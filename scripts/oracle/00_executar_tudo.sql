-- =====================================================================
-- VOZ DO BAIRRO - 00_executar_tudo.sql
-- Executa todos os scripts Oracle na ordem correta.
--
-- SQL Developer: abra ESTE arquivo (File > Open) a partir da pasta
--   scripts/oracle e rode como script (F5 / "Run Script"). O "@@" procura os
--   demais arquivos na mesma pasta deste.
-- SQL*Plus / SQLcl: cd scripts/oracle  e  @00_executar_tudo.sql
--
-- ATENÇÃO: 01_ddl.sql APAGA e recria as tabelas VB_* (dados das APIs
-- Java/.NET no mesmo schema também são apagados).
-- =====================================================================
SET DEFINE OFF
SET SQLBLANKLINES ON
SET SERVEROUTPUT ON SIZE UNLIMITED
SET ECHO OFF
SET FEEDBACK ON

-- (opcional) gravar toda a saída em arquivo para as evidências:
-- SPOOL evidencias_oracle.log

PROMPT ===== 01 - DDL (tabelas do contrato + índices) =====
@@01_ddl.sql

PROMPT ===== 02 - Dados de teste =====
@@02_dados.sql

PROMPT ===== 03 - Pacote PKG_PROPOSTA =====
@@03_pkg_proposta.sql

PROMPT ===== 04 - Pacote PKG_TRANSPARENCIA =====
@@04_pkg_transparencia.sql

PROMPT ===== 05 - Gatilhos =====
@@05_triggers.sql

PROMPT ===== 06 - Blocos anônimos =====
@@06_blocos_anonimos.sql

PROMPT ===== 07 - Testes (com ROLLBACK, não alteram os dados) =====
@@07_testes.sql

PROMPT ===== 08 - Relatórios equivalentes ao MongoDB =====
@@08_relatorios_equivalentes.sql

PROMPT ===== Objetos criados (todos devem estar VALID) =====
SELECT OBJECT_TYPE, OBJECT_NAME, STATUS
  FROM USER_OBJECTS
 WHERE OBJECT_NAME IN ('PKG_PROPOSTA', 'PKG_TRANSPARENCIA',
                       'TRG_VB_APOIO_AUDITORIA', 'TRG_VB_PROPOSTA_STATUS')
 ORDER BY OBJECT_TYPE, OBJECT_NAME;

-- SPOOL OFF
