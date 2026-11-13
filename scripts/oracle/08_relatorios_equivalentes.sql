-- =====================================================================
-- VOZ DO BAIRRO - 08_relatorios_equivalentes.sql
-- Consultas SQL equivalentes às consultas MongoDB de scripts/mongodb/02_consultas.js.
-- Mesmo número (R1..R6) nos dois arquivos para comparar os resultados lado a lado.
-- Resultados esperados (dados da carga) estão no README, seção 7.
-- =====================================================================
SET DEFINE OFF
SET SQLBLANKLINES ON
SET SERVEROUTPUT ON SIZE UNLIMITED

-- ---------------------------------------------------------------------
-- R1 - Propostas ABERTAS do Capão Redondo ordenadas por apoios (find + sort)
--      Mongo: db.propostas.find({ "bairro.nome": "Capão Redondo", status: "ABERTA" }, {...})
--                         .sort({ totalApoios: -1, oracleId: 1 })
-- ---------------------------------------------------------------------
SELECT p.ID           AS ORACLE_ID,
       p.TITULO,
       p.CATEGORIA,
       p.TOTAL_APOIOS,
       p.META_APOIOS,
       u.NOME         AS AUTOR
  FROM VB_PROPOSTA p
  JOIN VB_BAIRRO  b ON b.ID = p.BAIRRO_ID
  JOIN VB_USUARIO u ON u.ID = p.AUTOR_ID
 WHERE b.NOME = 'Capão Redondo'
   AND p.STATUS = 'ABERTA'
 ORDER BY p.TOTAL_APOIOS DESC, p.ID;

-- ---------------------------------------------------------------------
-- R2 - Demandas ATRASADAS (find com projeção)
--      Mongo: db.propostas.find({ status: "ATRASADA" },
--               { _id: 0, oracleId: 1, titulo: 1, "bairro.nome": 1, prazoResposta: 1, totalApoios: 1 })
--             .sort({ prazoResposta: 1 })
-- ---------------------------------------------------------------------
SELECT p.ID                                              AS ORACLE_ID,
       p.TITULO,
       b.NOME                                            AS BAIRRO,
       TO_CHAR(p.PRAZO_RESPOSTA, 'DD/MM/YYYY HH24:MI')   AS PRAZO_RESPOSTA,
       TRUNC(SYSDATE - CAST(p.PRAZO_RESPOSTA AS DATE))   AS DIAS_DE_ATRASO,
       p.TOTAL_APOIOS
  FROM VB_PROPOSTA p
  JOIN VB_BAIRRO b ON b.ID = p.BAIRRO_ID
 WHERE p.STATUS = 'ATRASADA'
 ORDER BY p.PRAZO_RESPOSTA;

-- ---------------------------------------------------------------------
-- R3 - Placar por bairro: quantidade de propostas por status + apoios (aggregate $group + $lookup)
-- ---------------------------------------------------------------------
SELECT b.ID                                                   AS BAIRRO_ID,
       b.NOME                                                 AS BAIRRO,
       b.SUBPREFEITURA,
       COUNT(p.ID)                                            AS TOTAL,
       SUM(CASE WHEN p.STATUS = 'ABERTA'      THEN 1 ELSE 0 END) AS ABERTA,
       SUM(CASE WHEN p.STATUS = 'DEMANDA'     THEN 1 ELSE 0 END) AS DEMANDA,
       SUM(CASE WHEN p.STATUS = 'ATRASADA'    THEN 1 ELSE 0 END) AS ATRASADA,
       SUM(CASE WHEN p.STATUS = 'EM_EXECUCAO' THEN 1 ELSE 0 END) AS EM_EXECUCAO,
       SUM(CASE WHEN p.STATUS = 'RECUSADA'    THEN 1 ELSE 0 END) AS RECUSADA,
       SUM(CASE WHEN p.STATUS = 'CONCLUIDA'   THEN 1 ELSE 0 END) AS CONCLUIDA,
       NVL(SUM(p.TOTAL_APOIOS), 0)                            AS TOTAL_APOIOS
  FROM VB_BAIRRO b
  LEFT JOIN VB_PROPOSTA p ON p.BAIRRO_ID = b.ID
 GROUP BY b.ID, b.NOME, b.SUBPREFEITURA
 ORDER BY b.ID;

-- ---------------------------------------------------------------------
-- R4 - Top categorias por total de apoios (aggregate $group + $sort)
--      APOIOS_REGISTRADOS conta as linhas de VB_APOIO (no Mongo: $size do array apoios)
-- ---------------------------------------------------------------------
SELECT p.CATEGORIA,
       COUNT(*)                       AS PROPOSTAS,
       SUM(p.TOTAL_APOIOS)            AS TOTAL_APOIOS,
       SUM(NVL(a.QTD, 0))             AS APOIOS_REGISTRADOS
  FROM VB_PROPOSTA p
  LEFT JOIN (SELECT PROPOSTA_ID, COUNT(*) AS QTD
               FROM VB_APOIO
              GROUP BY PROPOSTA_ID) a ON a.PROPOSTA_ID = p.ID
 GROUP BY p.CATEGORIA
 ORDER BY SUM(p.TOTAL_APOIOS) DESC, p.CATEGORIA;

-- ---------------------------------------------------------------------
-- R5 - Taxa de resposta no prazo por bairro (aggregate com $lookup/pipeline)
--      Coluna TAXA_FUNCAO usa a função PL/SQL; TAXA_SQL recalcula em SQL puro.
-- ---------------------------------------------------------------------
SELECT b.ID   AS BAIRRO_ID,
       b.NOME AS BAIRRO,
       (SELECT COUNT(*)
          FROM VB_PROPOSTA p LEFT JOIN VB_RESPOSTA r ON r.PROPOSTA_ID = p.ID
         WHERE p.BAIRRO_ID = b.ID AND p.DT_VIROU_DEMANDA IS NOT NULL
           AND (r.ID IS NOT NULL OR p.PRAZO_RESPOSTA < SYSTIMESTAMP))          AS AVALIAVEIS,
       (SELECT COUNT(*)
          FROM VB_PROPOSTA p JOIN VB_RESPOSTA r ON r.PROPOSTA_ID = p.ID
         WHERE p.BAIRRO_ID = b.ID AND r.DT_RESPOSTA <= p.PRAZO_RESPOSTA)      AS NO_PRAZO,
       PKG_TRANSPARENCIA.FN_TAXA_RESPOSTA_NO_PRAZO(b.ID)                      AS TAXA_FUNCAO,
       PKG_TRANSPARENCIA.FN_CLASSIFICAR_TAXA(
         PKG_TRANSPARENCIA.FN_TAXA_RESPOSTA_NO_PRAZO(b.ID))                  AS CLASSIFICACAO
  FROM VB_BAIRRO b
 ORDER BY b.ID;

-- ---------------------------------------------------------------------
-- R6 - Conferência de correspondência registro <-> documento
--      (no Mongo: totalApoios x $size(apoios) e contagens por collection)
-- ---------------------------------------------------------------------
SELECT p.ID AS ORACLE_ID, p.STATUS, p.TOTAL_APOIOS,
       (SELECT COUNT(*) FROM VB_APOIO a      WHERE a.PROPOSTA_ID = p.ID) AS QTD_APOIOS,
       (SELECT COUNT(*) FROM VB_COMENTARIO c WHERE c.PROPOSTA_ID = p.ID) AS QTD_COMENTARIOS,
       (SELECT COUNT(*) FROM VB_RESPOSTA r   WHERE r.PROPOSTA_ID = p.ID) AS TEM_RESPOSTA
  FROM VB_PROPOSTA p
 ORDER BY p.ID;
