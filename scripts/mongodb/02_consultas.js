// =====================================================================
// VOZ DO BAIRRO - MongoDB - 02_consultas.js (mongosh)
// Consultas/relatórios equivalentes às do scripts/oracle/08_relatorios_equivalentes.sql
// (mesma numeração R1..R6). Rodar depois do 01_carga.js:
//     mongosh "<sua-connection-string>" --file 02_consultas.js
// No Compass: aba _MONGOSH (colar o bloco de cada consulta) ou Aggregations
// (colar só o array do pipeline).
// =====================================================================
use("vozdobairro");

function titulo(t) { print("\n==================== " + t + " ===================="); }

// ---------------------------------------------------------------------
// R1 - find: propostas ABERTAS do Capão Redondo ordenadas por apoios
// SQL equivalente:
//   SELECT p.ID, p.TITULO, p.CATEGORIA, p.TOTAL_APOIOS, p.META_APOIOS, u.NOME AS AUTOR
//     FROM VB_PROPOSTA p JOIN VB_BAIRRO b ON b.ID = p.BAIRRO_ID
//                        JOIN VB_USUARIO u ON u.ID = p.AUTOR_ID
//    WHERE b.NOME = 'Capão Redondo' AND p.STATUS = 'ABERTA'
//    ORDER BY p.TOTAL_APOIOS DESC, p.ID;
// No Mongo não há JOIN: o nome do bairro e do autor estão embutidos no documento.
// ---------------------------------------------------------------------
titulo("R1 - Abertas do Capão Redondo por apoios");
db.propostas.find(
  { "bairro.nome": "Capão Redondo", status: "ABERTA" },
  { _id: 0, oracleId: 1, titulo: 1, categoria: 1, totalApoios: 1, metaApoios: 1, "autor.nome": 1 }
).sort({ totalApoios: -1, oracleId: 1 }).forEach(d => printjson(d));

// ---------------------------------------------------------------------
// R2 - find com projeção: demandas ATRASADAS
// SQL equivalente:
//   SELECT p.ID, p.TITULO, b.NOME AS BAIRRO, p.PRAZO_RESPOSTA, p.TOTAL_APOIOS
//     FROM VB_PROPOSTA p JOIN VB_BAIRRO b ON b.ID = p.BAIRRO_ID
//    WHERE p.STATUS = 'ATRASADA'
//    ORDER BY p.PRAZO_RESPOSTA;
// ---------------------------------------------------------------------
titulo("R2 - Demandas atrasadas");
db.propostas.find(
  { status: "ATRASADA" },
  { _id: 0, oracleId: 1, titulo: 1, "bairro.nome": 1, prazoResposta: 1, totalApoios: 1 }
).sort({ prazoResposta: 1 }).forEach(d => printjson(d));

// ---------------------------------------------------------------------
// R3 - aggregate: placar por bairro (contagem por status + apoios) com $lookup
// SQL equivalente:
//   SELECT b.ID, b.NOME, b.SUBPREFEITURA, COUNT(p.ID) AS TOTAL,
//          SUM(CASE WHEN p.STATUS = 'ABERTA' THEN 1 ELSE 0 END) AS ABERTA, ... ,
//          NVL(SUM(p.TOTAL_APOIOS), 0) AS TOTAL_APOIOS
//     FROM VB_BAIRRO b LEFT JOIN VB_PROPOSTA p ON p.BAIRRO_ID = b.ID
//    GROUP BY b.ID, b.NOME, b.SUBPREFEITURA ORDER BY b.ID;
// ---------------------------------------------------------------------
titulo("R3 - Placar por bairro");
function contaStatus(s) { return { $sum: { $cond: [{ $eq: ["$status", s] }, 1, 0] } }; }
db.propostas.aggregate([
  { $group: {
      _id: "$bairro.bairroId",
      bairro: { $first: "$bairro.nome" },
      total: { $sum: 1 },
      ABERTA: contaStatus("ABERTA"),
      DEMANDA: contaStatus("DEMANDA"),
      ATRASADA: contaStatus("ATRASADA"),
      EM_EXECUCAO: contaStatus("EM_EXECUCAO"),
      RECUSADA: contaStatus("RECUSADA"),
      CONCLUIDA: contaStatus("CONCLUIDA"),
      totalApoios: { $sum: "$totalApoios" }
  } },
  { $lookup: { from: "bairros", localField: "_id", foreignField: "oracleId", as: "b" } },
  { $unwind: "$b" },
  { $project: {
      _id: 0, bairroId: "$_id", bairro: 1, subprefeitura: "$b.subprefeitura", total: 1,
      ABERTA: 1, DEMANDA: 1, ATRASADA: 1, EM_EXECUCAO: 1, RECUSADA: 1, CONCLUIDA: 1, totalApoios: 1
  } },
  { $sort: { bairroId: 1 } }
]).forEach(d => printjson(d));

// ---------------------------------------------------------------------
// R4 - aggregate: top categorias por total de apoios
// SQL equivalente:
//   SELECT p.CATEGORIA, COUNT(*) AS PROPOSTAS, SUM(p.TOTAL_APOIOS) AS TOTAL_APOIOS,
//          SUM(NVL(a.QTD, 0)) AS APOIOS_REGISTRADOS
//     FROM VB_PROPOSTA p
//     LEFT JOIN (SELECT PROPOSTA_ID, COUNT(*) QTD FROM VB_APOIO GROUP BY PROPOSTA_ID) a
//       ON a.PROPOSTA_ID = p.ID
//    GROUP BY p.CATEGORIA ORDER BY SUM(p.TOTAL_APOIOS) DESC, p.CATEGORIA;
// apoiosRegistrados = soma do tamanho do array embutido (equivale a contar VB_APOIO).
// ---------------------------------------------------------------------
titulo("R4 - Top categorias por apoios");
db.propostas.aggregate([
  { $group: {
      _id: "$categoria",
      propostas: { $sum: 1 },
      totalApoios: { $sum: "$totalApoios" },
      apoiosRegistrados: { $sum: { $size: "$apoios" } }
  } },
  { $sort: { totalApoios: -1, _id: 1 } },
  { $project: { _id: 0, categoria: "$_id", propostas: 1, totalApoios: 1, apoiosRegistrados: 1 } }
]).forEach(d => printjson(d));

// ---------------------------------------------------------------------
// R5 - aggregate: taxa de resposta no prazo por bairro
// Mesma regra de PKG_TRANSPARENCIA.FN_TAXA_RESPOSTA_NO_PRAZO:
//   avaliáveis = viraram DEMANDA e (têm resposta OU prazo vencido)
//   no prazo   = resposta.dtResposta <= prazoResposta
// SQL equivalente:
//   SELECT b.ID, b.NOME, PKG_TRANSPARENCIA.FN_TAXA_RESPOSTA_NO_PRAZO(b.ID) AS TAXA
//     FROM VB_BAIRRO b ORDER BY b.ID;
// Parte de "bairros" para que bairros sem demandas avaliáveis apareçam com taxa null
// (igual ao NULL devolvido pela função no Oracle).
// ---------------------------------------------------------------------
titulo("R5 - Taxa de resposta no prazo por bairro");
const agora = new Date();
db.bairros.aggregate([
  { $lookup: {
      from: "propostas",
      let: { bid: "$oracleId" },
      pipeline: [
        { $match: {
            $expr: { $eq: ["$bairro.bairroId", "$$bid"] },
            dtVirouDemanda: { $exists: true },
            $or: [{ resposta: { $exists: true } }, { prazoResposta: { $lt: agora } }]
        } },
        { $project: {
            _id: 0,
            noPrazo: { $cond: [
              { $and: [
                { $ne: [{ $type: "$resposta" }, "missing"] },
                { $lte: ["$resposta.dtResposta", "$prazoResposta"] }
              ] }, 1, 0] }
        } }
      ],
      as: "avaliaveis"
  } },
  { $project: {
      _id: 0, bairroId: "$oracleId", bairro: "$nome",
      avaliaveis: { $size: "$avaliaveis" },
      noPrazo: { $sum: "$avaliaveis.noPrazo" },
      taxa: { $cond: [
        { $eq: [{ $size: "$avaliaveis" }, 0] },
        null,
        { $round: [{ $multiply: [{ $divide: [{ $sum: "$avaliaveis.noPrazo" }, { $size: "$avaliaveis" }] }, 100] }, 2] }
      ] },
      snapshotCarga: "$estatisticas.taxaRespostaNoPrazo"
  } },
  { $sort: { bairroId: 1 } }
]).forEach(d => printjson(d));

// ---------------------------------------------------------------------
// R6 - Conferência de correspondência (Oracle x Mongo)
// SQL equivalente (esperado: nenhuma linha):
//   SELECT p.ID FROM VB_PROPOSTA p LEFT JOIN VB_APOIO a ON a.PROPOSTA_ID = p.ID
//    GROUP BY p.ID, p.TOTAL_APOIOS HAVING p.TOTAL_APOIOS <> COUNT(a.ID);
// ---------------------------------------------------------------------
titulo("R6 - Conferência totalApoios x apoios embutidos (esperado: lista vazia)");
const divergentes = db.propostas.aggregate([
  { $project: { _id: 0, oracleId: 1, totalApoios: 1, qtdApoios: { $size: "$apoios" } } },
  { $match: { $expr: { $ne: ["$totalApoios", "$qtdApoios"] } } }
]).toArray();
printjson(divergentes);

titulo("R6b - Totais por collection (comparar com 02_dados.sql)");
db.propostas.aggregate([
  { $group: {
      _id: null,
      propostas: { $sum: 1 },
      apoios: { $sum: { $size: "$apoios" } },
      comentarios: { $sum: { $size: "$comentarios" } },
      respostas: { $sum: { $cond: [{ $ne: [{ $type: "$resposta" }, "missing"] }, 1, 0] } }
  } },
  { $project: { _id: 0, propostas: 1, apoios: 1, comentarios: 1, respostas: 1 } }
]).forEach(d => printjson(d));
print("bairros: " + db.bairros.countDocuments());
