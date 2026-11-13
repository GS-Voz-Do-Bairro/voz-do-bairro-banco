-- =====================================================================
-- VOZ DO BAIRRO - 04_pkg_transparencia.sql
-- Pacote PKG_TRANSPARENCIA: resposta da prefeitura e placar público.
--
--   FN_TAXA_RESPOSTA_NO_PRAZO(p_bairro_id) -> NUMBER   (% respondidas no prazo)
--   FN_CLASSIFICAR_TAXA(p_taxa)            -> VARCHAR2 (BOM/REGULAR/CRÍTICO)
--   PRC_REGISTRAR_RESPOSTA(...)                        (DEMANDA/ATRASADA -> EM_EXECUCAO/RECUSADA)
--   PRC_RELATORIO_BAIRRO(p_bairro_id)                  (placar via DBMS_OUTPUT)
--
-- Depende de PKG_PROPOSTA (FN_CALCULAR_PRIORIDADE) -> rodar 03 antes.
--
-- Códigos de erro deste pacote: -20010 .. -20019
--   -20010 bairro não encontrado
--   -20011 usuário (gestor) não encontrado
--   -20012 usuário não tem papel GESTOR
--   -20013 decisão inválida (use ACEITA ou RECUSADA)
--   -20014 justificativa obrigatória
--   -20015 proposta não encontrada
--   -20016 status da proposta não aceita resposta (precisa DEMANDA ou ATRASADA)
--   -20017 decisão ACEITA exige PRAZO_EXECUCAO futuro
--   -20018 proposta já possui resposta
-- =====================================================================
SET DEFINE OFF
SET SQLBLANKLINES ON
SET SERVEROUTPUT ON SIZE UNLIMITED

CREATE OR REPLACE PACKAGE PKG_TRANSPARENCIA AS

  /*
   * Taxa (%) de demandas respondidas dentro do prazo.
   *   Demandas "avaliáveis" = propostas que viraram DEMANDA (DT_VIROU_DEMANDA não nula)
   *                           e que JÁ têm resposta OU cujo prazo já venceu.
   *                           (demanda ainda dentro do prazo e sem resposta não conta)
   *   No prazo              = VB_RESPOSTA.DT_RESPOSTA <= VB_PROPOSTA.PRAZO_RESPOSTA
   *   taxa = ROUND(100 * no_prazo / avaliaveis, 2); NULL quando não há avaliáveis.
   *   p_bairro_id NULL = cidade toda. Bairro inexistente -> ORA-20010.
   */
  FUNCTION FN_TAXA_RESPOSTA_NO_PRAZO(p_bairro_id IN VB_BAIRRO.ID%TYPE DEFAULT NULL) RETURN NUMBER;

  -- NULL -> 'SEM DADOS'; >= 80 -> 'BOM'; >= 50 -> 'REGULAR'; < 50 -> 'CRÍTICO'
  FUNCTION FN_CLASSIFICAR_TAXA(p_taxa IN NUMBER) RETURN VARCHAR2;

  -- Gestor responde uma DEMANDA/ATRASADA. ACEITA -> EM_EXECUCAO (prazo futuro
  -- obrigatório); RECUSADA -> RECUSADA. Notifica o autor. Não faz COMMIT.
  PROCEDURE PRC_REGISTRAR_RESPOSTA(p_proposta_id    IN VB_PROPOSTA.ID%TYPE,
                                   p_gestor_id      IN VB_USUARIO.ID%TYPE,
                                   p_decisao        IN VARCHAR2,
                                   p_justificativa  IN VARCHAR2,
                                   p_prazo_execucao IN DATE DEFAULT NULL);

  -- Placar do bairro: propostas por status, apoios, taxa de resposta no prazo
  -- e as 3 propostas pendentes de maior prioridade.
  PROCEDURE PRC_RELATORIO_BAIRRO(p_bairro_id IN VB_BAIRRO.ID%TYPE);

END PKG_TRANSPARENCIA;
/
SHOW ERRORS PACKAGE PKG_TRANSPARENCIA

CREATE OR REPLACE PACKAGE BODY PKG_TRANSPARENCIA AS

  -- -------------------------------------------------------------------
  FUNCTION FN_TAXA_RESPOSTA_NO_PRAZO(p_bairro_id IN VB_BAIRRO.ID%TYPE DEFAULT NULL) RETURN NUMBER IS
    v_existe     PLS_INTEGER;
    v_avaliaveis NUMBER;
    v_no_prazo   NUMBER;
  BEGIN
    IF p_bairro_id IS NOT NULL THEN
      SELECT COUNT(*) INTO v_existe FROM VB_BAIRRO WHERE ID = p_bairro_id;
      IF v_existe = 0 THEN
        RAISE_APPLICATION_ERROR(-20010, 'Bairro ' || p_bairro_id || ' não encontrado.');
      END IF;
    END IF;

    SELECT COUNT(*),
           COUNT(CASE WHEN r.DT_RESPOSTA <= p.PRAZO_RESPOSTA THEN 1 END)
      INTO v_avaliaveis, v_no_prazo
      FROM VB_PROPOSTA p
      LEFT JOIN VB_RESPOSTA r ON r.PROPOSTA_ID = p.ID
     WHERE p.DT_VIROU_DEMANDA IS NOT NULL
       AND (p_bairro_id IS NULL OR p.BAIRRO_ID = p_bairro_id)
       AND (r.ID IS NOT NULL OR p.PRAZO_RESPOSTA < SYSTIMESTAMP);

    IF v_avaliaveis = 0 THEN
      RETURN NULL;
    END IF;

    RETURN ROUND(100 * v_no_prazo / v_avaliaveis, 2);
  END FN_TAXA_RESPOSTA_NO_PRAZO;

  -- -------------------------------------------------------------------
  FUNCTION FN_CLASSIFICAR_TAXA(p_taxa IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF p_taxa IS NULL THEN
      RETURN 'SEM DADOS';
    ELSIF p_taxa >= 80 THEN
      RETURN 'BOM';
    ELSIF p_taxa >= 50 THEN
      RETURN 'REGULAR';
    ELSE
      RETURN 'CRÍTICO';
    END IF;
  END FN_CLASSIFICAR_TAXA;

  -- -------------------------------------------------------------------
  PROCEDURE PRC_REGISTRAR_RESPOSTA(p_proposta_id    IN VB_PROPOSTA.ID%TYPE,
                                   p_gestor_id      IN VB_USUARIO.ID%TYPE,
                                   p_decisao        IN VARCHAR2,
                                   p_justificativa  IN VARCHAR2,
                                   p_prazo_execucao IN DATE DEFAULT NULL) IS
    v_papel       VB_USUARIO.PAPEL%TYPE;
    v_status      VB_PROPOSTA.STATUS%TYPE;
    v_autor_id    VB_PROPOSTA.AUTOR_ID%TYPE;
    v_titulo      VB_PROPOSTA.TITULO%TYPE;
    v_prazo_resp  VB_PROPOSTA.PRAZO_RESPOSTA%TYPE;
    v_qtd         PLS_INTEGER;
    v_decisao     VARCHAR2(4000) := UPPER(TRIM(p_decisao));
    v_novo_status VB_PROPOSTA.STATUS%TYPE;
    v_no_prazo    VARCHAR2(20);
  BEGIN
    -- 1) Gestor válido
    BEGIN
      SELECT PAPEL INTO v_papel FROM VB_USUARIO WHERE ID = p_gestor_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20011, 'Usuário ' || p_gestor_id || ' não encontrado.');
    END;
    IF v_papel <> 'GESTOR' THEN
      RAISE_APPLICATION_ERROR(-20012, 'Usuário ' || p_gestor_id || ' é ' || v_papel
                                      || '; somente GESTOR pode responder demandas.');
    END IF;

    -- 2) Decisão e justificativa
    IF v_decisao IS NULL OR v_decisao NOT IN ('ACEITA', 'RECUSADA') THEN
      RAISE_APPLICATION_ERROR(-20013, 'Decisão inválida: "' || SUBSTR(p_decisao, 1, 30) || '". Use ACEITA ou RECUSADA.');
    END IF;
    IF TRIM(p_justificativa) IS NULL THEN
      RAISE_APPLICATION_ERROR(-20014, 'Justificativa é obrigatória.');
    END IF;
    IF v_decisao = 'ACEITA'
       AND (p_prazo_execucao IS NULL OR TRUNC(p_prazo_execucao) <= TRUNC(SYSDATE)) THEN
      RAISE_APPLICATION_ERROR(-20017, 'Decisão ACEITA exige PRAZO_EXECUCAO futuro (a partir de amanhã).');
    END IF;

    -- 3) Proposta em status que aceita resposta (linha bloqueada)
    BEGIN
      SELECT STATUS, AUTOR_ID, TITULO, PRAZO_RESPOSTA
        INTO v_status, v_autor_id, v_titulo, v_prazo_resp
        FROM VB_PROPOSTA
       WHERE ID = p_proposta_id
         FOR UPDATE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20015, 'Proposta ' || p_proposta_id || ' não encontrada.');
    END;
    IF v_status NOT IN ('DEMANDA', 'ATRASADA') THEN
      RAISE_APPLICATION_ERROR(-20016, 'Proposta ' || p_proposta_id || ' está ' || v_status
                                      || '; só DEMANDA ou ATRASADA podem ser respondidas.');
    END IF;

    SELECT COUNT(*) INTO v_qtd FROM VB_RESPOSTA WHERE PROPOSTA_ID = p_proposta_id;
    IF v_qtd > 0 THEN
      RAISE_APPLICATION_ERROR(-20018, 'Proposta ' || p_proposta_id || ' já possui resposta.');
    END IF;

    -- 4) Grava a resposta e muda o status
    INSERT INTO VB_RESPOSTA (PROPOSTA_ID, GESTOR_ID, DECISAO, JUSTIFICATIVA, PRAZO_EXECUCAO)
    VALUES (p_proposta_id, p_gestor_id, v_decisao, TRIM(p_justificativa),
            CASE WHEN v_decisao = 'ACEITA' THEN TRUNC(p_prazo_execucao) END);

    IF v_decisao = 'ACEITA' THEN
      v_novo_status := 'EM_EXECUCAO';
    ELSE
      v_novo_status := 'RECUSADA';
    END IF;

    UPDATE VB_PROPOSTA SET STATUS = v_novo_status WHERE ID = p_proposta_id;

    IF v_prazo_resp IS NOT NULL AND SYSTIMESTAMP <= v_prazo_resp THEN
      v_no_prazo := 'dentro do prazo';
    ELSE
      v_no_prazo := 'fora do prazo';
    END IF;

    INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM)
    VALUES (v_autor_id, p_proposta_id,
            SUBSTR('A prefeitura respondeu sua proposta "' || v_titulo || '": ' || v_decisao
                   || CASE WHEN v_decisao = 'ACEITA'
                           THEN ' (execução até ' || TO_CHAR(p_prazo_execucao, 'DD/MM/YYYY') || ')'
                      END
                   || '.', 1, 500));

    DBMS_OUTPUT.PUT_LINE('Resposta registrada na proposta ' || p_proposta_id || ': ' || v_decisao
                         || ' -> ' || v_novo_status || ' (' || v_no_prazo || ').');
  END PRC_REGISTRAR_RESPOSTA;

  -- -------------------------------------------------------------------
  PROCEDURE PRC_RELATORIO_BAIRRO(p_bairro_id IN VB_BAIRRO.ID%TYPE) IS
    v_bairro       VB_BAIRRO%ROWTYPE;
    v_taxa         NUMBER;
    v_total_prop   PLS_INTEGER := 0;
    v_total_apoios NUMBER := 0;
    v_pos          PLS_INTEGER := 0;

    -- Todos os status aparecem, mesmo com zero propostas
    CURSOR c_status IS
      SELECT s.STATUS, COUNT(p.ID) AS QTD, NVL(SUM(p.TOTAL_APOIOS), 0) AS APOIOS
        FROM (SELECT 'ABERTA' AS STATUS, 1 AS ORDEM FROM DUAL UNION ALL
              SELECT 'DEMANDA',          2 FROM DUAL UNION ALL
              SELECT 'ATRASADA',         3 FROM DUAL UNION ALL
              SELECT 'EM_EXECUCAO',      4 FROM DUAL UNION ALL
              SELECT 'RECUSADA',         5 FROM DUAL UNION ALL
              SELECT 'CONCLUIDA',        6 FROM DUAL) s
        LEFT JOIN VB_PROPOSTA p
          ON p.STATUS = s.STATUS
         AND p.BAIRRO_ID = p_bairro_id
       GROUP BY s.STATUS, s.ORDEM
       ORDER BY s.ORDEM;

    CURSOR c_top IS
      SELECT ID, TITULO, STATUS, TOTAL_APOIOS, META_APOIOS,
             PKG_PROPOSTA.FN_CALCULAR_PRIORIDADE(ID) AS PRIORIDADE
        FROM VB_PROPOSTA
       WHERE BAIRRO_ID = p_bairro_id
         AND STATUS IN ('ABERTA', 'DEMANDA', 'ATRASADA')
       ORDER BY PRIORIDADE DESC, ID
       FETCH FIRST 3 ROWS ONLY;
  BEGIN
    BEGIN
      SELECT * INTO v_bairro FROM VB_BAIRRO WHERE ID = p_bairro_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20010, 'Bairro ' || p_bairro_id || ' não encontrado.');
    END;

    DBMS_OUTPUT.PUT_LINE('==============================================================');
    DBMS_OUTPUT.PUT_LINE(' PLACAR - ' || UPPER(v_bairro.NOME) || ' (Subpref. ' || v_bairro.SUBPREFEITURA
                         || ', ' || v_bairro.CIDADE || ')');
    DBMS_OUTPUT.PUT_LINE(' Meta padrão de apoios: ' || v_bairro.META_APOIOS_PADRAO);
    DBMS_OUTPUT.PUT_LINE('==============================================================');
    DBMS_OUTPUT.PUT_LINE(RPAD('STATUS', 14) || LPAD('PROPOSTAS', 10) || LPAD('APOIOS', 10));

    FOR r IN c_status LOOP
      DBMS_OUTPUT.PUT_LINE(RPAD(r.STATUS, 14) || LPAD(r.QTD, 10) || LPAD(r.APOIOS, 10));
      v_total_prop   := v_total_prop + r.QTD;
      v_total_apoios := v_total_apoios + r.APOIOS;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(RPAD('TOTAL', 14) || LPAD(v_total_prop, 10) || LPAD(v_total_apoios, 10));

    v_taxa := FN_TAXA_RESPOSTA_NO_PRAZO(p_bairro_id);
    DBMS_OUTPUT.PUT_LINE('Taxa de resposta no prazo: '
                         || NVL(TO_CHAR(v_taxa, 'FM990D00'), '-') || '% -> ' || FN_CLASSIFICAR_TAXA(v_taxa));

    DBMS_OUTPUT.PUT_LINE('Top 3 pendentes por prioridade:');
    FOR r IN c_top LOOP
      v_pos := v_pos + 1;
      DBMS_OUTPUT.PUT_LINE('  ' || v_pos || ') #' || r.ID || ' ' || r.TITULO || ' [' || r.STATUS || ', '
                           || r.TOTAL_APOIOS || '/' || r.META_APOIOS || ' apoios, prioridade '
                           || TO_CHAR(r.PRIORIDADE, 'FM990D00') || ']');
    END LOOP;
    IF v_pos = 0 THEN
      DBMS_OUTPUT.PUT_LINE('  (nenhuma proposta pendente)');
    END IF;
  END PRC_RELATORIO_BAIRRO;

END PKG_TRANSPARENCIA;
/
SHOW ERRORS PACKAGE BODY PKG_TRANSPARENCIA
