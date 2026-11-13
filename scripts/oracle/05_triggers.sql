-- =====================================================================
-- VOZ DO BAIRRO - 05_triggers.sql
--
-- TRG_VB_APOIO_AUDITORIA  : trilha de auditoria de VB_APOIO (INSERT/UPDATE/DELETE)
--                           -> VB_AUDITORIA_APOIO (operação, valores antigos/novos
--                              em texto JSON, data e usuário do banco)
-- TRG_VB_PROPOSTA_STATUS  : valida as transições de STATUS do contrato e, ao
--                           virar DEMANDA, completa DT_VIROU_DEMANDA/PRAZO_RESPOSTA
--                           se vierem nulos.
--
-- Código de erro: -20020 transição de status inválida.
--
-- Compatibilidade com as APIs (contrato, seção 2):
--   .NET : ABERTA -> DEMANDA (já envia DT_VIROU_DEMANDA e PRAZO_RESPOSTA: são mantidos)
--   Java : DEMANDA -> ATRASADA | DEMANDA/ATRASADA -> EM_EXECUCAO/RECUSADA
--          | EM_EXECUCAO -> CONCLUIDA
--   UPDATE que regrava o MESMO status (ex.: JPA/EF atualizando todas as colunas)
--   é permitido.
-- Nenhum dos gatilhos consulta a própria tabela -> sem ORA-04091 (mutating table).
-- Os gatilhos NÃO alteram TOTAL_APOIOS (quem mantém o contador é a API .NET).
-- =====================================================================
SET DEFINE OFF
SET SQLBLANKLINES ON
SET SERVEROUTPUT ON SIZE UNLIMITED

-- ---------------------------------------------------------------------
-- 1) Auditoria de apoios
-- ---------------------------------------------------------------------
CREATE OR REPLACE TRIGGER TRG_VB_APOIO_AUDITORIA
AFTER INSERT OR UPDATE OR DELETE ON VB_APOIO
FOR EACH ROW
DECLARE
  v_operacao VB_AUDITORIA_APOIO.OPERACAO%TYPE;
  v_antigos  VB_AUDITORIA_APOIO.VALORES_ANTIGOS%TYPE;
  v_novos    VB_AUDITORIA_APOIO.VALORES_NOVOS%TYPE;

  -- Monta o registro como texto JSON: {"id":1,"propostaId":2,"usuarioId":3,"dtApoio":"..."}
  FUNCTION fmt_json(p_id        IN NUMBER,
                   p_proposta  IN NUMBER,
                   p_usuario   IN NUMBER,
                   p_dt_apoio  IN TIMESTAMP) RETURN VARCHAR2 IS
  BEGIN
    RETURN '{"id":'         || NVL(TO_CHAR(p_id), 'null')
        || ',"propostaId":' || NVL(TO_CHAR(p_proposta), 'null')
        || ',"usuarioId":'  || NVL(TO_CHAR(p_usuario), 'null')
        || ',"dtApoio":'    || CASE WHEN p_dt_apoio IS NULL THEN 'null'
                                    ELSE '"' || TO_CHAR(p_dt_apoio, 'YYYY-MM-DD"T"HH24:MI:SS') || '"'
                               END
        || '}';
  END fmt_json;
BEGIN
  IF INSERTING THEN
    v_operacao := 'INSERT';
    v_novos    := fmt_json(:NEW.ID, :NEW.PROPOSTA_ID, :NEW.USUARIO_ID, :NEW.DT_APOIO);
  ELSIF UPDATING THEN
    v_operacao := 'UPDATE';
    v_antigos  := fmt_json(:OLD.ID, :OLD.PROPOSTA_ID, :OLD.USUARIO_ID, :OLD.DT_APOIO);
    v_novos    := fmt_json(:NEW.ID, :NEW.PROPOSTA_ID, :NEW.USUARIO_ID, :NEW.DT_APOIO);
  ELSE
    v_operacao := 'DELETE';
    v_antigos  := fmt_json(:OLD.ID, :OLD.PROPOSTA_ID, :OLD.USUARIO_ID, :OLD.DT_APOIO);
  END IF;

  INSERT INTO VB_AUDITORIA_APOIO
         (OPERACAO, APOIO_ID, PROPOSTA_ID, USUARIO_ID,
          VALORES_ANTIGOS, VALORES_NOVOS, DT_OPERACAO, USUARIO_BD)
  VALUES (v_operacao,
          NVL(:NEW.ID, :OLD.ID),
          NVL(:NEW.PROPOSTA_ID, :OLD.PROPOSTA_ID),
          NVL(:NEW.USUARIO_ID, :OLD.USUARIO_ID),
          v_antigos, v_novos, SYSTIMESTAMP,
          SUBSTR(SYS_CONTEXT('USERENV', 'SESSION_USER'), 1, 100));
END TRG_VB_APOIO_AUDITORIA;
/
SHOW ERRORS TRIGGER TRG_VB_APOIO_AUDITORIA

-- ---------------------------------------------------------------------
-- 2) Máquina de estados da proposta
-- ---------------------------------------------------------------------
CREATE OR REPLACE TRIGGER TRG_VB_PROPOSTA_STATUS
BEFORE UPDATE OF STATUS ON VB_PROPOSTA
FOR EACH ROW
DECLARE
  v_de     VB_PROPOSTA.STATUS%TYPE;
  v_para   VB_PROPOSTA.STATUS%TYPE;
  v_valida BOOLEAN := FALSE;
BEGIN
  v_de   := :OLD.STATUS;
  v_para := :NEW.STATUS;

  IF v_de = v_para THEN
    v_valida := TRUE;                                   -- regravação do mesmo status
  ELSIF v_de = 'ABERTA' AND v_para = 'DEMANDA' THEN
    v_valida := TRUE;                                   -- .NET: meta atingida
  ELSIF v_de = 'DEMANDA' AND v_para IN ('ATRASADA', 'EM_EXECUCAO', 'RECUSADA') THEN
    v_valida := TRUE;                                   -- Java: agendador / resposta do gestor
  ELSIF v_de = 'ATRASADA' AND v_para IN ('EM_EXECUCAO', 'RECUSADA') THEN
    v_valida := TRUE;                                   -- Java: resposta fora do prazo
  ELSIF v_de = 'EM_EXECUCAO' AND v_para = 'CONCLUIDA' THEN
    v_valida := TRUE;                                   -- Java: gestor conclui
  END IF;

  IF NOT v_valida THEN
    RAISE_APPLICATION_ERROR(-20020, 'Transição de status inválida na proposta ' || :OLD.ID
                                    || ': ' || v_de || ' -> ' || v_para || '.');
  END IF;

  -- Virou DEMANDA: garante as datas mesmo se quem atualizou não as enviou
  IF v_para = 'DEMANDA' AND v_de <> 'DEMANDA' THEN
    IF :NEW.DT_VIROU_DEMANDA IS NULL THEN
      :NEW.DT_VIROU_DEMANDA := SYSTIMESTAMP;
    END IF;
    IF :NEW.PRAZO_RESPOSTA IS NULL THEN
      :NEW.PRAZO_RESPOSTA := :NEW.DT_VIROU_DEMANDA + NUMTODSINTERVAL(15, 'DAY');
    END IF;
  END IF;
END TRG_VB_PROPOSTA_STATUS;
/
SHOW ERRORS TRIGGER TRG_VB_PROPOSTA_STATUS

-- Conferência: os dois gatilhos devem aparecer ENABLED
SELECT TRIGGER_NAME, TABLE_NAME, TRIGGERING_EVENT, STATUS
  FROM USER_TRIGGERS
 WHERE TRIGGER_NAME IN ('TRG_VB_APOIO_AUDITORIA', 'TRG_VB_PROPOSTA_STATUS');
