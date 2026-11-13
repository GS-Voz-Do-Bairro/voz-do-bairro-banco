-- =====================================================================
-- VOZ DO BAIRRO - 03_pkg_proposta.sql
-- Pacote PKG_PROPOSTA: regras do ciclo de vida da proposta.
--
--   FN_CALCULAR_PRIORIDADE(p_proposta_id)  -> NUMBER  (score de prioridade)
--   FN_APOIOS_FALTANTES(p_proposta_id)     -> NUMBER  (quanto falta p/ meta)
--   PRC_CONVERTER_EM_DEMANDA(p_proposta_id)          (ABERTA -> DEMANDA)
--   PRC_MARCAR_ATRASADAS(p_qtd_marcadas OUT)         (DEMANDA -> ATRASADA)
--   PRC_MARCAR_ATRASADAS                             (sobrecarga: só exibe)
--
-- Códigos de erro deste pacote: -20001 .. -20009
--   -20001 proposta não encontrada
--   -20002 status atual não permite virar DEMANDA (precisa estar ABERTA)
--   -20003 meta de apoios ainda não atingida
--
-- As procedures NÃO fazem COMMIT: quem chama controla a transação
-- (permite SAVEPOINT/ROLLBACK nos testes e uso dentro de transações maiores).
-- =====================================================================
SET DEFINE OFF
SET SQLBLANKLINES ON
SET SERVEROUTPUT ON SIZE UNLIMITED

CREATE OR REPLACE PACKAGE PKG_PROPOSTA AS

  -- Prazo (em dias) que a prefeitura tem para responder uma DEMANDA (contrato: 15)
  c_prazo_resposta_dias  CONSTANT PLS_INTEGER := 15;
  -- Peso extra para categorias críticas (SEGURANCA e SAUDE)
  c_peso_categoria_critica CONSTANT NUMBER := 1.5;
  -- Bônus para demandas já ATRASADAS (a prefeitura está devendo resposta)
  c_bonus_atraso CONSTANT NUMBER := 20;

  /*
   * Score de prioridade de atendimento (0 a 170):
   *
   *   score = ( 60 * LEAST(TOTAL_APOIOS / META_APOIOS, 1)      -- engajamento (até 60)
   *           + 40 * LEAST(DIAS_EM_ABERTO / 60, 1) )           -- tempo de espera (até 40)
   *           * PESO_CATEGORIA                                  -- 1.5 SEGURANCA/SAUDE, 1.0 demais
   *           + BONUS_ATRASO                                    -- +20 se STATUS = 'ATRASADA'
   *
   *   DIAS_EM_ABERTO = dias inteiros desde DT_CRIACAO.
   *   Propostas EM_EXECUCAO, CONCLUIDA ou RECUSADA já foram tratadas -> score 0.
   *   Resultado arredondado em 2 casas. Proposta inexistente -> ORA-20001.
   */
  FUNCTION FN_CALCULAR_PRIORIDADE(p_proposta_id IN VB_PROPOSTA.ID%TYPE) RETURN NUMBER;

  -- Quantos apoios ainda faltam para a meta (0 se já atingiu). Inexistente -> ORA-20001.
  FUNCTION FN_APOIOS_FALTANTES(p_proposta_id IN VB_PROPOSTA.ID%TYPE) RETURN NUMBER;

  -- ABERTA com TOTAL_APOIOS >= META_APOIOS vira DEMANDA (prazo de 15 dias)
  -- e notifica o autor e todos os gestores.
  PROCEDURE PRC_CONVERTER_EM_DEMANDA(p_proposta_id IN VB_PROPOSTA.ID%TYPE);

  -- Varre (cursor) as DEMANDAS com prazo vencido e sem resposta, muda para
  -- ATRASADA, notifica autor e gestores e devolve quantas foram marcadas.
  PROCEDURE PRC_MARCAR_ATRASADAS(p_qtd_marcadas OUT PLS_INTEGER);

  -- Mesma regra, apenas exibindo a quantidade no DBMS_OUTPUT.
  PROCEDURE PRC_MARCAR_ATRASADAS;

END PKG_PROPOSTA;
/
SHOW ERRORS PACKAGE PKG_PROPOSTA

CREATE OR REPLACE PACKAGE BODY PKG_PROPOSTA AS

  -- -------------------------------------------------------------------
  -- Auxiliares privados (não aparecem na especificação)
  -- -------------------------------------------------------------------
  PROCEDURE notificar(p_usuario_id  IN VB_USUARIO.ID%TYPE,
                      p_proposta_id IN VB_PROPOSTA.ID%TYPE,
                      p_mensagem    IN VARCHAR2) IS
  BEGIN
    INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM)
    VALUES (p_usuario_id, p_proposta_id, SUBSTR(p_mensagem, 1, 500));
  END notificar;

  PROCEDURE notificar_gestores(p_proposta_id IN VB_PROPOSTA.ID%TYPE,
                               p_mensagem    IN VARCHAR2,
                               p_qtd         OUT PLS_INTEGER) IS
  BEGIN
    INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM)
    SELECT u.ID, p_proposta_id, SUBSTR(p_mensagem, 1, 500)
      FROM VB_USUARIO u
     WHERE u.PAPEL = 'GESTOR';
    p_qtd := SQL%ROWCOUNT;
  END notificar_gestores;

  -- -------------------------------------------------------------------
  FUNCTION FN_CALCULAR_PRIORIDADE(p_proposta_id IN VB_PROPOSTA.ID%TYPE) RETURN NUMBER IS
    v_status    VB_PROPOSTA.STATUS%TYPE;
    v_categoria VB_PROPOSTA.CATEGORIA%TYPE;
    v_meta      VB_PROPOSTA.META_APOIOS%TYPE;
    v_total     VB_PROPOSTA.TOTAL_APOIOS%TYPE;
    v_criacao   VB_PROPOSTA.DT_CRIACAO%TYPE;
    v_dias      NUMBER;
    v_peso      NUMBER := 1;
    v_score     NUMBER;
  BEGIN
    SELECT STATUS, CATEGORIA, META_APOIOS, TOTAL_APOIOS, DT_CRIACAO
      INTO v_status, v_categoria, v_meta, v_total, v_criacao
      FROM VB_PROPOSTA
     WHERE ID = p_proposta_id;

    -- Já tratadas pela prefeitura: sem prioridade de atendimento
    IF v_status NOT IN ('ABERTA', 'DEMANDA', 'ATRASADA') THEN
      RETURN 0;
    END IF;

    v_dias := GREATEST(TRUNC(SYSDATE - CAST(v_criacao AS DATE)), 0);

    IF v_categoria IN ('SEGURANCA', 'SAUDE') THEN
      v_peso := c_peso_categoria_critica;
    END IF;

    v_score := (60 * LEAST(v_total / v_meta, 1) + 40 * LEAST(v_dias / 60, 1)) * v_peso;

    IF v_status = 'ATRASADA' THEN
      v_score := v_score + c_bonus_atraso;
    END IF;

    RETURN ROUND(v_score, 2);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20001, 'Proposta ' || p_proposta_id || ' não encontrada.');
  END FN_CALCULAR_PRIORIDADE;

  -- -------------------------------------------------------------------
  FUNCTION FN_APOIOS_FALTANTES(p_proposta_id IN VB_PROPOSTA.ID%TYPE) RETURN NUMBER IS
    v_meta  VB_PROPOSTA.META_APOIOS%TYPE;
    v_total VB_PROPOSTA.TOTAL_APOIOS%TYPE;
  BEGIN
    SELECT META_APOIOS, TOTAL_APOIOS
      INTO v_meta, v_total
      FROM VB_PROPOSTA
     WHERE ID = p_proposta_id;
    RETURN GREATEST(v_meta - v_total, 0);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20001, 'Proposta ' || p_proposta_id || ' não encontrada.');
  END FN_APOIOS_FALTANTES;

  -- -------------------------------------------------------------------
  PROCEDURE PRC_CONVERTER_EM_DEMANDA(p_proposta_id IN VB_PROPOSTA.ID%TYPE) IS
    v_prop         VB_PROPOSTA%ROWTYPE;
    v_qtd_gestores PLS_INTEGER := 0;
  BEGIN
    -- Bloqueia a linha para evitar duas conversões simultâneas
    BEGIN
      SELECT *
        INTO v_prop
        FROM VB_PROPOSTA
       WHERE ID = p_proposta_id
         FOR UPDATE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Proposta ' || p_proposta_id || ' não encontrada.');
    END;

    IF v_prop.STATUS <> 'ABERTA' THEN
      RAISE_APPLICATION_ERROR(-20002, 'Proposta ' || p_proposta_id || ' está ' || v_prop.STATUS
                                      || '; somente proposta ABERTA pode virar DEMANDA.');
    END IF;

    IF v_prop.TOTAL_APOIOS < v_prop.META_APOIOS THEN
      RAISE_APPLICATION_ERROR(-20003, 'Meta não atingida na proposta ' || p_proposta_id || ': '
                                      || v_prop.TOTAL_APOIOS || '/' || v_prop.META_APOIOS || ' apoios.');
    END IF;

    UPDATE VB_PROPOSTA
       SET STATUS           = 'DEMANDA',
           DT_VIROU_DEMANDA = SYSTIMESTAMP,
           PRAZO_RESPOSTA   = SYSTIMESTAMP + NUMTODSINTERVAL(c_prazo_resposta_dias, 'DAY')
     WHERE ID = p_proposta_id;

    notificar(v_prop.AUTOR_ID, p_proposta_id,
              'Sua proposta "' || v_prop.TITULO || '" atingiu a meta de ' || v_prop.META_APOIOS
              || ' apoios e virou DEMANDA. A prefeitura tem ' || c_prazo_resposta_dias
              || ' dias para responder.');

    notificar_gestores(p_proposta_id,
              'Nova DEMANDA: "' || v_prop.TITULO || '". Prazo de resposta: '
              || TO_CHAR(SYSDATE + c_prazo_resposta_dias, 'DD/MM/YYYY') || '.',
              v_qtd_gestores);

    DBMS_OUTPUT.PUT_LINE('Proposta ' || p_proposta_id || ' convertida em DEMANDA. Notificações: 1 autor + '
                         || v_qtd_gestores || ' gestor(es).');
  END PRC_CONVERTER_EM_DEMANDA;

  -- -------------------------------------------------------------------
  PROCEDURE PRC_MARCAR_ATRASADAS(p_qtd_marcadas OUT PLS_INTEGER) IS
    CURSOR c_vencidas IS
      SELECT p.ID, p.TITULO, p.AUTOR_ID, p.PRAZO_RESPOSTA
        FROM VB_PROPOSTA p
       WHERE p.STATUS = 'DEMANDA'
         AND p.PRAZO_RESPOSTA < SYSTIMESTAMP
         AND NOT EXISTS (SELECT 1 FROM VB_RESPOSTA r WHERE r.PROPOSTA_ID = p.ID)
       ORDER BY p.PRAZO_RESPOSTA
         FOR UPDATE OF p.STATUS;
    v_qtd_gestores PLS_INTEGER;
  BEGIN
    p_qtd_marcadas := 0;

    FOR r IN c_vencidas LOOP
      UPDATE VB_PROPOSTA
         SET STATUS = 'ATRASADA'
       WHERE CURRENT OF c_vencidas;

      notificar(r.AUTOR_ID, r.ID,
                'O prazo de resposta da proposta "' || r.TITULO
                || '" venceu sem resposta. Status: ATRASADA.');
      notificar_gestores(r.ID,
                'Demanda ATRASADA: "' || r.TITULO || '" está sem resposta desde '
                || TO_CHAR(r.PRAZO_RESPOSTA, 'DD/MM/YYYY HH24:MI') || '.',
                v_qtd_gestores);

      p_qtd_marcadas := p_qtd_marcadas + 1;
      DBMS_OUTPUT.PUT_LINE('  ATRASADA -> #' || r.ID || ' ' || r.TITULO
                           || ' (prazo ' || TO_CHAR(r.PRAZO_RESPOSTA, 'DD/MM/YYYY HH24:MI') || ')');
    END LOOP;
  END PRC_MARCAR_ATRASADAS;

  -- -------------------------------------------------------------------
  PROCEDURE PRC_MARCAR_ATRASADAS IS
    v_qtd PLS_INTEGER;
  BEGIN
    PRC_MARCAR_ATRASADAS(v_qtd);
    DBMS_OUTPUT.PUT_LINE('Demandas marcadas como ATRASADA: ' || v_qtd);
  END PRC_MARCAR_ATRASADAS;

END PKG_PROPOSTA;
/
SHOW ERRORS PACKAGE BODY PKG_PROPOSTA
