-- =====================================================================
-- VOZ DO BAIRRO - 06_blocos_anonimos.sql
-- Blocos PL/SQL anônimos com cursor, repetição e decisão.
--   Bloco 1: ranking de prioridade das propostas pendentes (cursor FOR + IF)
--   Bloco 2: varredura de bairros com taxa de resposta e classificação
--            BOM / REGULAR / CRÍTICO (cursor FOR + IF/ELSIF + contadores)
--   Bloco 3: auditoria de integridade TOTAL_APOIOS x VB_APOIO
--            (cursor explícito OPEN/FETCH/CLOSE + LOOP/EXIT WHEN)
-- Somente leitura: nenhum bloco altera dados.
-- =====================================================================
SET DEFINE OFF
SET SQLBLANKLINES ON
SET SERVEROUTPUT ON SIZE UNLIMITED

-- ---------------------------------------------------------------------
-- Bloco 1 - Ranking de prioridade (usa PKG_PROPOSTA.FN_CALCULAR_PRIORIDADE)
-- ---------------------------------------------------------------------
DECLARE
  CURSOR c_pendentes IS
    SELECT p.ID, p.TITULO, p.STATUS, p.CATEGORIA, p.TOTAL_APOIOS, p.META_APOIOS,
           b.NOME AS BAIRRO,
           PKG_PROPOSTA.FN_CALCULAR_PRIORIDADE(p.ID) AS PRIORIDADE
      FROM VB_PROPOSTA p
      JOIN VB_BAIRRO b ON b.ID = p.BAIRRO_ID
     WHERE p.STATUS IN ('ABERTA', 'DEMANDA', 'ATRASADA')
     ORDER BY PRIORIDADE DESC, p.ID;

  v_pos    PLS_INTEGER := 0;
  v_faixa  VARCHAR2(10);
  v_alta   PLS_INTEGER := 0;
  v_media  PLS_INTEGER := 0;
  v_baixa  PLS_INTEGER := 0;
BEGIN
  DBMS_OUTPUT.PUT_LINE('=== RANKING DE PRIORIDADE - PROPOSTAS PENDENTES ===');
  FOR r IN c_pendentes LOOP
    v_pos := v_pos + 1;

    IF r.PRIORIDADE >= 100 THEN
      v_faixa := 'ALTA';
      v_alta  := v_alta + 1;
    ELSIF r.PRIORIDADE >= 30 THEN
      v_faixa := 'MÉDIA';
      v_media := v_media + 1;
    ELSE
      v_faixa := 'BAIXA';
      v_baixa := v_baixa + 1;
    END IF;

    DBMS_OUTPUT.PUT_LINE(LPAD(v_pos, 2) || 'º  #' || RPAD(r.ID, 3) || ' '
                         || RPAD(TO_CHAR(r.PRIORIDADE, 'FM990D00'), 7) || ' ' || RPAD(v_faixa, 6)
                         || RPAD(r.STATUS, 9) || RPAD(r.CATEGORIA, 14)
                         || LPAD(r.TOTAL_APOIOS || '/' || r.META_APOIOS, 6) || '  '
                         || r.BAIRRO || ' - ' || r.TITULO);

    -- Alerta específico: categoria crítica já atrasada
    IF r.STATUS = 'ATRASADA' AND r.CATEGORIA IN ('SEGURANCA', 'SAUDE') THEN
      DBMS_OUTPUT.PUT_LINE('      ! ALERTA: demanda de ' || r.CATEGORIA || ' sem resposta após o prazo.');
    END IF;
  END LOOP;

  IF v_pos = 0 THEN
    DBMS_OUTPUT.PUT_LINE('Nenhuma proposta pendente.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Total: ' || v_pos || ' | ALTA: ' || v_alta || ' | MÉDIA: ' || v_media
                         || ' | BAIXA: ' || v_baixa);
  END IF;
END;
/

-- ---------------------------------------------------------------------
-- Bloco 2 - Varredura de bairros (usa PKG_TRANSPARENCIA.FN_TAXA_RESPOSTA_NO_PRAZO)
-- ---------------------------------------------------------------------
DECLARE
  CURSOR c_bairros IS
    SELECT b.ID, b.NOME, b.SUBPREFEITURA,
           (SELECT COUNT(*) FROM VB_PROPOSTA p
             WHERE p.BAIRRO_ID = b.ID AND p.STATUS IN ('DEMANDA', 'ATRASADA')) AS PENDENTES,
           (SELECT COUNT(*) FROM VB_PROPOSTA p
             WHERE p.BAIRRO_ID = b.ID AND p.STATUS = 'ATRASADA') AS ATRASADAS
      FROM VB_BAIRRO b
     ORDER BY b.ID;

  v_taxa          NUMBER;
  v_classificacao VARCHAR2(20);
  v_qtd_bom       PLS_INTEGER := 0;
  v_qtd_regular   PLS_INTEGER := 0;
  v_qtd_critico   PLS_INTEGER := 0;
  v_qtd_sem_dados PLS_INTEGER := 0;
BEGIN
  DBMS_OUTPUT.PUT_LINE('=== TRANSPARÊNCIA POR BAIRRO - RESPOSTA NO PRAZO ===');
  DBMS_OUTPUT.PUT_LINE(RPAD('BAIRRO', 16) || RPAD('SUBPREFEITURA', 24) || LPAD('TAXA', 8)
                       || '  ' || RPAD('CLASSIF.', 11) || 'PENDENTES (ATRASADAS)');

  FOR r IN c_bairros LOOP
    v_taxa := PKG_TRANSPARENCIA.FN_TAXA_RESPOSTA_NO_PRAZO(r.ID);

    IF v_taxa IS NULL THEN
      v_classificacao := 'SEM DADOS';
      v_qtd_sem_dados := v_qtd_sem_dados + 1;
    ELSIF v_taxa >= 80 THEN
      v_classificacao := 'BOM';
      v_qtd_bom := v_qtd_bom + 1;
    ELSIF v_taxa >= 50 THEN
      v_classificacao := 'REGULAR';
      v_qtd_regular := v_qtd_regular + 1;
    ELSE
      v_classificacao := 'CRÍTICO';
      v_qtd_critico := v_qtd_critico + 1;
    END IF;

    DBMS_OUTPUT.PUT_LINE(RPAD(r.NOME, 16) || RPAD(r.SUBPREFEITURA, 24)
                         || LPAD(NVL(TO_CHAR(v_taxa, 'FM990D00') || '%', '-'), 8) || '  '
                         || RPAD(v_classificacao, 11) || r.PENDENTES || ' (' || r.ATRASADAS || ')');
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('Cidade: ' || NVL(TO_CHAR(PKG_TRANSPARENCIA.FN_TAXA_RESPOSTA_NO_PRAZO(NULL), 'FM990D00'), '-')
                       || '% | BOM: ' || v_qtd_bom || ' | REGULAR: ' || v_qtd_regular
                       || ' | CRÍTICO: ' || v_qtd_critico || ' | SEM DADOS: ' || v_qtd_sem_dados);
END;
/

-- ---------------------------------------------------------------------
-- Bloco 3 - Integridade: TOTAL_APOIOS deve ser igual à contagem de VB_APOIO
-- ---------------------------------------------------------------------
DECLARE
  CURSOR c_conferencia IS
    SELECT p.ID, p.TITULO, p.TOTAL_APOIOS, COUNT(a.ID) AS APOIOS_REAIS
      FROM VB_PROPOSTA p
      LEFT JOIN VB_APOIO a ON a.PROPOSTA_ID = p.ID
     GROUP BY p.ID, p.TITULO, p.TOTAL_APOIOS
     ORDER BY p.ID;

  v_reg          c_conferencia%ROWTYPE;
  v_verificadas  PLS_INTEGER := 0;
  v_divergentes  PLS_INTEGER := 0;
BEGIN
  DBMS_OUTPUT.PUT_LINE('=== CONFERÊNCIA TOTAL_APOIOS x VB_APOIO ===');
  OPEN c_conferencia;
  LOOP
    FETCH c_conferencia INTO v_reg;
    EXIT WHEN c_conferencia%NOTFOUND;

    v_verificadas := v_verificadas + 1;
    IF v_reg.TOTAL_APOIOS <> v_reg.APOIOS_REAIS THEN
      v_divergentes := v_divergentes + 1;
      DBMS_OUTPUT.PUT_LINE('  DIVERGENTE #' || v_reg.ID || ' ' || v_reg.TITULO || ': TOTAL_APOIOS='
                           || v_reg.TOTAL_APOIOS || ', VB_APOIO=' || v_reg.APOIOS_REAIS);
    END IF;
  END LOOP;
  CLOSE c_conferencia;

  IF v_divergentes = 0 THEN
    DBMS_OUTPUT.PUT_LINE('OK: ' || v_verificadas || ' propostas verificadas, nenhuma divergência.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('ATENÇÃO: ' || v_divergentes || ' de ' || v_verificadas || ' propostas divergentes.');
  END IF;
END;
/
