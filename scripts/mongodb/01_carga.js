// =====================================================================
// VOZ DO BAIRRO - MongoDB - 01_carga.js (mongosh)
// Representação documental de parte do banco Oracle (VB_BAIRRO, VB_PROPOSTA,
// VB_USUARIO resumido, VB_APOIO, VB_COMENTARIO, VB_RESPOSTA).
// Mesmos dados do scripts/oracle/02_dados.sql: o campo oracleId guarda o ID
// da linha correspondente no Oracle (correspondência registro <-> documento).
// Datas relativas ao momento da carga (igual ao SYSTIMESTAMP do Oracle).
// Executar:  mongosh "<sua-connection-string>" --file 01_carga.js
//        ou  colar no shell do MongoDB Compass (aba _MONGOSH).
// =====================================================================
use("vozdobairro");

const AGORA = new Date();
const DIA_MS = 24 * 60 * 60 * 1000;
function diasAtras(d) { return new Date(AGORA.getTime() - d * DIA_MS); }   // d negativo = futuro
function diaTruncado(d) {                                                   // equivalente a TRUNC(SYSDATE) - d (DATE do Oracle)
  const x = diasAtras(d); x.setHours(0, 0, 0, 0); return x;
}

// ---------------------------------------------------------------------
// 1) Limpeza (reexecutável)
// ---------------------------------------------------------------------
db.propostas.drop();
db.bairros.drop();

// ---------------------------------------------------------------------
// 2) Collections com validação $jsonSchema
// ---------------------------------------------------------------------
const STATUS = ["ABERTA", "DEMANDA", "ATRASADA", "EM_EXECUCAO", "CONCLUIDA", "RECUSADA"];
const CATEGORIAS = ["ZELADORIA", "MOBILIDADE", "SAUDE", "EDUCACAO", "LAZER", "SEGURANCA", "MEIO_AMBIENTE", "OUTROS"];

db.createCollection("bairros", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["oracleId", "nome", "subprefeitura", "cidade", "metaApoiosPadrao", "estatisticas"],
      properties: {
        oracleId:         { bsonType: "number", description: "VB_BAIRRO.ID" },
        nome:             { bsonType: "string" },
        subprefeitura:    { bsonType: "string" },
        cidade:           { bsonType: "string" },
        metaApoiosPadrao: { bsonType: "number", minimum: 1 },
        estatisticas: {
          bsonType: "object",
          required: ["totalPropostas", "porStatus", "totalApoios"],
          properties: {
            totalPropostas:      { bsonType: "number", minimum: 0 },
            porStatus:           { bsonType: "object" },
            totalApoios:         { bsonType: "number", minimum: 0 },
            taxaRespostaNoPrazo: { bsonType: ["number", "null"] },
            atualizadoEm:        { bsonType: "date" }
          }
        }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

db.createCollection("propostas", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["oracleId", "titulo", "descricao", "categoria", "status", "metaApoios", "totalApoios",
                 "autor", "bairro", "apoios", "comentarios", "historicoStatus", "dtCriacao"],
      properties: {
        oracleId:    { bsonType: "number", description: "VB_PROPOSTA.ID" },
        titulo:      { bsonType: "string", maxLength: 150 },
        descricao:   { bsonType: "string", maxLength: 2000 },
        categoria:   { enum: CATEGORIAS },
        status:      { enum: STATUS },
        metaApoios:  { bsonType: "number", minimum: 1 },
        totalApoios: { bsonType: "number", minimum: 0 },
        autor: {
          bsonType: "object", required: ["id", "nome"],
          properties: { id: { bsonType: "number" }, nome: { bsonType: "string" } }
        },
        bairro: {
          bsonType: "object", required: ["bairroId", "nome"],
          properties: { bairroId: { bsonType: "number" }, nome: { bsonType: "string" } }
        },
        apoios: {
          bsonType: "array",
          items: {
            bsonType: "object", required: ["oracleId", "usuarioId", "dtApoio"],
            properties: { oracleId: { bsonType: "number" }, usuarioId: { bsonType: "number" }, dtApoio: { bsonType: "date" } }
          }
        },
        comentarios: {
          bsonType: "array",
          items: {
            bsonType: "object", required: ["oracleId", "usuario", "texto", "dtCriacao"],
            properties: { texto: { bsonType: "string", maxLength: 1000 }, dtCriacao: { bsonType: "date" } }
          }
        },
        resposta: {
          bsonType: "object", required: ["oracleId", "gestor", "decisao", "justificativa", "dtResposta"],
          properties: { decisao: { enum: ["ACEITA", "RECUSADA"] }, dtResposta: { bsonType: "date" } }
        },
        historicoStatus: {
          bsonType: "array", minItems: 1,
          items: {
            bsonType: "object", required: ["status", "em", "origem"],
            properties: { status: { enum: STATUS }, em: { bsonType: "date" }, origem: { bsonType: "string" } }
          }
        },
        dtCriacao:      { bsonType: "date" },
        dtVirouDemanda: { bsonType: "date" },
        prazoResposta:  { bsonType: "date" }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

// ---------------------------------------------------------------------
// 3) bairros (dados do bairro + estatísticas embutidas - snapshot da carga)
// ---------------------------------------------------------------------
const resBairros = db.bairros.insertMany([
  {
    oracleId: 1, nome: "Vila Mariana", subprefeitura: "Vila Mariana", cidade: "São Paulo", metaApoiosPadrao: 50,
    estatisticas: {
      totalPropostas: 3, totalApoios: 25,
      porStatus: { ABERTA: 1, DEMANDA: 1, ATRASADA: 0, EM_EXECUCAO: 0, RECUSADA: 1, CONCLUIDA: 0 },
      taxaRespostaNoPrazo: 100.0,   // = PKG_TRANSPARENCIA.FN_TAXA_RESPOSTA_NO_PRAZO(1)
      atualizadoEm: AGORA
    }
  },
  {
    oracleId: 2, nome: "Capão Redondo", subprefeitura: "Campo Limpo", cidade: "São Paulo", metaApoiosPadrao: 30,
    estatisticas: {
      totalPropostas: 6, totalApoios: 41,
      porStatus: { ABERTA: 3, DEMANDA: 1, ATRASADA: 1, EM_EXECUCAO: 1, RECUSADA: 0, CONCLUIDA: 0 },
      taxaRespostaNoPrazo: 50.0,   // = PKG_TRANSPARENCIA.FN_TAXA_RESPOSTA_NO_PRAZO(2)
      atualizadoEm: AGORA
    }
  },
  {
    oracleId: 3, nome: "Itaquera", subprefeitura: "Itaquera", cidade: "São Paulo", metaApoiosPadrao: 40,
    estatisticas: {
      totalPropostas: 3, totalApoios: 26,
      porStatus: { ABERTA: 1, DEMANDA: 0, ATRASADA: 1, EM_EXECUCAO: 0, RECUSADA: 0, CONCLUIDA: 1 },
      taxaRespostaNoPrazo: 50.0,   // = PKG_TRANSPARENCIA.FN_TAXA_RESPOSTA_NO_PRAZO(3)
      atualizadoEm: AGORA
    }
  },
  {
    oracleId: 4, nome: "Brasilândia", subprefeitura: "Freguesia/Brasilândia", cidade: "São Paulo", metaApoiosPadrao: 10,
    estatisticas: {
      totalPropostas: 3, totalApoios: 23,
      porStatus: { ABERTA: 1, DEMANDA: 1, ATRASADA: 0, EM_EXECUCAO: 1, RECUSADA: 0, CONCLUIDA: 0 },
      taxaRespostaNoPrazo: 0.0,   // = PKG_TRANSPARENCIA.FN_TAXA_RESPOSTA_NO_PRAZO(4)
      atualizadoEm: AGORA
    }
  },
  {
    oracleId: 5, nome: "Grajaú", subprefeitura: "Capela do Socorro", cidade: "São Paulo", metaApoiosPadrao: 8,
    estatisticas: {
      totalPropostas: 2, totalApoios: 16,
      porStatus: { ABERTA: 0, DEMANDA: 0, ATRASADA: 0, EM_EXECUCAO: 0, RECUSADA: 1, CONCLUIDA: 1 },
      taxaRespostaNoPrazo: 50.0,   // = PKG_TRANSPARENCIA.FN_TAXA_RESPOSTA_NO_PRAZO(5)
      atualizadoEm: AGORA
    }
  },
  {
    oracleId: 6, nome: "Mooca", subprefeitura: "Mooca", cidade: "São Paulo", metaApoiosPadrao: 10,
    estatisticas: {
      totalPropostas: 1, totalApoios: 2,
      porStatus: { ABERTA: 1, DEMANDA: 0, ATRASADA: 0, EM_EXECUCAO: 0, RECUSADA: 0, CONCLUIDA: 0 },
      taxaRespostaNoPrazo: null,   // = PKG_TRANSPARENCIA.FN_TAXA_RESPOSTA_NO_PRAZO(6)
      atualizadoEm: AGORA
    }
  }
]);
print("bairros inseridos: " + Object.keys(resBairros.insertedIds).length);

// ---------------------------------------------------------------------
// 4) propostas (autor resumido embutido, bairro por referência estendida,
//    apoios/comentários/resposta/histórico embutidos)
// ---------------------------------------------------------------------
const resPropostas = db.propostas.insertMany([
  {
    oracleId: 1,
    titulo: "Iluminação na Rua Agnaldo Macedo",
    descricao: "A rua fica totalmente escura à noite entre os números 100 e 400. Moradores voltando do trabalho e da escola se sentem inseguros.",
    categoria: "SEGURANCA", status: "ABERTA",
    metaApoios: 30, totalApoios: 7,
    autor: { id: 1, nome: "Maria Cidadã" },
    bairro: { bairroId: 2, nome: "Capão Redondo" },
    dtCriacao: diasAtras(12.3),
    apoios: [
      { oracleId: 1, usuarioId: 4, dtApoio: diasAtras(10.5938) },
      { oracleId: 2, usuarioId: 5, dtApoio: diasAtras(9.0875) },
      { oracleId: 3, usuarioId: 6, dtApoio: diasAtras(7.5813) },
      { oracleId: 4, usuarioId: 7, dtApoio: diasAtras(6.075) },
      { oracleId: 5, usuarioId: 8, dtApoio: diasAtras(4.5688) },
      { oracleId: 6, usuarioId: 9, dtApoio: diasAtras(3.0625) },
      { oracleId: 7, usuarioId: 10, dtApoio: diasAtras(1.5563) }
    ],
    comentarios: [
      { oracleId: 1, usuario: { id: 4, nome: "Ana Paula Ribeiro" }, texto: "Apoio total! Minha filha volta do cursinho por essa rua e tem medo.", dtCriacao: diasAtras(11.8) },
      { oracleId: 2, usuario: { id: 3, nome: "Carla Gestora" }, texto: "Solicitação registrada. A Ilume vai fazer vistoria técnica no trecho.", dtCriacao: diasAtras(9.5) }
    ],
    historicoStatus: [
      { status: "ABERTA", em: diasAtras(12.3), origem: "VB_PROPOSTA.DT_CRIACAO" }
    ]
  },
  {
    oracleId: 2,
    titulo: "Faixa de pedestre em frente à EMEF",
    descricao: "Crianças atravessam a avenida sem faixa nem semáforo na saída da escola. Já houve atropelamentos.",
    categoria: "MOBILIDADE", status: "ABERTA",
    metaApoios: 30, totalApoios: 5,
    autor: { id: 2, nome: "João Vizinho" },
    bairro: { bairroId: 2, nome: "Capão Redondo" },
    dtCriacao: diasAtras(10.6),
    apoios: [
      { oracleId: 8, usuarioId: 4, dtApoio: diasAtras(8.675) },
      { oracleId: 9, usuarioId: 5, dtApoio: diasAtras(6.95) },
      { oracleId: 10, usuarioId: 6, dtApoio: diasAtras(5.225) },
      { oracleId: 11, usuarioId: 7, dtApoio: diasAtras(3.5) },
      { oracleId: 12, usuarioId: 8, dtApoio: diasAtras(1.775) }
    ],
    comentarios: [
      { oracleId: 3, usuario: { id: 1, nome: "Maria Cidadã" }, texto: "Já vi duas crianças quase serem atropeladas na saída das 12h.", dtCriacao: diasAtras(10.1) }
    ],
    historicoStatus: [
      { status: "ABERTA", em: diasAtras(10.6), origem: "VB_PROPOSTA.DT_CRIACAO" }
    ]
  },
  {
    oracleId: 3,
    titulo: "Reforma da quadra do CEU Capão Redondo",
    descricao: "A quadra poliesportiva está com o piso rachado e sem rede nas traves. Os jovens do bairro deixaram de usar o espaço nos fins de semana.",
    categoria: "LAZER", status: "DEMANDA",
    metaApoios: 8, totalApoios: 9,
    autor: { id: 4, nome: "Ana Paula Ribeiro" },
    bairro: { bairroId: 2, nome: "Capão Redondo" },
    dtCriacao: diasAtras(25.2),
    dtVirouDemanda: diasAtras(3.4), prazoResposta: diasAtras(-11.6),
    apoios: [
      { oracleId: 13, usuarioId: 1, dtApoio: diasAtras(22.3) },
      { oracleId: 14, usuarioId: 2, dtApoio: diasAtras(19.6) },
      { oracleId: 15, usuarioId: 5, dtApoio: diasAtras(16.9) },
      { oracleId: 16, usuarioId: 6, dtApoio: diasAtras(14.2) },
      { oracleId: 17, usuarioId: 7, dtApoio: diasAtras(11.5) },
      { oracleId: 18, usuarioId: 8, dtApoio: diasAtras(8.8) },
      { oracleId: 19, usuarioId: 9, dtApoio: diasAtras(6.1) },
      { oracleId: 20, usuarioId: 10, dtApoio: diasAtras(3.4) },
      { oracleId: 21, usuarioId: 11, dtApoio: diasAtras(1.725) }
    ],
    comentarios: [
      { oracleId: 4, usuario: { id: 2, nome: "João Vizinho" }, texto: "O CEU é o principal espaço de esporte dos jovens daqui. Precisa muito!", dtCriacao: diasAtras(20), dtEdicao: diasAtras(19.5) }
    ],
    historicoStatus: [
      { status: "ABERTA", em: diasAtras(25.2), origem: "VB_PROPOSTA.DT_CRIACAO" },
      { status: "DEMANDA", em: diasAtras(3.4), origem: "VB_PROPOSTA.DT_VIROU_DEMANDA" }
    ]
  },
  {
    oracleId: 4,
    titulo: "UBS do Capão Redondo aberta aos sábados",
    descricao: "Quem trabalha durante a semana não consegue consultar nem vacinar os filhos. Pedimos atendimento aos sábados pela manhã na UBS.",
    categoria: "SAUDE", status: "ATRASADA",
    metaApoios: 10, totalApoios: 10,
    autor: { id: 1, nome: "Maria Cidadã" },
    bairro: { bairroId: 2, nome: "Capão Redondo" },
    dtCriacao: diasAtras(45.1),
    dtVirouDemanda: diasAtras(25.5), prazoResposta: diasAtras(10.5),
    apoios: [
      { oracleId: 22, usuarioId: 2, dtApoio: diasAtras(42.96) },
      { oracleId: 23, usuarioId: 4, dtApoio: diasAtras(41.02) },
      { oracleId: 24, usuarioId: 5, dtApoio: diasAtras(39.08) },
      { oracleId: 25, usuarioId: 6, dtApoio: diasAtras(37.14) },
      { oracleId: 26, usuarioId: 7, dtApoio: diasAtras(35.2) },
      { oracleId: 27, usuarioId: 8, dtApoio: diasAtras(33.26) },
      { oracleId: 28, usuarioId: 9, dtApoio: diasAtras(31.32) },
      { oracleId: 29, usuarioId: 10, dtApoio: diasAtras(29.38) },
      { oracleId: 30, usuarioId: 11, dtApoio: diasAtras(27.44) },
      { oracleId: 31, usuarioId: 12, dtApoio: diasAtras(25.5) }
    ],
    comentarios: [
      { oracleId: 5, usuario: { id: 4, nome: "Ana Paula Ribeiro" }, texto: "Já passou do prazo e ninguém respondeu. Vamos cobrar!", dtCriacao: diasAtras(9) }
    ],
    historicoStatus: [
      { status: "ABERTA", em: diasAtras(45.1), origem: "VB_PROPOSTA.DT_CRIACAO" },
      { status: "DEMANDA", em: diasAtras(25.5), origem: "VB_PROPOSTA.DT_VIROU_DEMANDA" },
      { status: "ATRASADA", em: diasAtras(10.4), origem: "VB_NOTIFICACAO.DT_CRIACAO (aviso de atraso)" }
    ]
  },
  {
    oracleId: 5,
    titulo: "Limpeza do córrego Pirajuçara-Mirim",
    descricao: "O córrego acumula lixo e entulho; em dias de chuva a água invade as casas da viela. Pedimos limpeza e caçambas para descarte.",
    categoria: "MEIO_AMBIENTE", status: "EM_EXECUCAO",
    metaApoios: 8, totalApoios: 8,
    autor: { id: 2, nome: "João Vizinho" },
    bairro: { bairroId: 2, nome: "Capão Redondo" },
    dtCriacao: diasAtras(60.3),
    dtVirouDemanda: diasAtras(40.2), prazoResposta: diasAtras(25.2),
    resposta: {
      oracleId: 1, gestor: { id: 3, nome: "Carla Gestora" }, decisao: "ACEITA",
      justificativa: "Limpeza incluída no cronograma da Subprefeitura do Campo Limpo, com caçambas por 30 dias.",
      prazoExecucao: diaTruncado(-60), dtResposta: diasAtras(30.1)
    },
    apoios: [
      { oracleId: 32, usuarioId: 1, dtApoio: diasAtras(57.6125) },
      { oracleId: 33, usuarioId: 4, dtApoio: diasAtras(55.125) },
      { oracleId: 34, usuarioId: 5, dtApoio: diasAtras(52.6375) },
      { oracleId: 35, usuarioId: 6, dtApoio: diasAtras(50.15) },
      { oracleId: 36, usuarioId: 7, dtApoio: diasAtras(47.6625) },
      { oracleId: 37, usuarioId: 8, dtApoio: diasAtras(45.175) },
      { oracleId: 38, usuarioId: 9, dtApoio: diasAtras(42.6875) },
      { oracleId: 39, usuarioId: 10, dtApoio: diasAtras(40.2) }
    ],
    comentarios: [
      { oracleId: 6, usuario: { id: 1, nome: "Maria Cidadã" }, texto: "As caçambas chegaram ontem, obrigado a todos que apoiaram.", dtCriacao: diasAtras(25) }
    ],
    historicoStatus: [
      { status: "ABERTA", em: diasAtras(60.3), origem: "VB_PROPOSTA.DT_CRIACAO" },
      { status: "DEMANDA", em: diasAtras(40.2), origem: "VB_PROPOSTA.DT_VIROU_DEMANDA" },
      { status: "EM_EXECUCAO", em: diasAtras(30.1), origem: "VB_RESPOSTA.DT_RESPOSTA" }
    ]
  },
  {
    oracleId: 6,
    titulo: "Poda de árvores na Rua Domingos de Morais",
    descricao: "Galhos encostando na fiação elétrica e cobrindo a iluminação pública em vários trechos da calçada.",
    categoria: "ZELADORIA", status: "ABERTA",
    metaApoios: 50, totalApoios: 4,
    autor: { id: 7, nome: "Ricardo Almeida" },
    bairro: { bairroId: 1, nome: "Vila Mariana" },
    dtCriacao: diasAtras(8.2),
    apoios: [
      { oracleId: 40, usuarioId: 8, dtApoio: diasAtras(6.41) },
      { oracleId: 41, usuarioId: 1, dtApoio: diasAtras(4.82) },
      { oracleId: 42, usuarioId: 2, dtApoio: diasAtras(3.23) },
      { oracleId: 43, usuarioId: 4, dtApoio: diasAtras(1.64) }
    ],
    comentarios: [],
    historicoStatus: [
      { status: "ABERTA", em: diasAtras(8.2), origem: "VB_PROPOSTA.DT_CRIACAO" }
    ]
  },
  {
    oracleId: 7,
    titulo: "Ciclofaixa na Rua Sena Madureira",
    descricao: "Muitos moradores vão de bicicleta até o metrô Vila Mariana disputando espaço com ônibus. Uma ciclofaixa ligaria o bairro à rede existente.",
    categoria: "MOBILIDADE", status: "RECUSADA",
    metaApoios: 10, totalApoios: 11,
    autor: { id: 8, nome: "Fernanda Oliveira Costa" },
    bairro: { bairroId: 1, nome: "Vila Mariana" },
    dtCriacao: diasAtras(70.4),
    dtVirouDemanda: diasAtras(50.3), prazoResposta: diasAtras(35.3),
    resposta: {
      oracleId: 2, gestor: { id: 14, nome: "Roberto Mendes" }, decisao: "RECUSADA",
      justificativa: "A via está no plano de requalificação da CET para 2027; a ciclofaixa será avaliada dentro desse projeto e não isoladamente.",
      prazoExecucao: null, dtResposta: diasAtras(38.2)
    },
    apoios: [
      { oracleId: 44, usuarioId: 7, dtApoio: diasAtras(68.21) },
      { oracleId: 45, usuarioId: 1, dtApoio: diasAtras(66.22) },
      { oracleId: 46, usuarioId: 2, dtApoio: diasAtras(64.23) },
      { oracleId: 47, usuarioId: 4, dtApoio: diasAtras(62.24) },
      { oracleId: 48, usuarioId: 5, dtApoio: diasAtras(60.25) },
      { oracleId: 49, usuarioId: 6, dtApoio: diasAtras(58.26) },
      { oracleId: 50, usuarioId: 9, dtApoio: diasAtras(56.27) },
      { oracleId: 51, usuarioId: 10, dtApoio: diasAtras(54.28) },
      { oracleId: 52, usuarioId: 11, dtApoio: diasAtras(52.29) },
      { oracleId: 53, usuarioId: 12, dtApoio: diasAtras(50.3) },
      { oracleId: 54, usuarioId: 13, dtApoio: diasAtras(44.25) }
    ],
    comentarios: [
      { oracleId: 7, usuario: { id: 7, nome: "Ricardo Almeida" }, texto: "Uma pena a recusa, vamos acompanhar o projeto da CET.", dtCriacao: diasAtras(37.5) }
    ],
    historicoStatus: [
      { status: "ABERTA", em: diasAtras(70.4), origem: "VB_PROPOSTA.DT_CRIACAO" },
      { status: "DEMANDA", em: diasAtras(50.3), origem: "VB_PROPOSTA.DT_VIROU_DEMANDA" },
      { status: "RECUSADA", em: diasAtras(38.2), origem: "VB_RESPOSTA.DT_RESPOSTA" }
    ]
  },
  {
    oracleId: 8,
    titulo: "Rondas e iluminação na saída do metrô Santa Cruz",
    descricao: "À noite a saída lateral do metrô fica deserta e houve vários roubos de celular. Pedimos reforço de iluminação e rondas da GCM.",
    categoria: "SEGURANCA", status: "DEMANDA",
    metaApoios: 10, totalApoios: 10,
    autor: { id: 7, nome: "Ricardo Almeida" },
    bairro: { bairroId: 1, nome: "Vila Mariana" },
    dtCriacao: diasAtras(20.5),
    dtVirouDemanda: diasAtras(2.2), prazoResposta: diasAtras(-12.8),
    apoios: [
      { oracleId: 55, usuarioId: 8, dtApoio: diasAtras(18.49) },
      { oracleId: 56, usuarioId: 1, dtApoio: diasAtras(16.68) },
      { oracleId: 57, usuarioId: 2, dtApoio: diasAtras(14.87) },
      { oracleId: 58, usuarioId: 4, dtApoio: diasAtras(13.06) },
      { oracleId: 59, usuarioId: 5, dtApoio: diasAtras(11.25) },
      { oracleId: 60, usuarioId: 6, dtApoio: diasAtras(9.44) },
      { oracleId: 61, usuarioId: 9, dtApoio: diasAtras(7.63) },
      { oracleId: 62, usuarioId: 10, dtApoio: diasAtras(5.82) },
      { oracleId: 63, usuarioId: 11, dtApoio: diasAtras(4.01) },
      { oracleId: 64, usuarioId: 12, dtApoio: diasAtras(2.2) }
    ],
    comentarios: [
      { oracleId: 8, usuario: { id: 8, nome: "Fernanda Oliveira Costa" }, texto: "Fui assaltada nessa saída mês passado. Apoiado.", dtCriacao: diasAtras(15) }
    ],
    historicoStatus: [
      { status: "ABERTA", em: diasAtras(20.5), origem: "VB_PROPOSTA.DT_CRIACAO" },
      { status: "DEMANDA", em: diasAtras(2.2), origem: "VB_PROPOSTA.DT_VIROU_DEMANDA" }
    ]
  },
  {
    oracleId: 9,
    titulo: "Cobertura nos pontos de ônibus da Av. Jacu-Pêssego",
    descricao: "Os pontos não têm cobertura nem banco; idosos esperam no sol e na chuva por mais de 30 minutos.",
    categoria: "MOBILIDADE", status: "ATRASADA",
    metaApoios: 10, totalApoios: 11,
    autor: { id: 5, nome: "Bruno Henrique Santos" },
    bairro: { bairroId: 3, nome: "Itaquera" },
    dtCriacao: diasAtras(50.2),
    dtVirouDemanda: diasAtras(20.3), prazoResposta: diasAtras(5.3),
    apoios: [
      { oracleId: 65, usuarioId: 6, dtApoio: diasAtras(47.03) },
      { oracleId: 66, usuarioId: 1, dtApoio: diasAtras(44.06) },
      { oracleId: 67, usuarioId: 2, dtApoio: diasAtras(41.09) },
      { oracleId: 68, usuarioId: 4, dtApoio: diasAtras(38.12) },
      { oracleId: 69, usuarioId: 7, dtApoio: diasAtras(35.15) },
      { oracleId: 70, usuarioId: 8, dtApoio: diasAtras(32.18) },
      { oracleId: 71, usuarioId: 9, dtApoio: diasAtras(29.21) },
      { oracleId: 72, usuarioId: 10, dtApoio: diasAtras(26.24) },
      { oracleId: 73, usuarioId: 11, dtApoio: diasAtras(23.27) },
      { oracleId: 74, usuarioId: 12, dtApoio: diasAtras(20.3) },
      { oracleId: 75, usuarioId: 13, dtApoio: diasAtras(10.175) }
    ],
    comentarios: [
      { oracleId: 9, usuario: { id: 6, nome: "Juliana Ferreira Lima" }, texto: "Minha mãe tem 72 anos e espera o ônibus em pé no sol.", dtCriacao: diasAtras(30) }
    ],
    historicoStatus: [
      { status: "ABERTA", em: diasAtras(50.2), origem: "VB_PROPOSTA.DT_CRIACAO" },
      { status: "DEMANDA", em: diasAtras(20.3), origem: "VB_PROPOSTA.DT_VIROU_DEMANDA" },
      { status: "ATRASADA", em: diasAtras(5.2), origem: "VB_NOTIFICACAO.DT_CRIACAO (aviso de atraso)" }
    ]
  },
  {
    oracleId: 10,
    titulo: "Reabertura da biblioteca comunitária de Itaquera",
    descricao: "A biblioteca está fechada desde a pandemia. Estudantes não têm lugar para estudar nem acesso a computadores.",
    categoria: "EDUCACAO", status: "CONCLUIDA",
    metaApoios: 8, totalApoios: 9,
    autor: { id: 6, nome: "Juliana Ferreira Lima" },
    bairro: { bairroId: 3, nome: "Itaquera" },
    dtCriacao: diasAtras(120.5),
    dtVirouDemanda: diasAtras(100.2), prazoResposta: diasAtras(85.2),
    resposta: {
      oracleId: 3, gestor: { id: 15, nome: "Sandra Lopes" }, decisao: "ACEITA",
      justificativa: "Reabertura aprovada com novo horário (9h às 20h) e 10 computadores doados pela Secretaria de Educação.",
      prazoExecucao: diaTruncado(60), dtResposta: diasAtras(90.1)
    },
    apoios: [
      { oracleId: 76, usuarioId: 5, dtApoio: diasAtras(117.787) },
      { oracleId: 77, usuarioId: 1, dtApoio: diasAtras(115.275) },
      { oracleId: 78, usuarioId: 2, dtApoio: diasAtras(112.763) },
      { oracleId: 79, usuarioId: 4, dtApoio: diasAtras(110.25) },
      { oracleId: 80, usuarioId: 7, dtApoio: diasAtras(107.737) },
      { oracleId: 81, usuarioId: 8, dtApoio: diasAtras(105.225) },
      { oracleId: 82, usuarioId: 9, dtApoio: diasAtras(102.713) },
      { oracleId: 83, usuarioId: 10, dtApoio: diasAtras(100.2) },
      { oracleId: 84, usuarioId: 11, dtApoio: diasAtras(95.15) }
    ],
    comentarios: [
      { oracleId: 10, usuario: { id: 5, nome: "Bruno Henrique Santos" }, texto: "Biblioteca reaberta e cheia de estudantes. Deu certo!", dtCriacao: diasAtras(57) }
    ],
    historicoStatus: [
      { status: "ABERTA", em: diasAtras(120.5), origem: "VB_PROPOSTA.DT_CRIACAO" },
      { status: "DEMANDA", em: diasAtras(100.2), origem: "VB_PROPOSTA.DT_VIROU_DEMANDA" },
      { status: "EM_EXECUCAO", em: diasAtras(90.1), origem: "VB_RESPOSTA.DT_RESPOSTA" },
      { status: "CONCLUIDA", em: diasAtras(58), origem: "VB_NOTIFICACAO.DT_CRIACAO (aviso de conclusão)" }
    ]
  },
  {
    oracleId: 11,
    titulo: "Tapa-buracos na Rua Victório Santim",
    descricao: "Buracos grandes na pista causam acidentes com motos e danificam carros, principalmente perto do terminal.",
    categoria: "ZELADORIA", status: "ABERTA",
    metaApoios: 40, totalApoios: 6,
    autor: { id: 5, nome: "Bruno Henrique Santos" },
    bairro: { bairroId: 3, nome: "Itaquera" },
    dtCriacao: diasAtras(6.4),
    apoios: [
      { oracleId: 85, usuarioId: 6, dtApoio: diasAtras(5.3214) },
      { oracleId: 86, usuarioId: 1, dtApoio: diasAtras(4.4429) },
      { oracleId: 87, usuarioId: 2, dtApoio: diasAtras(3.5643) },
      { oracleId: 88, usuarioId: 4, dtApoio: diasAtras(2.6857) },
      { oracleId: 89, usuarioId: 7, dtApoio: diasAtras(1.8071) },
      { oracleId: 90, usuarioId: 8, dtApoio: diasAtras(0.9286) }
    ],
    comentarios: [],
    historicoStatus: [
      { status: "ABERTA", em: diasAtras(6.4), origem: "VB_PROPOSTA.DT_CRIACAO" }
    ]
  },
  {
    oracleId: 12,
    titulo: "Pediatra todos os dias na UBS Vila Brasilândia",
    descricao: "Hoje só há pediatra duas vezes por semana; as mães esperam semanas por consulta ou vão ao pronto-socorro.",
    categoria: "SAUDE", status: "EM_EXECUCAO",
    metaApoios: 10, totalApoios: 10,
    autor: { id: 9, nome: "Lucas Gabriel Souza" },
    bairro: { bairroId: 4, nome: "Brasilândia" },
    dtCriacao: diasAtras(40.3),
    dtVirouDemanda: diasAtras(30.2), prazoResposta: diasAtras(15.2),
    resposta: {
      oracleId: 4, gestor: { id: 3, nome: "Carla Gestora" }, decisao: "ACEITA",
      justificativa: "Contratação de dois pediatras aprovada; escala diária a partir do próximo mês.",
      prazoExecucao: diaTruncado(-45), dtResposta: diasAtras(12)
    },
    apoios: [
      { oracleId: 91, usuarioId: 10, dtApoio: diasAtras(39.11) },
      { oracleId: 92, usuarioId: 1, dtApoio: diasAtras(38.12) },
      { oracleId: 93, usuarioId: 2, dtApoio: diasAtras(37.13) },
      { oracleId: 94, usuarioId: 4, dtApoio: diasAtras(36.14) },
      { oracleId: 95, usuarioId: 5, dtApoio: diasAtras(35.15) },
      { oracleId: 96, usuarioId: 6, dtApoio: diasAtras(34.16) },
      { oracleId: 97, usuarioId: 7, dtApoio: diasAtras(33.17) },
      { oracleId: 98, usuarioId: 8, dtApoio: diasAtras(32.18) },
      { oracleId: 99, usuarioId: 11, dtApoio: diasAtras(31.19) },
      { oracleId: 100, usuarioId: 12, dtApoio: diasAtras(30.2) }
    ],
    comentarios: [
      { oracleId: 11, usuario: { id: 10, nome: "Patrícia Nogueira" }, texto: "Respondeu fora do prazo, mas pelo menos aceitaram.", dtCriacao: diasAtras(11.5) }
    ],
    historicoStatus: [
      { status: "ABERTA", em: diasAtras(40.3), origem: "VB_PROPOSTA.DT_CRIACAO" },
      { status: "DEMANDA", em: diasAtras(30.2), origem: "VB_PROPOSTA.DT_VIROU_DEMANDA" },
      { status: "ATRASADA", em: diasAtras(15.1), origem: "VB_NOTIFICACAO.DT_CRIACAO (aviso de atraso)" },
      { status: "EM_EXECUCAO", em: diasAtras(12), origem: "VB_RESPOSTA.DT_RESPOSTA" }
    ]
  },
  {
    oracleId: 13,
    titulo: "Coleta seletiva semanal na Brasilândia",
    descricao: "O caminhão da coleta seletiva não passa nas ruas de cima do morro; o reciclável acaba no lixo comum.",
    categoria: "MEIO_AMBIENTE", status: "ABERTA",
    metaApoios: 10, totalApoios: 3,
    autor: { id: 10, nome: "Patrícia Nogueira" },
    bairro: { bairroId: 4, nome: "Brasilândia" },
    dtCriacao: diasAtras(5.3),
    apoios: [
      { oracleId: 101, usuarioId: 9, dtApoio: diasAtras(3.8375) },
      { oracleId: 102, usuarioId: 1, dtApoio: diasAtras(2.575) },
      { oracleId: 103, usuarioId: 2, dtApoio: diasAtras(1.3125) }
    ],
    comentarios: [],
    historicoStatus: [
      { status: "ABERTA", em: diasAtras(5.3), origem: "VB_PROPOSTA.DT_CRIACAO" }
    ]
  },
  {
    oracleId: 14,
    titulo: "Iluminação da escadaria da Rua Parapuã",
    descricao: "A escadaria é o único acesso de muitas famílias ao ponto de ônibus e está sem nenhuma lâmpada funcionando.",
    categoria: "SEGURANCA", status: "DEMANDA",
    metaApoios: 10, totalApoios: 10,
    autor: { id: 10, nome: "Patrícia Nogueira" },
    bairro: { bairroId: 4, nome: "Brasilândia" },
    dtCriacao: diasAtras(15.4),
    dtVirouDemanda: diasAtras(1.3), prazoResposta: diasAtras(-13.7),
    apoios: [
      { oracleId: 104, usuarioId: 9, dtApoio: diasAtras(13.81) },
      { oracleId: 105, usuarioId: 1, dtApoio: diasAtras(12.42) },
      { oracleId: 106, usuarioId: 2, dtApoio: diasAtras(11.03) },
      { oracleId: 107, usuarioId: 4, dtApoio: diasAtras(9.64) },
      { oracleId: 108, usuarioId: 5, dtApoio: diasAtras(8.25) },
      { oracleId: 109, usuarioId: 6, dtApoio: diasAtras(6.86) },
      { oracleId: 110, usuarioId: 7, dtApoio: diasAtras(5.47) },
      { oracleId: 111, usuarioId: 8, dtApoio: diasAtras(4.08) },
      { oracleId: 112, usuarioId: 11, dtApoio: diasAtras(2.69) },
      { oracleId: 113, usuarioId: 12, dtApoio: diasAtras(1.3) }
    ],
    comentarios: [
      { oracleId: 12, usuario: { id: 9, nome: "Lucas Gabriel Souza" }, texto: "Subo essa escadaria todo dia às 5h, no escuro total.", dtCriacao: diasAtras(10) }
    ],
    historicoStatus: [
      { status: "ABERTA", em: diasAtras(15.4), origem: "VB_PROPOSTA.DT_CRIACAO" },
      { status: "DEMANDA", em: diasAtras(1.3), origem: "VB_PROPOSTA.DT_VIROU_DEMANDA" }
    ]
  },
  {
    oracleId: 15,
    titulo: "Linha de ônibus noturna Grajaú - Terminal Santo Amaro",
    descricao: "Quem trabalha até tarde não tem ônibus depois da meia-noite e precisa pagar aplicativo ou dormir no trabalho.",
    categoria: "MOBILIDADE", status: "RECUSADA",
    metaApoios: 8, totalApoios: 8,
    autor: { id: 11, nome: "Diego Martins Rocha" },
    bairro: { bairroId: 5, nome: "Grajaú" },
    dtCriacao: diasAtras(80.2),
    dtVirouDemanda: diasAtras(60.4), prazoResposta: diasAtras(45.4),
    resposta: {
      oracleId: 5, gestor: { id: 14, nome: "Roberto Mendes" }, decisao: "RECUSADA",
      justificativa: "A SPTrans informou que a linha noturna N632 já atende a região; será ampliada a divulgação dos horários.",
      prazoExecucao: null, dtResposta: diasAtras(40.2)
    },
    apoios: [
      { oracleId: 114, usuarioId: 12, dtApoio: diasAtras(77.55) },
      { oracleId: 115, usuarioId: 1, dtApoio: diasAtras(75.1) },
      { oracleId: 116, usuarioId: 2, dtApoio: diasAtras(72.65) },
      { oracleId: 117, usuarioId: 4, dtApoio: diasAtras(70.2) },
      { oracleId: 118, usuarioId: 5, dtApoio: diasAtras(67.75) },
      { oracleId: 119, usuarioId: 6, dtApoio: diasAtras(65.3) },
      { oracleId: 120, usuarioId: 7, dtApoio: diasAtras(62.85) },
      { oracleId: 121, usuarioId: 8, dtApoio: diasAtras(60.4) }
    ],
    comentarios: [
      { oracleId: 13, usuario: { id: 12, nome: "Camila Rodrigues" }, texto: "A N632 não passa no nosso trecho, a resposta não resolve.", dtCriacao: diasAtras(39) }
    ],
    historicoStatus: [
      { status: "ABERTA", em: diasAtras(80.2), origem: "VB_PROPOSTA.DT_CRIACAO" },
      { status: "DEMANDA", em: diasAtras(60.4), origem: "VB_PROPOSTA.DT_VIROU_DEMANDA" },
      { status: "ATRASADA", em: diasAtras(45.3), origem: "VB_NOTIFICACAO.DT_CRIACAO (aviso de atraso)" },
      { status: "RECUSADA", em: diasAtras(40.2), origem: "VB_RESPOSTA.DT_RESPOSTA" }
    ]
  },
  {
    oracleId: 16,
    titulo: "Revitalização da Praça do Jardim Shangri-lá",
    descricao: "Brinquedos quebrados, mato alto e bancos destruídos. A praça é o único espaço de lazer para as crianças da região.",
    categoria: "LAZER", status: "CONCLUIDA",
    metaApoios: 8, totalApoios: 8,
    autor: { id: 12, nome: "Camila Rodrigues" },
    bairro: { bairroId: 5, nome: "Grajaú" },
    dtCriacao: diasAtras(150.3),
    dtVirouDemanda: diasAtras(130.2), prazoResposta: diasAtras(115.2),
    resposta: {
      oracleId: 6, gestor: { id: 15, nome: "Sandra Lopes" }, decisao: "ACEITA",
      justificativa: "Revitalização incluída no programa de zeladoria: novos brinquedos, bancos e roçagem mensal.",
      prazoExecucao: diaTruncado(80), dtResposta: diasAtras(120.4)
    },
    apoios: [
      { oracleId: 122, usuarioId: 11, dtApoio: diasAtras(147.613) },
      { oracleId: 123, usuarioId: 1, dtApoio: diasAtras(145.125) },
      { oracleId: 124, usuarioId: 2, dtApoio: diasAtras(142.637) },
      { oracleId: 125, usuarioId: 4, dtApoio: diasAtras(140.15) },
      { oracleId: 126, usuarioId: 5, dtApoio: diasAtras(137.662) },
      { oracleId: 127, usuarioId: 6, dtApoio: diasAtras(135.175) },
      { oracleId: 128, usuarioId: 7, dtApoio: diasAtras(132.688) },
      { oracleId: 129, usuarioId: 8, dtApoio: diasAtras(130.2) }
    ],
    comentarios: [
      { oracleId: 14, usuario: { id: 11, nome: "Diego Martins Rocha" }, texto: "A praça ficou ótima, as crianças voltaram a brincar lá.", dtCriacao: diasAtras(75) }
    ],
    historicoStatus: [
      { status: "ABERTA", em: diasAtras(150.3), origem: "VB_PROPOSTA.DT_CRIACAO" },
      { status: "DEMANDA", em: diasAtras(130.2), origem: "VB_PROPOSTA.DT_VIROU_DEMANDA" },
      { status: "EM_EXECUCAO", em: diasAtras(120.4), origem: "VB_RESPOSTA.DT_RESPOSTA" },
      { status: "CONCLUIDA", em: diasAtras(78.3), origem: "VB_NOTIFICACAO.DT_CRIACAO (aviso de conclusão)" }
    ]
  },
  {
    oracleId: 17,
    titulo: "Horta comunitária na Praça Kennedy",
    descricao: "Moradores querem transformar um canto sem uso da praça em horta comunitária, com apoio técnico da prefeitura.",
    categoria: "MEIO_AMBIENTE", status: "ABERTA",
    metaApoios: 10, totalApoios: 2,
    autor: { id: 13, nome: "Thiago Pereira Alves" },
    bairro: { bairroId: 6, nome: "Mooca" },
    dtCriacao: diasAtras(4.2),
    apoios: [
      { oracleId: 130, usuarioId: 1, dtApoio: diasAtras(2.6833) },
      { oracleId: 131, usuarioId: 2, dtApoio: diasAtras(1.3667) }
    ],
    comentarios: [
      { oracleId: 15, usuario: { id: 13, nome: "Thiago Pereira Alves" }, texto: "Posso doar mudas e ajudar no mutirão de sábado.", dtCriacao: diasAtras(3), dtEdicao: diasAtras(2.8) }
    ],
    historicoStatus: [
      { status: "ABERTA", em: diasAtras(4.2), origem: "VB_PROPOSTA.DT_CRIACAO" }
    ]
  },
  {
    oracleId: 18,
    titulo: "Academia ao ar livre no Parque Santo Dias",
    descricao: "Pedimos aparelhos de ginástica ao ar livre perto da entrada do parque, muito procurada por idosos pela manhã.",
    categoria: "LAZER", status: "ABERTA",
    metaApoios: 30, totalApoios: 2,
    autor: { id: 4, nome: "Ana Paula Ribeiro" },
    bairro: { bairroId: 2, nome: "Capão Redondo" },
    dtCriacao: diasAtras(3.1),
    apoios: [
      { oracleId: 132, usuarioId: 1, dtApoio: diasAtras(1.95) },
      { oracleId: 133, usuarioId: 2, dtApoio: diasAtras(1) }
    ],
    comentarios: [],
    historicoStatus: [
      { status: "ABERTA", em: diasAtras(3.1), origem: "VB_PROPOSTA.DT_CRIACAO" }
    ]
  }
]);
print("propostas inseridas: " + Object.keys(resPropostas.insertedIds).length);

// ---------------------------------------------------------------------
// 5) Índices (equivalentes aos índices criados no Oracle)
// ---------------------------------------------------------------------
db.bairros.createIndex({ oracleId: 1 }, { unique: true });
db.propostas.createIndex({ oracleId: 1 }, { unique: true });
db.propostas.createIndex({ "bairro.bairroId": 1, status: 1 });   // IX_VB_PROPOSTA_BAIRRO_STATUS
db.propostas.createIndex({ status: 1, prazoResposta: 1 });       // IX_VB_PROPOSTA_STATUS_PRAZO
db.propostas.createIndex({ "apoios.usuarioId": 1 });             // IX_VB_APOIO_USUARIO (multikey)

// ---------------------------------------------------------------------
// 6) Conferência rápida
//    esperado: bairros=6 propostas=18 apoios embutidos=133 comentarios=15
// ---------------------------------------------------------------------
print("bairros:   " + db.bairros.countDocuments());
print("propostas: " + db.propostas.countDocuments());
db.propostas.aggregate([
  { $group: { _id: null, apoios: { $sum: { $size: "$apoios" } }, comentarios: { $sum: { $size: "$comentarios" } } } },
  { $project: { _id: 0, apoios: 1, comentarios: 1 } }
]).forEach(d => printjson(d));
