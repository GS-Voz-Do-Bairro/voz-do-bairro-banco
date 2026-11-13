-- =====================================================================
-- VOZ DO BAIRRO - 07_testes.sql
-- Testes dos pacotes e gatilhos. Cada caso imprime ESPERADO x OBTIDO e
-- [OK]/[FALHOU]. Casos de erro capturam a exceção e comparam o SQLCODE.
--
-- Todos os testes rodam dentro de SAVEPOINT e terminam com ROLLBACK TO:
-- os dados de 02_dados.sql NÃO são alterados.
-- IMPORTANTE: rodar com AUTOCOMMIT DESLIGADO (padrão do SQL Developer),
-- senão o ROLLBACK TO falha com ORA-01086.
--
-- Os valores "esperados" fixos (ex.: taxas por bairro) valem para os dados
-- recém-carregados pelo 02_dados.sql (as demandas em aberto têm prazo de
-- 11+ dias a partir da carga).
-- =====================================================================
SET DEFINE OFF
SET SQLBLANKLINES ON
SET SERVEROUTPUT ON SIZE UNLIMITED

-- =====================================================================
-- TESTE 1 - PKG_PROPOSTA
-- =====================================================================
DECLARE
  v_ok      PLS_INTEGER := 0;
  v_falhas  PLS_INTEGER := 0;

  v_autor      NUMBER;
  v_apoiador   NUMBER;
  v_bairro     NUMBER;
  v_gestores   NUMBER;
  v_id_a       NUMBER;   -- ZELADORIA, 5/10 apoios, 30 dias
  v_id_b       NUMBER;   -- SAUDE,     5/10 apoios, 30 dias
  v_id_c       NUMBER;   -- meta 1 atingida, para conversão
  v_id_fechada NUMBER;
  v_id_demanda NUMBER;
  v_status     VB_PROPOSTA.STATUS%TYPE;
  v_dias_prazo NUMBER;
  v_qtd        NUMBER;
  v_marcadas   PLS_INTEGER;
  v_ja_vencidas NUMBER;

  PROCEDURE verificar(p_caso IN VARCHAR2, p_esperado IN VARCHAR2, p_obtido IN VARCHAR2) IS
  BEGIN
    IF p_esperado = p_obtido OR (p_esperado IS NULL AND p_obtido IS NULL) THEN
      v_ok := v_ok + 1;
      DBMS_OUTPUT.PUT_LINE('[OK]     ' || p_caso || ' | esperado=' || NVL(p_esperado, 'NULL')
                           || ' | obtido=' || NVL(p_obtido, 'NULL'));
    ELSE
      v_falhas := v_falhas + 1;
      DBMS_OUTPUT.PUT_LINE('[FALHOU] ' || p_caso || ' | esperado=' || NVL(p_esperado, 'NULL')
                           || ' | obtido=' || NVL(p_obtido, 'NULL'));
    END IF;
  END verificar;
BEGIN
  DBMS_OUTPUT.PUT_LINE('========== TESTE 1 - PKG_PROPOSTA ==========');
  SAVEPOINT sp_teste_proposta;

  SELECT ID INTO v_autor    FROM VB_USUARIO WHERE EMAIL = 'cidadao@vozdobairro.com';
  SELECT ID INTO v_apoiador FROM VB_USUARIO WHERE EMAIL = 'vizinho@vozdobairro.com';
  SELECT ID INTO v_bairro   FROM VB_BAIRRO  WHERE NOME  = 'Capão Redondo';
  SELECT COUNT(*) INTO v_gestores FROM VB_USUARIO WHERE PAPEL = 'GESTOR';
  SELECT ID INTO v_id_fechada FROM VB_PROPOSTA WHERE TITULO = 'Reabertura da biblioteca comunitária de Itaquera';
  SELECT ID INTO v_id_demanda FROM VB_PROPOSTA WHERE TITULO = 'Reforma da quadra do CEU Capão Redondo';

  -- Massa de teste controlada (desfeita no ROLLBACK).
  -- 30.05 dias (= 30 dias e ~1h) para que TRUNC(dias em aberto) seja exatamente 30.
  INSERT INTO VB_PROPOSTA (TITULO, DESCRICAO, CATEGORIA, META_APOIOS, TOTAL_APOIOS, AUTOR_ID, BAIRRO_ID, DT_CRIACAO)
  VALUES ('TESTE A', 'Proposta de teste A', 'ZELADORIA', 10, 5, v_autor, v_bairro,
          SYSTIMESTAMP - NUMTODSINTERVAL(30.05, 'DAY'))
  RETURNING ID INTO v_id_a;

  INSERT INTO VB_PROPOSTA (TITULO, DESCRICAO, CATEGORIA, META_APOIOS, TOTAL_APOIOS, AUTOR_ID, BAIRRO_ID, DT_CRIACAO)
  VALUES ('TESTE B', 'Proposta de teste B', 'SAUDE', 10, 5, v_autor, v_bairro,
          SYSTIMESTAMP - NUMTODSINTERVAL(30.05, 'DAY'))
  RETURNING ID INTO v_id_b;

  INSERT INTO VB_PROPOSTA (TITULO, DESCRICAO, CATEGORIA, META_APOIOS, TOTAL_APOIOS, AUTOR_ID, BAIRRO_ID)
  VALUES ('TESTE C', 'Proposta de teste C', 'LAZER', 1, 1, v_autor, v_bairro)
  RETURNING ID INTO v_id_c;
  INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID) VALUES (v_id_c, v_apoiador);

  -- 1.1 FN_CALCULAR_PRIORIDADE: (60*5/10 + 40*30/60) * 1.0 = 50
  verificar('1.1 Prioridade ZELADORIA 5/10, 30 dias', '50',
            TO_CHAR(PKG_PROPOSTA.FN_CALCULAR_PRIORIDADE(v_id_a)));
  -- 1.2 mesma proposta em SAUDE: peso 1.5 -> 75
  verificar('1.2 Prioridade SAUDE 5/10, 30 dias (peso 1.5)', '75',
            TO_CHAR(PKG_PROPOSTA.FN_CALCULAR_PRIORIDADE(v_id_b)));
  -- 1.3 proposta CONCLUIDA -> 0
  verificar('1.3 Prioridade de proposta CONCLUIDA', '0',
            TO_CHAR(PKG_PROPOSTA.FN_CALCULAR_PRIORIDADE(v_id_fechada)));
  -- 1.4 proposta inexistente -> ORA-20001
  BEGIN
    v_qtd := PKG_PROPOSTA.FN_CALCULAR_PRIORIDADE(-1);
    verificar('1.4 Prioridade de proposta inexistente', '-20001', 'sem erro');
  EXCEPTION WHEN OTHERS THEN
    verificar('1.4 Prioridade de proposta inexistente', '-20001', TO_CHAR(SQLCODE));
  END;
  -- 1.5 FN_APOIOS_FALTANTES
  verificar('1.5 Apoios faltantes (5/10)', '5', TO_CHAR(PKG_PROPOSTA.FN_APOIOS_FALTANTES(v_id_a)));

  -- 1.6 Converter sem meta atingida -> ORA-20003
  BEGIN
    PKG_PROPOSTA.PRC_CONVERTER_EM_DEMANDA(v_id_a);
    verificar('1.6 Converter com meta não atingida', '-20003', 'sem erro');
  EXCEPTION WHEN OTHERS THEN
    verificar('1.6 Converter com meta não atingida', '-20003', TO_CHAR(SQLCODE));
  END;

  -- 1.7 Converter proposta que já é DEMANDA -> ORA-20002
  BEGIN
    PKG_PROPOSTA.PRC_CONVERTER_EM_DEMANDA(v_id_demanda);
    verificar('1.7 Converter proposta que já é DEMANDA', '-20002', 'sem erro');
  EXCEPTION WHEN OTHERS THEN
    verificar('1.7 Converter proposta que já é DEMANDA', '-20002', TO_CHAR(SQLCODE));
  END;

  -- 1.8 Converter proposta inexistente -> ORA-20001
  BEGIN
    PKG_PROPOSTA.PRC_CONVERTER_EM_DEMANDA(-1);
    verificar('1.8 Converter proposta inexistente', '-20001', 'sem erro');
  EXCEPTION WHEN OTHERS THEN
    verificar('1.8 Converter proposta inexistente', '-20001', TO_CHAR(SQLCODE));
  END;

  -- 1.9 Sucesso: meta 1/1 -> DEMANDA, prazo de 15 dias, notificações autor + gestores
  PKG_PROPOSTA.PRC_CONVERTER_EM_DEMANDA(v_id_c);
  SELECT STATUS, EXTRACT(DAY FROM (PRAZO_RESPOSTA - DT_VIROU_DEMANDA))
    INTO v_status, v_dias_prazo
    FROM VB_PROPOSTA WHERE ID = v_id_c;
  verificar('1.9a Status após conversão', 'DEMANDA', v_status);
  verificar('1.9b Prazo de resposta (dias)', '15', TO_CHAR(v_dias_prazo));
  SELECT COUNT(*) INTO v_qtd FROM VB_NOTIFICACAO WHERE PROPOSTA_ID = v_id_c;
  verificar('1.9c Notificações geradas (1 autor + gestores)', TO_CHAR(1 + v_gestores), TO_CHAR(v_qtd));

  -- 1.10 PRC_MARCAR_ATRASADAS: força o prazo da TESTE C para ontem
  SELECT COUNT(*) INTO v_ja_vencidas
    FROM VB_PROPOSTA p
   WHERE p.STATUS = 'DEMANDA' AND p.PRAZO_RESPOSTA < SYSTIMESTAMP
     AND NOT EXISTS (SELECT 1 FROM VB_RESPOSTA r WHERE r.PROPOSTA_ID = p.ID);
  UPDATE VB_PROPOSTA SET PRAZO_RESPOSTA = SYSTIMESTAMP - NUMTODSINTERVAL(1, 'DAY') WHERE ID = v_id_c;

  PKG_PROPOSTA.PRC_MARCAR_ATRASADAS(v_marcadas);
  verificar('1.10a Demandas marcadas como ATRASADA', TO_CHAR(v_ja_vencidas + 1), TO_CHAR(v_marcadas));
  SELECT STATUS INTO v_status FROM VB_PROPOSTA WHERE ID = v_id_c;
  verificar('1.10b Status da TESTE C', 'ATRASADA', v_status);
  SELECT COUNT(*) INTO v_qtd FROM VB_NOTIFICACAO WHERE PROPOSTA_ID = v_id_c;
  verificar('1.10c Notificações da TESTE C (conversão + atraso)', TO_CHAR(2 * (1 + v_gestores)), TO_CHAR(v_qtd));

  -- 1.11 Segunda execução não marca de novo (idempotente)
  PKG_PROPOSTA.PRC_MARCAR_ATRASADAS(v_marcadas);
  verificar('1.11 Segunda varredura', '0', TO_CHAR(v_marcadas));

  ROLLBACK TO sp_teste_proposta;
  DBMS_OUTPUT.PUT_LINE('RESULTADO TESTE 1: ' || v_ok || ' OK, ' || v_falhas || ' falha(s). (alterações desfeitas)');
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO sp_teste_proposta;
    DBMS_OUTPUT.PUT_LINE('ERRO INESPERADO NO TESTE 1: ' || SQLERRM);
    RAISE;
END;
/

-- =====================================================================
-- TESTE 2 - PKG_TRANSPARENCIA
-- =====================================================================
DECLARE
  v_ok      PLS_INTEGER := 0;
  v_falhas  PLS_INTEGER := 0;

  v_gestor      NUMBER;
  v_cidadao     NUMBER;
  v_bras        NUMBER;
  v_id_dem_bras NUMBER;   -- DEMANDA na Brasilândia (escadaria)
  v_id_atrasada NUMBER;   -- ATRASADA no Capão (UBS sábados)
  v_id_aberta   NUMBER;
  v_id_dem_ceu  NUMBER;   -- DEMANDA no Capão (quadra do CEU)
  v_status      VB_PROPOSTA.STATUS%TYPE;
  v_decisao     VB_RESPOSTA.DECISAO%TYPE;
  v_qtd         NUMBER;
  v_notif_antes NUMBER;

  PROCEDURE verificar(p_caso IN VARCHAR2, p_esperado IN VARCHAR2, p_obtido IN VARCHAR2) IS
  BEGIN
    IF p_esperado = p_obtido OR (p_esperado IS NULL AND p_obtido IS NULL) THEN
      v_ok := v_ok + 1;
      DBMS_OUTPUT.PUT_LINE('[OK]     ' || p_caso || ' | esperado=' || NVL(p_esperado, 'NULL')
                           || ' | obtido=' || NVL(p_obtido, 'NULL'));
    ELSE
      v_falhas := v_falhas + 1;
      DBMS_OUTPUT.PUT_LINE('[FALHOU] ' || p_caso || ' | esperado=' || NVL(p_esperado, 'NULL')
                           || ' | obtido=' || NVL(p_obtido, 'NULL'));
    END IF;
  END verificar;

  FUNCTION taxa(p_nome_bairro IN VARCHAR2) RETURN VARCHAR2 IS
    v_id NUMBER;
  BEGIN
    SELECT ID INTO v_id FROM VB_BAIRRO WHERE NOME = p_nome_bairro;
    RETURN TO_CHAR(PKG_TRANSPARENCIA.FN_TAXA_RESPOSTA_NO_PRAZO(v_id));
  END taxa;
BEGIN
  DBMS_OUTPUT.PUT_LINE('========== TESTE 2 - PKG_TRANSPARENCIA ==========');
  SAVEPOINT sp_teste_transparencia;

  SELECT ID INTO v_gestor  FROM VB_USUARIO WHERE EMAIL = 'gestor@vozdobairro.com';
  SELECT ID INTO v_cidadao FROM VB_USUARIO WHERE EMAIL = 'cidadao@vozdobairro.com';
  SELECT ID INTO v_bras    FROM VB_BAIRRO  WHERE NOME  = 'Brasilândia';
  SELECT ID INTO v_id_dem_bras FROM VB_PROPOSTA WHERE TITULO = 'Iluminação da escadaria da Rua Parapuã';
  SELECT ID INTO v_id_atrasada FROM VB_PROPOSTA WHERE TITULO = 'UBS do Capão Redondo aberta aos sábados';
  SELECT ID INTO v_id_aberta   FROM VB_PROPOSTA WHERE TITULO = 'Iluminação na Rua Agnaldo Macedo';
  SELECT ID INTO v_id_dem_ceu  FROM VB_PROPOSTA WHERE TITULO = 'Reforma da quadra do CEU Capão Redondo';

  -- 2.1 Taxas de resposta no prazo (dados da carga)
  verificar('2.1a Taxa Vila Mariana',  '100', taxa('Vila Mariana'));
  verificar('2.1b Taxa Capão Redondo', '50',  taxa('Capão Redondo'));
  verificar('2.1c Taxa Itaquera',      '50',  taxa('Itaquera'));
  verificar('2.1d Taxa Brasilândia',   '0',   taxa('Brasilândia'));
  verificar('2.1e Taxa Grajaú',        '50',  taxa('Grajaú'));
  verificar('2.1f Taxa Mooca (sem demandas avaliáveis)', NULL, taxa('Mooca'));
  verificar('2.1g Taxa da cidade (NULL = todos)', '50',
            TO_CHAR(PKG_TRANSPARENCIA.FN_TAXA_RESPOSTA_NO_PRAZO(NULL)));
  BEGIN
    v_qtd := PKG_TRANSPARENCIA.FN_TAXA_RESPOSTA_NO_PRAZO(-1);
    verificar('2.1h Taxa de bairro inexistente', '-20010', 'sem erro');
  EXCEPTION WHEN OTHERS THEN
    verificar('2.1h Taxa de bairro inexistente', '-20010', TO_CHAR(SQLCODE));
  END;

  -- 2.2 Classificação
  verificar('2.2a Classificar 85',   'BOM',       PKG_TRANSPARENCIA.FN_CLASSIFICAR_TAXA(85));
  verificar('2.2b Classificar 50',   'REGULAR',   PKG_TRANSPARENCIA.FN_CLASSIFICAR_TAXA(50));
  verificar('2.2c Classificar 10',   'CRÍTICO',   PKG_TRANSPARENCIA.FN_CLASSIFICAR_TAXA(10));
  verificar('2.2d Classificar NULL', 'SEM DADOS', PKG_TRANSPARENCIA.FN_CLASSIFICAR_TAXA(NULL));

  -- 2.3 Erros de PRC_REGISTRAR_RESPOSTA
  BEGIN
    PKG_TRANSPARENCIA.PRC_REGISTRAR_RESPOSTA(v_id_dem_bras, -1, 'ACEITA', 'x', TRUNC(SYSDATE) + 30);
    verificar('2.3a Gestor inexistente', '-20011', 'sem erro');
  EXCEPTION WHEN OTHERS THEN
    verificar('2.3a Gestor inexistente', '-20011', TO_CHAR(SQLCODE));
  END;
  BEGIN
    PKG_TRANSPARENCIA.PRC_REGISTRAR_RESPOSTA(v_id_dem_bras, v_cidadao, 'ACEITA', 'x', TRUNC(SYSDATE) + 30);
    verificar('2.3b CIDADAO tentando responder', '-20012', 'sem erro');
  EXCEPTION WHEN OTHERS THEN
    verificar('2.3b CIDADAO tentando responder', '-20012', TO_CHAR(SQLCODE));
  END;
  BEGIN
    PKG_TRANSPARENCIA.PRC_REGISTRAR_RESPOSTA(v_id_dem_bras, v_gestor, 'TALVEZ', 'x', NULL);
    verificar('2.3c Decisão inválida', '-20013', 'sem erro');
  EXCEPTION WHEN OTHERS THEN
    verificar('2.3c Decisão inválida', '-20013', TO_CHAR(SQLCODE));
  END;
  BEGIN
    PKG_TRANSPARENCIA.PRC_REGISTRAR_RESPOSTA(v_id_dem_bras, v_gestor, 'RECUSADA', '   ', NULL);
    verificar('2.3d Justificativa em branco', '-20014', 'sem erro');
  EXCEPTION WHEN OTHERS THEN
    verificar('2.3d Justificativa em branco', '-20014', TO_CHAR(SQLCODE));
  END;
  BEGIN
    PKG_TRANSPARENCIA.PRC_REGISTRAR_RESPOSTA(-1, v_gestor, 'RECUSADA', 'Sem orçamento.', NULL);
    verificar('2.3e Proposta inexistente', '-20015', 'sem erro');
  EXCEPTION WHEN OTHERS THEN
    verificar('2.3e Proposta inexistente', '-20015', TO_CHAR(SQLCODE));
  END;
  BEGIN
    PKG_TRANSPARENCIA.PRC_REGISTRAR_RESPOSTA(v_id_aberta, v_gestor, 'RECUSADA', 'Sem orçamento.', NULL);
    verificar('2.3f Responder proposta ABERTA', '-20016', 'sem erro');
  EXCEPTION WHEN OTHERS THEN
    verificar('2.3f Responder proposta ABERTA', '-20016', TO_CHAR(SQLCODE));
  END;
  BEGIN
    PKG_TRANSPARENCIA.PRC_REGISTRAR_RESPOSTA(v_id_dem_bras, v_gestor, 'ACEITA', 'Vamos executar.', TRUNC(SYSDATE) - 1);
    verificar('2.3g ACEITA com prazo no passado', '-20017', 'sem erro');
  EXCEPTION WHEN OTHERS THEN
    verificar('2.3g ACEITA com prazo no passado', '-20017', TO_CHAR(SQLCODE));
  END;
  -- resposta já existente com status ainda DEMANDA (dado inconsistente simulado;
  -- desfeito logo em seguida para não afetar as taxas dos próximos casos)
  SAVEPOINT sp_resp_inconsistente;
  INSERT INTO VB_RESPOSTA (PROPOSTA_ID, GESTOR_ID, DECISAO, JUSTIFICATIVA)
  VALUES (v_id_dem_ceu, v_gestor, 'RECUSADA', 'Resposta inserida direto para simular inconsistência.');
  BEGIN
    PKG_TRANSPARENCIA.PRC_REGISTRAR_RESPOSTA(v_id_dem_ceu, v_gestor, 'RECUSADA', 'Outra resposta.', NULL);
    verificar('2.3h Proposta que já possui resposta', '-20018', 'sem erro');
  EXCEPTION WHEN OTHERS THEN
    verificar('2.3h Proposta que já possui resposta', '-20018', TO_CHAR(SQLCODE));
  END;
  ROLLBACK TO sp_resp_inconsistente;

  -- 2.4 Sucesso: ACEITA dentro do prazo (DEMANDA -> EM_EXECUCAO)
  SELECT COUNT(*) INTO v_notif_antes FROM VB_NOTIFICACAO WHERE PROPOSTA_ID = v_id_dem_bras;
  PKG_TRANSPARENCIA.PRC_REGISTRAR_RESPOSTA(v_id_dem_bras, v_gestor, 'aceita',
      'Troca das luminárias incluída na ordem de serviço da Ilume.', TRUNC(SYSDATE) + 30);
  SELECT p.STATUS, r.DECISAO INTO v_status, v_decisao
    FROM VB_PROPOSTA p JOIN VB_RESPOSTA r ON r.PROPOSTA_ID = p.ID
   WHERE p.ID = v_id_dem_bras;
  verificar('2.4a Status após ACEITA', 'EM_EXECUCAO', v_status);
  verificar('2.4b Decisão gravada (normalizada)', 'ACEITA', v_decisao);
  SELECT COUNT(*) INTO v_qtd FROM VB_NOTIFICACAO WHERE PROPOSTA_ID = v_id_dem_bras;
  verificar('2.4c Notificação ao autor', TO_CHAR(v_notif_antes + 1), TO_CHAR(v_qtd));
  -- Brasilândia: antes 0/1 (0%); agora 1 no prazo de 2 avaliáveis -> 50%
  verificar('2.4d Nova taxa Brasilândia', '50', taxa('Brasilândia'));

  -- 2.5 Sucesso: RECUSADA de demanda ATRASADA (resposta fora do prazo)
  PKG_TRANSPARENCIA.PRC_REGISTRAR_RESPOSTA(v_id_atrasada, v_gestor, 'RECUSADA',
      'A UBS não tem equipe para o sábado; será aberto mutirão mensal de vacinação.');
  SELECT STATUS INTO v_status FROM VB_PROPOSTA WHERE ID = v_id_atrasada;
  verificar('2.5a Status após RECUSADA', 'RECUSADA', v_status);
  -- Capão: avaliáveis continuam 2 (UBS já contava como vencida), no prazo 1 -> 50%
  verificar('2.5b Taxa Capão Redondo inalterada', '50', taxa('Capão Redondo'));

  -- 2.6 Relatório de bairro inexistente
  BEGIN
    PKG_TRANSPARENCIA.PRC_RELATORIO_BAIRRO(-1);
    verificar('2.6 Relatório de bairro inexistente', '-20010', 'sem erro');
  EXCEPTION WHEN OTHERS THEN
    verificar('2.6 Relatório de bairro inexistente', '-20010', TO_CHAR(SQLCODE));
  END;

  ROLLBACK TO sp_teste_transparencia;
  DBMS_OUTPUT.PUT_LINE('RESULTADO TESTE 2: ' || v_ok || ' OK, ' || v_falhas || ' falha(s). (alterações desfeitas)');
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO sp_teste_transparencia;
    DBMS_OUTPUT.PUT_LINE('ERRO INESPERADO NO TESTE 2: ' || SQLERRM);
    RAISE;
END;
/

-- Relatório (somente leitura) - placar do Capão Redondo e da Brasilândia
DECLARE
  v_id NUMBER;
BEGIN
  SELECT ID INTO v_id FROM VB_BAIRRO WHERE NOME = 'Capão Redondo';
  PKG_TRANSPARENCIA.PRC_RELATORIO_BAIRRO(v_id);
  SELECT ID INTO v_id FROM VB_BAIRRO WHERE NOME = 'Brasilândia';
  PKG_TRANSPARENCIA.PRC_RELATORIO_BAIRRO(v_id);
END;
/

-- =====================================================================
-- TESTE 3 - TRG_VB_PROPOSTA_STATUS (máquina de estados)
-- =====================================================================
DECLARE
  v_ok      PLS_INTEGER := 0;
  v_falhas  PLS_INTEGER := 0;

  v_id_aberta    NUMBER;
  v_id_aberta2   NUMBER;
  v_id_aberta3   NUMBER;
  v_id_concluida NUMBER;
  v_id_recusada  NUMBER;
  v_id_atrasada  NUMBER;
  v_status       VB_PROPOSTA.STATUS%TYPE;
  v_virou        VB_PROPOSTA.DT_VIROU_DEMANDA%TYPE;
  v_dias         NUMBER;
  v_ts           TIMESTAMP;

  PROCEDURE verificar(p_caso IN VARCHAR2, p_esperado IN VARCHAR2, p_obtido IN VARCHAR2) IS
  BEGIN
    IF p_esperado = p_obtido OR (p_esperado IS NULL AND p_obtido IS NULL) THEN
      v_ok := v_ok + 1;
      DBMS_OUTPUT.PUT_LINE('[OK]     ' || p_caso || ' | esperado=' || NVL(p_esperado, 'NULL')
                           || ' | obtido=' || NVL(p_obtido, 'NULL'));
    ELSE
      v_falhas := v_falhas + 1;
      DBMS_OUTPUT.PUT_LINE('[FALHOU] ' || p_caso || ' | esperado=' || NVL(p_esperado, 'NULL')
                           || ' | obtido=' || NVL(p_obtido, 'NULL'));
    END IF;
  END verificar;
BEGIN
  DBMS_OUTPUT.PUT_LINE('========== TESTE 3 - TRG_VB_PROPOSTA_STATUS ==========');
  SAVEPOINT sp_teste_trigger_status;

  SELECT ID INTO v_id_aberta    FROM VB_PROPOSTA WHERE TITULO = 'Iluminação na Rua Agnaldo Macedo';
  SELECT ID INTO v_id_aberta2   FROM VB_PROPOSTA WHERE TITULO = 'Faixa de pedestre em frente à EMEF';
  SELECT ID INTO v_id_aberta3   FROM VB_PROPOSTA WHERE TITULO = 'Coleta seletiva semanal na Brasilândia';
  SELECT ID INTO v_id_concluida FROM VB_PROPOSTA WHERE TITULO = 'Reabertura da biblioteca comunitária de Itaquera';
  SELECT ID INTO v_id_recusada  FROM VB_PROPOSTA WHERE TITULO = 'Ciclofaixa na Rua Sena Madureira';
  SELECT ID INTO v_id_atrasada  FROM VB_PROPOSTA WHERE TITULO = 'Cobertura nos pontos de ônibus da Av. Jacu-Pêssego';

  -- 3.1 Transições inválidas -> ORA-20020
  BEGIN
    UPDATE VB_PROPOSTA SET STATUS = 'CONCLUIDA' WHERE ID = v_id_aberta;
    verificar('3.1a ABERTA -> CONCLUIDA', '-20020', 'sem erro');
  EXCEPTION WHEN OTHERS THEN
    verificar('3.1a ABERTA -> CONCLUIDA', '-20020', TO_CHAR(SQLCODE));
  END;
  BEGIN
    UPDATE VB_PROPOSTA SET STATUS = 'ABERTA' WHERE ID = v_id_concluida;
    verificar('3.1b CONCLUIDA -> ABERTA', '-20020', 'sem erro');
  EXCEPTION WHEN OTHERS THEN
    verificar('3.1b CONCLUIDA -> ABERTA', '-20020', TO_CHAR(SQLCODE));
  END;
  BEGIN
    UPDATE VB_PROPOSTA SET STATUS = 'EM_EXECUCAO' WHERE ID = v_id_recusada;
    verificar('3.1c RECUSADA -> EM_EXECUCAO', '-20020', 'sem erro');
  EXCEPTION WHEN OTHERS THEN
    verificar('3.1c RECUSADA -> EM_EXECUCAO', '-20020', TO_CHAR(SQLCODE));
  END;
  BEGIN
    UPDATE VB_PROPOSTA SET STATUS = 'DEMANDA' WHERE ID = v_id_atrasada;
    verificar('3.1d ATRASADA -> DEMANDA', '-20020', 'sem erro');
  EXCEPTION WHEN OTHERS THEN
    verificar('3.1d ATRASADA -> DEMANDA', '-20020', TO_CHAR(SQLCODE));
  END;

  -- 3.2 Regravar o mesmo status (ORM atualizando todas as colunas) é permitido
  UPDATE VB_PROPOSTA SET STATUS = STATUS, TITULO = TITULO WHERE ID = v_id_aberta;
  verificar('3.2 ABERTA -> ABERTA (mesmo status)', '1', TO_CHAR(SQL%ROWCOUNT));

  -- 3.3 ABERTA -> DEMANDA sem datas: o trigger preenche DT_VIROU_DEMANDA e PRAZO (+15)
  UPDATE VB_PROPOSTA SET STATUS = 'DEMANDA' WHERE ID = v_id_aberta2;
  SELECT STATUS, DT_VIROU_DEMANDA, EXTRACT(DAY FROM (PRAZO_RESPOSTA - DT_VIROU_DEMANDA))
    INTO v_status, v_virou, v_dias
    FROM VB_PROPOSTA WHERE ID = v_id_aberta2;
  verificar('3.3a Status', 'DEMANDA', v_status);
  verificar('3.3b DT_VIROU_DEMANDA preenchida', 'S', CASE WHEN v_virou IS NOT NULL THEN 'S' ELSE 'N' END);
  verificar('3.3c PRAZO_RESPOSTA = virou + 15 dias', '15', TO_CHAR(v_dias));

  -- 3.4 ABERTA -> DEMANDA com datas enviadas (como a API .NET): o trigger não sobrescreve
  v_ts := CAST(SYSTIMESTAMP AS TIMESTAMP) - NUMTODSINTERVAL(1, 'HOUR');
  UPDATE VB_PROPOSTA
     SET STATUS = 'DEMANDA', DT_VIROU_DEMANDA = v_ts, PRAZO_RESPOSTA = v_ts + NUMTODSINTERVAL(20, 'DAY')
   WHERE ID = v_id_aberta3;
  SELECT EXTRACT(DAY FROM (PRAZO_RESPOSTA - DT_VIROU_DEMANDA)) INTO v_dias
    FROM VB_PROPOSTA WHERE ID = v_id_aberta3;
  verificar('3.4 Datas enviadas pela API preservadas (20 dias)', '20', TO_CHAR(v_dias));

  -- 3.5 Fluxo válido do Java: DEMANDA -> ATRASADA, ATRASADA -> EM_EXECUCAO -> CONCLUIDA
  UPDATE VB_PROPOSTA SET STATUS = 'ATRASADA' WHERE ID = v_id_aberta2;
  SELECT STATUS INTO v_status FROM VB_PROPOSTA WHERE ID = v_id_aberta2;
  verificar('3.5a DEMANDA -> ATRASADA', 'ATRASADA', v_status);
  UPDATE VB_PROPOSTA SET STATUS = 'EM_EXECUCAO' WHERE ID = v_id_atrasada;
  UPDATE VB_PROPOSTA SET STATUS = 'CONCLUIDA'   WHERE ID = v_id_atrasada;
  SELECT STATUS INTO v_status FROM VB_PROPOSTA WHERE ID = v_id_atrasada;
  verificar('3.5b ATRASADA -> EM_EXECUCAO -> CONCLUIDA', 'CONCLUIDA', v_status);

  ROLLBACK TO sp_teste_trigger_status;
  DBMS_OUTPUT.PUT_LINE('RESULTADO TESTE 3: ' || v_ok || ' OK, ' || v_falhas || ' falha(s). (alterações desfeitas)');
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO sp_teste_trigger_status;
    DBMS_OUTPUT.PUT_LINE('ERRO INESPERADO NO TESTE 3: ' || SQLERRM);
    RAISE;
END;
/

-- =====================================================================
-- TESTE 4 - TRG_VB_APOIO_AUDITORIA (trilha de auditoria)
-- DML "solto" para que a consulta à VB_AUDITORIA_APOIO apareça como grade
-- de resultado (evidência/print). Tudo é desfeito no ROLLBACK TO do final.
-- =====================================================================
SAVEPOINT sp_teste_auditoria;

-- Thiago (Mooca) apoia a proposta "Iluminação na Rua Agnaldo Macedo"
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID)
VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Iluminação na Rua Agnaldo Macedo'),
        (SELECT ID FROM VB_USUARIO  WHERE EMAIL  = 'thiago.alves@vozdobairro.com'));

-- Correção da data do apoio (UPDATE)
UPDATE VB_APOIO
   SET DT_APOIO = DT_APOIO - NUMTODSINTERVAL(1, 'HOUR')
 WHERE PROPOSTA_ID = (SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Iluminação na Rua Agnaldo Macedo')
   AND USUARIO_ID  = (SELECT ID FROM VB_USUARIO  WHERE EMAIL  = 'thiago.alves@vozdobairro.com');

-- Remoção do apoio (DELETE)
DELETE FROM VB_APOIO
 WHERE PROPOSTA_ID = (SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Iluminação na Rua Agnaldo Macedo')
   AND USUARIO_ID  = (SELECT ID FROM VB_USUARIO  WHERE EMAIL  = 'thiago.alves@vozdobairro.com');

-- EVIDÊNCIA: 3 linhas (INSERT, UPDATE, DELETE) com valores antigos/novos, data e usuário do banco
SELECT ID, OPERACAO, APOIO_ID, PROPOSTA_ID, USUARIO_ID,
       VALORES_ANTIGOS, VALORES_NOVOS,
       TO_CHAR(DT_OPERACAO, 'DD/MM/YYYY HH24:MI:SS') AS DT_OPERACAO, USUARIO_BD
  FROM VB_AUDITORIA_APOIO
 WHERE USUARIO_ID = (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'thiago.alves@vozdobairro.com')
 ORDER BY ID;

DECLARE
  v_ok      PLS_INTEGER := 0;
  v_falhas  PLS_INTEGER := 0;
  v_thiago  NUMBER;
  v_ops     VARCHAR2(100);
  v_ins_ant NUMBER;
  v_del_nov NUMBER;
  v_upd_ok  NUMBER;

  PROCEDURE verificar(p_caso IN VARCHAR2, p_esperado IN VARCHAR2, p_obtido IN VARCHAR2) IS
  BEGIN
    IF p_esperado = p_obtido OR (p_esperado IS NULL AND p_obtido IS NULL) THEN
      v_ok := v_ok + 1;
      DBMS_OUTPUT.PUT_LINE('[OK]     ' || p_caso || ' | esperado=' || NVL(p_esperado, 'NULL')
                           || ' | obtido=' || NVL(p_obtido, 'NULL'));
    ELSE
      v_falhas := v_falhas + 1;
      DBMS_OUTPUT.PUT_LINE('[FALHOU] ' || p_caso || ' | esperado=' || NVL(p_esperado, 'NULL')
                           || ' | obtido=' || NVL(p_obtido, 'NULL'));
    END IF;
  END verificar;
BEGIN
  DBMS_OUTPUT.PUT_LINE('========== TESTE 4 - TRG_VB_APOIO_AUDITORIA ==========');
  SELECT ID INTO v_thiago FROM VB_USUARIO WHERE EMAIL = 'thiago.alves@vozdobairro.com';

  -- Sequência de operações registradas
  v_ops := NULL;
  FOR r IN (SELECT OPERACAO FROM VB_AUDITORIA_APOIO WHERE USUARIO_ID = v_thiago ORDER BY ID) LOOP
    v_ops := v_ops || CASE WHEN v_ops IS NOT NULL THEN ',' END || r.OPERACAO;
  END LOOP;
  verificar('4.1 Operações auditadas', 'INSERT,UPDATE,DELETE', v_ops);

  SELECT COUNT(*) INTO v_ins_ant FROM VB_AUDITORIA_APOIO
   WHERE USUARIO_ID = v_thiago AND OPERACAO = 'INSERT'
     AND VALORES_ANTIGOS IS NULL AND VALORES_NOVOS LIKE '{"id":%';
  verificar('4.2 INSERT: só valores novos', '1', TO_CHAR(v_ins_ant));

  SELECT COUNT(*) INTO v_upd_ok FROM VB_AUDITORIA_APOIO
   WHERE USUARIO_ID = v_thiago AND OPERACAO = 'UPDATE'
     AND VALORES_ANTIGOS IS NOT NULL AND VALORES_NOVOS IS NOT NULL
     AND VALORES_ANTIGOS <> VALORES_NOVOS;
  verificar('4.3 UPDATE: antigo e novo diferentes', '1', TO_CHAR(v_upd_ok));

  SELECT COUNT(*) INTO v_del_nov FROM VB_AUDITORIA_APOIO
   WHERE USUARIO_ID = v_thiago AND OPERACAO = 'DELETE'
     AND VALORES_NOVOS IS NULL AND VALORES_ANTIGOS IS NOT NULL
     AND USUARIO_BD = SYS_CONTEXT('USERENV', 'SESSION_USER');
  verificar('4.4 DELETE: só valores antigos + usuário do banco', '1', TO_CHAR(v_del_nov));

  DBMS_OUTPUT.PUT_LINE('RESULTADO TESTE 4: ' || v_ok || ' OK, ' || v_falhas || ' falha(s).');
END;
/

ROLLBACK TO sp_teste_auditoria;

-- Conferência final: nada ficou sujo (esperado: 0 linhas de auditoria do Thiago,
-- 18 propostas, 133 apoios)
SELECT (SELECT COUNT(*) FROM VB_AUDITORIA_APOIO a
         WHERE a.USUARIO_ID = (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'thiago.alves@vozdobairro.com')) AS AUDITORIA_THIAGO,
       (SELECT COUNT(*) FROM VB_PROPOSTA) AS PROPOSTAS,
       (SELECT COUNT(*) FROM VB_APOIO)    AS APOIOS
  FROM DUAL;
