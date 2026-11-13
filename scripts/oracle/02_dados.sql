-- =====================================================================
-- VOZ DO BAIRRO - 02_dados.sql
-- Dados de teste (São Paulo). Rodar logo depois do 01_ddl.sql (tabelas vazias,
-- identity reiniciada) para que os IDs batam com o oracleId do MongoDB.
-- Datas relativas a SYSTIMESTAMP: os status continuam coerentes em qualquer dia.
-- Arquivo gerado a partir da mesma fonte do scripts/mongodb/01_carga.js.
-- =====================================================================
SET DEFINE OFF
SET SQLBLANKLINES ON
SET SERVEROUTPUT ON SIZE UNLIMITED

-- ---------------------------------------------------------------------
-- 1) Bairros (os 3 primeiros = seed do contrato, mesma ordem/IDs)
-- ---------------------------------------------------------------------
INSERT INTO VB_BAIRRO (NOME, SUBPREFEITURA, META_APOIOS_PADRAO) VALUES ('Vila Mariana', 'Vila Mariana', 50);
INSERT INTO VB_BAIRRO (NOME, SUBPREFEITURA, META_APOIOS_PADRAO) VALUES ('Capão Redondo', 'Campo Limpo', 30);
INSERT INTO VB_BAIRRO (NOME, SUBPREFEITURA, META_APOIOS_PADRAO) VALUES ('Itaquera', 'Itaquera', 40);
INSERT INTO VB_BAIRRO (NOME, SUBPREFEITURA, META_APOIOS_PADRAO) VALUES ('Brasilândia', 'Freguesia/Brasilândia', 10);
INSERT INTO VB_BAIRRO (NOME, SUBPREFEITURA, META_APOIOS_PADRAO) VALUES ('Grajaú', 'Capela do Socorro', 8);
INSERT INTO VB_BAIRRO (NOME, SUBPREFEITURA, META_APOIOS_PADRAO) VALUES ('Mooca', 'Mooca', 10);

-- ---------------------------------------------------------------------
-- 2) Usuários (senha de todos: Senha@123). IDs 1..3 = seed do contrato.
-- ---------------------------------------------------------------------
INSERT INTO VB_USUARIO (NOME, EMAIL, SENHA_HASH, PAPEL, BAIRRO_ID)
  VALUES ('Maria Cidadã', 'cidadao@vozdobairro.com', '$2a$10$Yo8Jrc6SrfqCEGZtaJFnReZPvqzVm5yvQpmwYdaTFgl78a5d17Ub6', 'CIDADAO', (SELECT ID FROM VB_BAIRRO WHERE NOME = 'Capão Redondo'));
INSERT INTO VB_USUARIO (NOME, EMAIL, SENHA_HASH, PAPEL, BAIRRO_ID)
  VALUES ('João Vizinho', 'vizinho@vozdobairro.com', '$2a$10$Yo8Jrc6SrfqCEGZtaJFnReZPvqzVm5yvQpmwYdaTFgl78a5d17Ub6', 'CIDADAO', (SELECT ID FROM VB_BAIRRO WHERE NOME = 'Capão Redondo'));
INSERT INTO VB_USUARIO (NOME, EMAIL, SENHA_HASH, PAPEL, BAIRRO_ID)
  VALUES ('Carla Gestora', 'gestor@vozdobairro.com', '$2a$10$Yo8Jrc6SrfqCEGZtaJFnReZPvqzVm5yvQpmwYdaTFgl78a5d17Ub6', 'GESTOR', NULL);
INSERT INTO VB_USUARIO (NOME, EMAIL, SENHA_HASH, PAPEL, BAIRRO_ID, DT_CADASTRO)
  VALUES ('Ana Paula Ribeiro', 'ana.ribeiro@vozdobairro.com', '$2a$10$Yo8Jrc6SrfqCEGZtaJFnReZPvqzVm5yvQpmwYdaTFgl78a5d17Ub6', 'CIDADAO', (SELECT ID FROM VB_BAIRRO WHERE NOME = 'Capão Redondo'), SYSTIMESTAMP - NUMTODSINTERVAL(200, 'DAY'));
INSERT INTO VB_USUARIO (NOME, EMAIL, SENHA_HASH, PAPEL, BAIRRO_ID, DT_CADASTRO)
  VALUES ('Bruno Henrique Santos', 'bruno.santos@vozdobairro.com', '$2a$10$Yo8Jrc6SrfqCEGZtaJFnReZPvqzVm5yvQpmwYdaTFgl78a5d17Ub6', 'CIDADAO', (SELECT ID FROM VB_BAIRRO WHERE NOME = 'Itaquera'), SYSTIMESTAMP - NUMTODSINTERVAL(190, 'DAY'));
INSERT INTO VB_USUARIO (NOME, EMAIL, SENHA_HASH, PAPEL, BAIRRO_ID, DT_CADASTRO)
  VALUES ('Juliana Ferreira Lima', 'juliana.lima@vozdobairro.com', '$2a$10$Yo8Jrc6SrfqCEGZtaJFnReZPvqzVm5yvQpmwYdaTFgl78a5d17Ub6', 'CIDADAO', (SELECT ID FROM VB_BAIRRO WHERE NOME = 'Itaquera'), SYSTIMESTAMP - NUMTODSINTERVAL(185, 'DAY'));
INSERT INTO VB_USUARIO (NOME, EMAIL, SENHA_HASH, PAPEL, BAIRRO_ID, DT_CADASTRO)
  VALUES ('Ricardo Almeida', 'ricardo.almeida@vozdobairro.com', '$2a$10$Yo8Jrc6SrfqCEGZtaJFnReZPvqzVm5yvQpmwYdaTFgl78a5d17Ub6', 'CIDADAO', (SELECT ID FROM VB_BAIRRO WHERE NOME = 'Vila Mariana'), SYSTIMESTAMP - NUMTODSINTERVAL(180, 'DAY'));
INSERT INTO VB_USUARIO (NOME, EMAIL, SENHA_HASH, PAPEL, BAIRRO_ID, DT_CADASTRO)
  VALUES ('Fernanda Oliveira Costa', 'fernanda.costa@vozdobairro.com', '$2a$10$Yo8Jrc6SrfqCEGZtaJFnReZPvqzVm5yvQpmwYdaTFgl78a5d17Ub6', 'CIDADAO', (SELECT ID FROM VB_BAIRRO WHERE NOME = 'Vila Mariana'), SYSTIMESTAMP - NUMTODSINTERVAL(175, 'DAY'));
INSERT INTO VB_USUARIO (NOME, EMAIL, SENHA_HASH, PAPEL, BAIRRO_ID, DT_CADASTRO)
  VALUES ('Lucas Gabriel Souza', 'lucas.souza@vozdobairro.com', '$2a$10$Yo8Jrc6SrfqCEGZtaJFnReZPvqzVm5yvQpmwYdaTFgl78a5d17Ub6', 'CIDADAO', (SELECT ID FROM VB_BAIRRO WHERE NOME = 'Brasilândia'), SYSTIMESTAMP - NUMTODSINTERVAL(170, 'DAY'));
INSERT INTO VB_USUARIO (NOME, EMAIL, SENHA_HASH, PAPEL, BAIRRO_ID, DT_CADASTRO)
  VALUES ('Patrícia Nogueira', 'patricia.nogueira@vozdobairro.com', '$2a$10$Yo8Jrc6SrfqCEGZtaJFnReZPvqzVm5yvQpmwYdaTFgl78a5d17Ub6', 'CIDADAO', (SELECT ID FROM VB_BAIRRO WHERE NOME = 'Brasilândia'), SYSTIMESTAMP - NUMTODSINTERVAL(165, 'DAY'));
INSERT INTO VB_USUARIO (NOME, EMAIL, SENHA_HASH, PAPEL, BAIRRO_ID, DT_CADASTRO)
  VALUES ('Diego Martins Rocha', 'diego.rocha@vozdobairro.com', '$2a$10$Yo8Jrc6SrfqCEGZtaJFnReZPvqzVm5yvQpmwYdaTFgl78a5d17Ub6', 'CIDADAO', (SELECT ID FROM VB_BAIRRO WHERE NOME = 'Grajaú'), SYSTIMESTAMP - NUMTODSINTERVAL(160, 'DAY'));
INSERT INTO VB_USUARIO (NOME, EMAIL, SENHA_HASH, PAPEL, BAIRRO_ID, DT_CADASTRO)
  VALUES ('Camila Rodrigues', 'camila.rodrigues@vozdobairro.com', '$2a$10$Yo8Jrc6SrfqCEGZtaJFnReZPvqzVm5yvQpmwYdaTFgl78a5d17Ub6', 'CIDADAO', (SELECT ID FROM VB_BAIRRO WHERE NOME = 'Grajaú'), SYSTIMESTAMP - NUMTODSINTERVAL(158, 'DAY'));
INSERT INTO VB_USUARIO (NOME, EMAIL, SENHA_HASH, PAPEL, BAIRRO_ID, DT_CADASTRO)
  VALUES ('Thiago Pereira Alves', 'thiago.alves@vozdobairro.com', '$2a$10$Yo8Jrc6SrfqCEGZtaJFnReZPvqzVm5yvQpmwYdaTFgl78a5d17Ub6', 'CIDADAO', (SELECT ID FROM VB_BAIRRO WHERE NOME = 'Mooca'), SYSTIMESTAMP - NUMTODSINTERVAL(150, 'DAY'));
INSERT INTO VB_USUARIO (NOME, EMAIL, SENHA_HASH, PAPEL, BAIRRO_ID, DT_CADASTRO)
  VALUES ('Roberto Mendes', 'roberto.mendes@vozdobairro.com', '$2a$10$Yo8Jrc6SrfqCEGZtaJFnReZPvqzVm5yvQpmwYdaTFgl78a5d17Ub6', 'GESTOR', NULL, SYSTIMESTAMP - NUMTODSINTERVAL(210, 'DAY'));
INSERT INTO VB_USUARIO (NOME, EMAIL, SENHA_HASH, PAPEL, BAIRRO_ID, DT_CADASTRO)
  VALUES ('Sandra Lopes', 'sandra.lopes@vozdobairro.com', '$2a$10$Yo8Jrc6SrfqCEGZtaJFnReZPvqzVm5yvQpmwYdaTFgl78a5d17Ub6', 'GESTOR', NULL, SYSTIMESTAMP - NUMTODSINTERVAL(205, 'DAY'));

-- ---------------------------------------------------------------------
-- 3) Propostas. IDs 1 e 2 = seed do contrato (mesmo texto, META 30, ABERTA).
--    Propostas que já atingiram a meta em bairros com META_APOIOS_PADRAO alta
--    usam meta reduzida (piloto) para que TOTAL_APOIOS bata com VB_APOIO.
--    Regras: DEMANDA -> prazo futuro; ATRASADA -> prazo vencido sem resposta;
--    EM_EXECUCAO/RECUSADA/CONCLUIDA -> possuem VB_RESPOSTA.
-- ---------------------------------------------------------------------
-- #1 ABERTA (Capão Redondo)
INSERT INTO VB_PROPOSTA (TITULO, DESCRICAO, CATEGORIA, STATUS, META_APOIOS, TOTAL_APOIOS, AUTOR_ID, BAIRRO_ID, DT_CRIACAO, DT_VIROU_DEMANDA, PRAZO_RESPOSTA)
  VALUES ('Iluminação na Rua Agnaldo Macedo',
          'A rua fica totalmente escura à noite entre os números 100 e 400. Moradores voltando do trabalho e da escola se sentem inseguros.',
          'SEGURANCA', 'ABERTA', 30, 7, (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'cidadao@vozdobairro.com'), (SELECT ID FROM VB_BAIRRO WHERE NOME = 'Capão Redondo'),
          SYSTIMESTAMP - NUMTODSINTERVAL(12.3, 'DAY'), NULL, NULL);
-- #2 ABERTA (Capão Redondo)
INSERT INTO VB_PROPOSTA (TITULO, DESCRICAO, CATEGORIA, STATUS, META_APOIOS, TOTAL_APOIOS, AUTOR_ID, BAIRRO_ID, DT_CRIACAO, DT_VIROU_DEMANDA, PRAZO_RESPOSTA)
  VALUES ('Faixa de pedestre em frente à EMEF',
          'Crianças atravessam a avenida sem faixa nem semáforo na saída da escola. Já houve atropelamentos.',
          'MOBILIDADE', 'ABERTA', 30, 5, (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'vizinho@vozdobairro.com'), (SELECT ID FROM VB_BAIRRO WHERE NOME = 'Capão Redondo'),
          SYSTIMESTAMP - NUMTODSINTERVAL(10.6, 'DAY'), NULL, NULL);
-- #3 DEMANDA (Capão Redondo)
INSERT INTO VB_PROPOSTA (TITULO, DESCRICAO, CATEGORIA, STATUS, META_APOIOS, TOTAL_APOIOS, AUTOR_ID, BAIRRO_ID, DT_CRIACAO, DT_VIROU_DEMANDA, PRAZO_RESPOSTA)
  VALUES ('Reforma da quadra do CEU Capão Redondo',
          'A quadra poliesportiva está com o piso rachado e sem rede nas traves. Os jovens do bairro deixaram de usar o espaço nos fins de semana.',
          'LAZER', 'DEMANDA', 8, 9, (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'ana.ribeiro@vozdobairro.com'), (SELECT ID FROM VB_BAIRRO WHERE NOME = 'Capão Redondo'),
          SYSTIMESTAMP - NUMTODSINTERVAL(25.2, 'DAY'), SYSTIMESTAMP - NUMTODSINTERVAL(3.4, 'DAY'), SYSTIMESTAMP + NUMTODSINTERVAL(11.6, 'DAY'));
-- #4 ATRASADA (Capão Redondo)
INSERT INTO VB_PROPOSTA (TITULO, DESCRICAO, CATEGORIA, STATUS, META_APOIOS, TOTAL_APOIOS, AUTOR_ID, BAIRRO_ID, DT_CRIACAO, DT_VIROU_DEMANDA, PRAZO_RESPOSTA)
  VALUES ('UBS do Capão Redondo aberta aos sábados',
          'Quem trabalha durante a semana não consegue consultar nem vacinar os filhos. Pedimos atendimento aos sábados pela manhã na UBS.',
          'SAUDE', 'ATRASADA', 10, 10, (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'cidadao@vozdobairro.com'), (SELECT ID FROM VB_BAIRRO WHERE NOME = 'Capão Redondo'),
          SYSTIMESTAMP - NUMTODSINTERVAL(45.1, 'DAY'), SYSTIMESTAMP - NUMTODSINTERVAL(25.5, 'DAY'), SYSTIMESTAMP - NUMTODSINTERVAL(10.5, 'DAY'));
-- #5 EM_EXECUCAO (Capão Redondo)
INSERT INTO VB_PROPOSTA (TITULO, DESCRICAO, CATEGORIA, STATUS, META_APOIOS, TOTAL_APOIOS, AUTOR_ID, BAIRRO_ID, DT_CRIACAO, DT_VIROU_DEMANDA, PRAZO_RESPOSTA)
  VALUES ('Limpeza do córrego Pirajuçara-Mirim',
          'O córrego acumula lixo e entulho; em dias de chuva a água invade as casas da viela. Pedimos limpeza e caçambas para descarte.',
          'MEIO_AMBIENTE', 'EM_EXECUCAO', 8, 8, (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'vizinho@vozdobairro.com'), (SELECT ID FROM VB_BAIRRO WHERE NOME = 'Capão Redondo'),
          SYSTIMESTAMP - NUMTODSINTERVAL(60.3, 'DAY'), SYSTIMESTAMP - NUMTODSINTERVAL(40.2, 'DAY'), SYSTIMESTAMP - NUMTODSINTERVAL(25.2, 'DAY'));
-- #6 ABERTA (Vila Mariana)
INSERT INTO VB_PROPOSTA (TITULO, DESCRICAO, CATEGORIA, STATUS, META_APOIOS, TOTAL_APOIOS, AUTOR_ID, BAIRRO_ID, DT_CRIACAO, DT_VIROU_DEMANDA, PRAZO_RESPOSTA)
  VALUES ('Poda de árvores na Rua Domingos de Morais',
          'Galhos encostando na fiação elétrica e cobrindo a iluminação pública em vários trechos da calçada.',
          'ZELADORIA', 'ABERTA', 50, 4, (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'ricardo.almeida@vozdobairro.com'), (SELECT ID FROM VB_BAIRRO WHERE NOME = 'Vila Mariana'),
          SYSTIMESTAMP - NUMTODSINTERVAL(8.2, 'DAY'), NULL, NULL);
-- #7 RECUSADA (Vila Mariana)
INSERT INTO VB_PROPOSTA (TITULO, DESCRICAO, CATEGORIA, STATUS, META_APOIOS, TOTAL_APOIOS, AUTOR_ID, BAIRRO_ID, DT_CRIACAO, DT_VIROU_DEMANDA, PRAZO_RESPOSTA)
  VALUES ('Ciclofaixa na Rua Sena Madureira',
          'Muitos moradores vão de bicicleta até o metrô Vila Mariana disputando espaço com ônibus. Uma ciclofaixa ligaria o bairro à rede existente.',
          'MOBILIDADE', 'RECUSADA', 10, 11, (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'fernanda.costa@vozdobairro.com'), (SELECT ID FROM VB_BAIRRO WHERE NOME = 'Vila Mariana'),
          SYSTIMESTAMP - NUMTODSINTERVAL(70.4, 'DAY'), SYSTIMESTAMP - NUMTODSINTERVAL(50.3, 'DAY'), SYSTIMESTAMP - NUMTODSINTERVAL(35.3, 'DAY'));
-- #8 DEMANDA (Vila Mariana)
INSERT INTO VB_PROPOSTA (TITULO, DESCRICAO, CATEGORIA, STATUS, META_APOIOS, TOTAL_APOIOS, AUTOR_ID, BAIRRO_ID, DT_CRIACAO, DT_VIROU_DEMANDA, PRAZO_RESPOSTA)
  VALUES ('Rondas e iluminação na saída do metrô Santa Cruz',
          'À noite a saída lateral do metrô fica deserta e houve vários roubos de celular. Pedimos reforço de iluminação e rondas da GCM.',
          'SEGURANCA', 'DEMANDA', 10, 10, (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'ricardo.almeida@vozdobairro.com'), (SELECT ID FROM VB_BAIRRO WHERE NOME = 'Vila Mariana'),
          SYSTIMESTAMP - NUMTODSINTERVAL(20.5, 'DAY'), SYSTIMESTAMP - NUMTODSINTERVAL(2.2, 'DAY'), SYSTIMESTAMP + NUMTODSINTERVAL(12.8, 'DAY'));
-- #9 ATRASADA (Itaquera)
INSERT INTO VB_PROPOSTA (TITULO, DESCRICAO, CATEGORIA, STATUS, META_APOIOS, TOTAL_APOIOS, AUTOR_ID, BAIRRO_ID, DT_CRIACAO, DT_VIROU_DEMANDA, PRAZO_RESPOSTA)
  VALUES ('Cobertura nos pontos de ônibus da Av. Jacu-Pêssego',
          'Os pontos não têm cobertura nem banco; idosos esperam no sol e na chuva por mais de 30 minutos.',
          'MOBILIDADE', 'ATRASADA', 10, 11, (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'bruno.santos@vozdobairro.com'), (SELECT ID FROM VB_BAIRRO WHERE NOME = 'Itaquera'),
          SYSTIMESTAMP - NUMTODSINTERVAL(50.2, 'DAY'), SYSTIMESTAMP - NUMTODSINTERVAL(20.3, 'DAY'), SYSTIMESTAMP - NUMTODSINTERVAL(5.3, 'DAY'));
-- #10 CONCLUIDA (Itaquera)
INSERT INTO VB_PROPOSTA (TITULO, DESCRICAO, CATEGORIA, STATUS, META_APOIOS, TOTAL_APOIOS, AUTOR_ID, BAIRRO_ID, DT_CRIACAO, DT_VIROU_DEMANDA, PRAZO_RESPOSTA)
  VALUES ('Reabertura da biblioteca comunitária de Itaquera',
          'A biblioteca está fechada desde a pandemia. Estudantes não têm lugar para estudar nem acesso a computadores.',
          'EDUCACAO', 'CONCLUIDA', 8, 9, (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'juliana.lima@vozdobairro.com'), (SELECT ID FROM VB_BAIRRO WHERE NOME = 'Itaquera'),
          SYSTIMESTAMP - NUMTODSINTERVAL(120.5, 'DAY'), SYSTIMESTAMP - NUMTODSINTERVAL(100.2, 'DAY'), SYSTIMESTAMP - NUMTODSINTERVAL(85.2, 'DAY'));
-- #11 ABERTA (Itaquera)
INSERT INTO VB_PROPOSTA (TITULO, DESCRICAO, CATEGORIA, STATUS, META_APOIOS, TOTAL_APOIOS, AUTOR_ID, BAIRRO_ID, DT_CRIACAO, DT_VIROU_DEMANDA, PRAZO_RESPOSTA)
  VALUES ('Tapa-buracos na Rua Victório Santim',
          'Buracos grandes na pista causam acidentes com motos e danificam carros, principalmente perto do terminal.',
          'ZELADORIA', 'ABERTA', 40, 6, (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'bruno.santos@vozdobairro.com'), (SELECT ID FROM VB_BAIRRO WHERE NOME = 'Itaquera'),
          SYSTIMESTAMP - NUMTODSINTERVAL(6.4, 'DAY'), NULL, NULL);
-- #12 EM_EXECUCAO (Brasilândia)
INSERT INTO VB_PROPOSTA (TITULO, DESCRICAO, CATEGORIA, STATUS, META_APOIOS, TOTAL_APOIOS, AUTOR_ID, BAIRRO_ID, DT_CRIACAO, DT_VIROU_DEMANDA, PRAZO_RESPOSTA)
  VALUES ('Pediatra todos os dias na UBS Vila Brasilândia',
          'Hoje só há pediatra duas vezes por semana; as mães esperam semanas por consulta ou vão ao pronto-socorro.',
          'SAUDE', 'EM_EXECUCAO', 10, 10, (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'lucas.souza@vozdobairro.com'), (SELECT ID FROM VB_BAIRRO WHERE NOME = 'Brasilândia'),
          SYSTIMESTAMP - NUMTODSINTERVAL(40.3, 'DAY'), SYSTIMESTAMP - NUMTODSINTERVAL(30.2, 'DAY'), SYSTIMESTAMP - NUMTODSINTERVAL(15.2, 'DAY'));
-- #13 ABERTA (Brasilândia)
INSERT INTO VB_PROPOSTA (TITULO, DESCRICAO, CATEGORIA, STATUS, META_APOIOS, TOTAL_APOIOS, AUTOR_ID, BAIRRO_ID, DT_CRIACAO, DT_VIROU_DEMANDA, PRAZO_RESPOSTA)
  VALUES ('Coleta seletiva semanal na Brasilândia',
          'O caminhão da coleta seletiva não passa nas ruas de cima do morro; o reciclável acaba no lixo comum.',
          'MEIO_AMBIENTE', 'ABERTA', 10, 3, (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'patricia.nogueira@vozdobairro.com'), (SELECT ID FROM VB_BAIRRO WHERE NOME = 'Brasilândia'),
          SYSTIMESTAMP - NUMTODSINTERVAL(5.3, 'DAY'), NULL, NULL);
-- #14 DEMANDA (Brasilândia)
INSERT INTO VB_PROPOSTA (TITULO, DESCRICAO, CATEGORIA, STATUS, META_APOIOS, TOTAL_APOIOS, AUTOR_ID, BAIRRO_ID, DT_CRIACAO, DT_VIROU_DEMANDA, PRAZO_RESPOSTA)
  VALUES ('Iluminação da escadaria da Rua Parapuã',
          'A escadaria é o único acesso de muitas famílias ao ponto de ônibus e está sem nenhuma lâmpada funcionando.',
          'SEGURANCA', 'DEMANDA', 10, 10, (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'patricia.nogueira@vozdobairro.com'), (SELECT ID FROM VB_BAIRRO WHERE NOME = 'Brasilândia'),
          SYSTIMESTAMP - NUMTODSINTERVAL(15.4, 'DAY'), SYSTIMESTAMP - NUMTODSINTERVAL(1.3, 'DAY'), SYSTIMESTAMP + NUMTODSINTERVAL(13.7, 'DAY'));
-- #15 RECUSADA (Grajaú)
INSERT INTO VB_PROPOSTA (TITULO, DESCRICAO, CATEGORIA, STATUS, META_APOIOS, TOTAL_APOIOS, AUTOR_ID, BAIRRO_ID, DT_CRIACAO, DT_VIROU_DEMANDA, PRAZO_RESPOSTA)
  VALUES ('Linha de ônibus noturna Grajaú - Terminal Santo Amaro',
          'Quem trabalha até tarde não tem ônibus depois da meia-noite e precisa pagar aplicativo ou dormir no trabalho.',
          'MOBILIDADE', 'RECUSADA', 8, 8, (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'diego.rocha@vozdobairro.com'), (SELECT ID FROM VB_BAIRRO WHERE NOME = 'Grajaú'),
          SYSTIMESTAMP - NUMTODSINTERVAL(80.2, 'DAY'), SYSTIMESTAMP - NUMTODSINTERVAL(60.4, 'DAY'), SYSTIMESTAMP - NUMTODSINTERVAL(45.4, 'DAY'));
-- #16 CONCLUIDA (Grajaú)
INSERT INTO VB_PROPOSTA (TITULO, DESCRICAO, CATEGORIA, STATUS, META_APOIOS, TOTAL_APOIOS, AUTOR_ID, BAIRRO_ID, DT_CRIACAO, DT_VIROU_DEMANDA, PRAZO_RESPOSTA)
  VALUES ('Revitalização da Praça do Jardim Shangri-lá',
          'Brinquedos quebrados, mato alto e bancos destruídos. A praça é o único espaço de lazer para as crianças da região.',
          'LAZER', 'CONCLUIDA', 8, 8, (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'camila.rodrigues@vozdobairro.com'), (SELECT ID FROM VB_BAIRRO WHERE NOME = 'Grajaú'),
          SYSTIMESTAMP - NUMTODSINTERVAL(150.3, 'DAY'), SYSTIMESTAMP - NUMTODSINTERVAL(130.2, 'DAY'), SYSTIMESTAMP - NUMTODSINTERVAL(115.2, 'DAY'));
-- #17 ABERTA (Mooca)
INSERT INTO VB_PROPOSTA (TITULO, DESCRICAO, CATEGORIA, STATUS, META_APOIOS, TOTAL_APOIOS, AUTOR_ID, BAIRRO_ID, DT_CRIACAO, DT_VIROU_DEMANDA, PRAZO_RESPOSTA)
  VALUES ('Horta comunitária na Praça Kennedy',
          'Moradores querem transformar um canto sem uso da praça em horta comunitária, com apoio técnico da prefeitura.',
          'MEIO_AMBIENTE', 'ABERTA', 10, 2, (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'thiago.alves@vozdobairro.com'), (SELECT ID FROM VB_BAIRRO WHERE NOME = 'Mooca'),
          SYSTIMESTAMP - NUMTODSINTERVAL(4.2, 'DAY'), NULL, NULL);
-- #18 ABERTA (Capão Redondo)
INSERT INTO VB_PROPOSTA (TITULO, DESCRICAO, CATEGORIA, STATUS, META_APOIOS, TOTAL_APOIOS, AUTOR_ID, BAIRRO_ID, DT_CRIACAO, DT_VIROU_DEMANDA, PRAZO_RESPOSTA)
  VALUES ('Academia ao ar livre no Parque Santo Dias',
          'Pedimos aparelhos de ginástica ao ar livre perto da entrada do parque, muito procurada por idosos pela manhã.',
          'LAZER', 'ABERTA', 30, 2, (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'ana.ribeiro@vozdobairro.com'), (SELECT ID FROM VB_BAIRRO WHERE NOME = 'Capão Redondo'),
          SYSTIMESTAMP - NUMTODSINTERVAL(3.1, 'DAY'), NULL, NULL);

-- ---------------------------------------------------------------------
-- 4) Respostas da prefeitura (EM_EXECUCAO, RECUSADA, CONCLUIDA)
-- ---------------------------------------------------------------------
INSERT INTO VB_RESPOSTA (PROPOSTA_ID, GESTOR_ID, DECISAO, JUSTIFICATIVA, PRAZO_EXECUCAO, DT_RESPOSTA)
  VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Limpeza do córrego Pirajuçara-Mirim'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'gestor@vozdobairro.com'), 'ACEITA',
          'Limpeza incluída no cronograma da Subprefeitura do Campo Limpo, com caçambas por 30 dias.',
          TRUNC(SYSDATE) + 60, SYSTIMESTAMP - NUMTODSINTERVAL(30.1, 'DAY'));
INSERT INTO VB_RESPOSTA (PROPOSTA_ID, GESTOR_ID, DECISAO, JUSTIFICATIVA, PRAZO_EXECUCAO, DT_RESPOSTA)
  VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Ciclofaixa na Rua Sena Madureira'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'roberto.mendes@vozdobairro.com'), 'RECUSADA',
          'A via está no plano de requalificação da CET para 2027; a ciclofaixa será avaliada dentro desse projeto e não isoladamente.',
          NULL, SYSTIMESTAMP - NUMTODSINTERVAL(38.2, 'DAY'));
INSERT INTO VB_RESPOSTA (PROPOSTA_ID, GESTOR_ID, DECISAO, JUSTIFICATIVA, PRAZO_EXECUCAO, DT_RESPOSTA)
  VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Reabertura da biblioteca comunitária de Itaquera'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'sandra.lopes@vozdobairro.com'), 'ACEITA',
          'Reabertura aprovada com novo horário (9h às 20h) e 10 computadores doados pela Secretaria de Educação.',
          TRUNC(SYSDATE) - 60, SYSTIMESTAMP - NUMTODSINTERVAL(90.1, 'DAY'));
INSERT INTO VB_RESPOSTA (PROPOSTA_ID, GESTOR_ID, DECISAO, JUSTIFICATIVA, PRAZO_EXECUCAO, DT_RESPOSTA)
  VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Pediatra todos os dias na UBS Vila Brasilândia'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'gestor@vozdobairro.com'), 'ACEITA',
          'Contratação de dois pediatras aprovada; escala diária a partir do próximo mês.',
          TRUNC(SYSDATE) + 45, SYSTIMESTAMP - NUMTODSINTERVAL(12, 'DAY'));
INSERT INTO VB_RESPOSTA (PROPOSTA_ID, GESTOR_ID, DECISAO, JUSTIFICATIVA, PRAZO_EXECUCAO, DT_RESPOSTA)
  VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Linha de ônibus noturna Grajaú - Terminal Santo Amaro'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'roberto.mendes@vozdobairro.com'), 'RECUSADA',
          'A SPTrans informou que a linha noturna N632 já atende a região; será ampliada a divulgação dos horários.',
          NULL, SYSTIMESTAMP - NUMTODSINTERVAL(40.2, 'DAY'));
INSERT INTO VB_RESPOSTA (PROPOSTA_ID, GESTOR_ID, DECISAO, JUSTIFICATIVA, PRAZO_EXECUCAO, DT_RESPOSTA)
  VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Revitalização da Praça do Jardim Shangri-lá'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'sandra.lopes@vozdobairro.com'), 'ACEITA',
          'Revitalização incluída no programa de zeladoria: novos brinquedos, bancos e roçagem mensal.',
          TRUNC(SYSDATE) - 80, SYSTIMESTAMP - NUMTODSINTERVAL(120.4, 'DAY'));

-- ---------------------------------------------------------------------
-- 5) Apoios (a quantidade por proposta = TOTAL_APOIOS; autor não apoia a
--    própria proposta; usuários 1 e 2 não apoiam as propostas 1 e 2 do seed
--    para não conflitar com os testes das APIs)
-- ---------------------------------------------------------------------
-- proposta #1 - Iluminação na Rua Agnaldo Macedo (7 apoios)
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Iluminação na Rua Agnaldo Macedo'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'ana.ribeiro@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(10.5938, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Iluminação na Rua Agnaldo Macedo'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'bruno.santos@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(9.0875, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Iluminação na Rua Agnaldo Macedo'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'juliana.lima@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(7.5813, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Iluminação na Rua Agnaldo Macedo'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'ricardo.almeida@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(6.075, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Iluminação na Rua Agnaldo Macedo'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'fernanda.costa@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(4.5688, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Iluminação na Rua Agnaldo Macedo'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'lucas.souza@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(3.0625, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Iluminação na Rua Agnaldo Macedo'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'patricia.nogueira@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(1.5563, 'DAY'));
-- proposta #2 - Faixa de pedestre em frente à EMEF (5 apoios)
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Faixa de pedestre em frente à EMEF'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'ana.ribeiro@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(8.675, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Faixa de pedestre em frente à EMEF'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'bruno.santos@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(6.95, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Faixa de pedestre em frente à EMEF'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'juliana.lima@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(5.225, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Faixa de pedestre em frente à EMEF'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'ricardo.almeida@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(3.5, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Faixa de pedestre em frente à EMEF'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'fernanda.costa@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(1.775, 'DAY'));
-- proposta #3 - Reforma da quadra do CEU Capão Redondo (9 apoios)
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Reforma da quadra do CEU Capão Redondo'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'cidadao@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(22.3, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Reforma da quadra do CEU Capão Redondo'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'vizinho@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(19.6, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Reforma da quadra do CEU Capão Redondo'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'bruno.santos@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(16.9, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Reforma da quadra do CEU Capão Redondo'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'juliana.lima@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(14.2, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Reforma da quadra do CEU Capão Redondo'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'ricardo.almeida@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(11.5, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Reforma da quadra do CEU Capão Redondo'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'fernanda.costa@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(8.8, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Reforma da quadra do CEU Capão Redondo'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'lucas.souza@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(6.1, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Reforma da quadra do CEU Capão Redondo'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'patricia.nogueira@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(3.4, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Reforma da quadra do CEU Capão Redondo'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'diego.rocha@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(1.725, 'DAY'));
-- proposta #4 - UBS do Capão Redondo aberta aos sábados (10 apoios)
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'UBS do Capão Redondo aberta aos sábados'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'vizinho@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(42.96, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'UBS do Capão Redondo aberta aos sábados'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'ana.ribeiro@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(41.02, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'UBS do Capão Redondo aberta aos sábados'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'bruno.santos@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(39.08, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'UBS do Capão Redondo aberta aos sábados'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'juliana.lima@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(37.14, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'UBS do Capão Redondo aberta aos sábados'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'ricardo.almeida@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(35.2, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'UBS do Capão Redondo aberta aos sábados'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'fernanda.costa@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(33.26, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'UBS do Capão Redondo aberta aos sábados'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'lucas.souza@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(31.32, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'UBS do Capão Redondo aberta aos sábados'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'patricia.nogueira@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(29.38, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'UBS do Capão Redondo aberta aos sábados'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'diego.rocha@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(27.44, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'UBS do Capão Redondo aberta aos sábados'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'camila.rodrigues@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(25.5, 'DAY'));
-- proposta #5 - Limpeza do córrego Pirajuçara-Mirim (8 apoios)
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Limpeza do córrego Pirajuçara-Mirim'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'cidadao@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(57.6125, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Limpeza do córrego Pirajuçara-Mirim'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'ana.ribeiro@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(55.125, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Limpeza do córrego Pirajuçara-Mirim'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'bruno.santos@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(52.6375, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Limpeza do córrego Pirajuçara-Mirim'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'juliana.lima@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(50.15, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Limpeza do córrego Pirajuçara-Mirim'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'ricardo.almeida@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(47.6625, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Limpeza do córrego Pirajuçara-Mirim'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'fernanda.costa@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(45.175, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Limpeza do córrego Pirajuçara-Mirim'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'lucas.souza@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(42.6875, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Limpeza do córrego Pirajuçara-Mirim'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'patricia.nogueira@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(40.2, 'DAY'));
-- proposta #6 - Poda de árvores na Rua Domingos de Morais (4 apoios)
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Poda de árvores na Rua Domingos de Morais'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'fernanda.costa@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(6.41, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Poda de árvores na Rua Domingos de Morais'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'cidadao@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(4.82, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Poda de árvores na Rua Domingos de Morais'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'vizinho@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(3.23, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Poda de árvores na Rua Domingos de Morais'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'ana.ribeiro@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(1.64, 'DAY'));
-- proposta #7 - Ciclofaixa na Rua Sena Madureira (11 apoios)
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Ciclofaixa na Rua Sena Madureira'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'ricardo.almeida@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(68.21, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Ciclofaixa na Rua Sena Madureira'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'cidadao@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(66.22, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Ciclofaixa na Rua Sena Madureira'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'vizinho@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(64.23, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Ciclofaixa na Rua Sena Madureira'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'ana.ribeiro@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(62.24, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Ciclofaixa na Rua Sena Madureira'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'bruno.santos@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(60.25, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Ciclofaixa na Rua Sena Madureira'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'juliana.lima@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(58.26, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Ciclofaixa na Rua Sena Madureira'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'lucas.souza@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(56.27, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Ciclofaixa na Rua Sena Madureira'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'patricia.nogueira@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(54.28, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Ciclofaixa na Rua Sena Madureira'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'diego.rocha@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(52.29, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Ciclofaixa na Rua Sena Madureira'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'camila.rodrigues@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(50.3, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Ciclofaixa na Rua Sena Madureira'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'thiago.alves@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(44.25, 'DAY'));
-- proposta #8 - Rondas e iluminação na saída do metrô Santa Cruz (10 apoios)
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Rondas e iluminação na saída do metrô Santa Cruz'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'fernanda.costa@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(18.49, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Rondas e iluminação na saída do metrô Santa Cruz'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'cidadao@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(16.68, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Rondas e iluminação na saída do metrô Santa Cruz'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'vizinho@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(14.87, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Rondas e iluminação na saída do metrô Santa Cruz'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'ana.ribeiro@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(13.06, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Rondas e iluminação na saída do metrô Santa Cruz'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'bruno.santos@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(11.25, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Rondas e iluminação na saída do metrô Santa Cruz'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'juliana.lima@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(9.44, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Rondas e iluminação na saída do metrô Santa Cruz'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'lucas.souza@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(7.63, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Rondas e iluminação na saída do metrô Santa Cruz'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'patricia.nogueira@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(5.82, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Rondas e iluminação na saída do metrô Santa Cruz'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'diego.rocha@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(4.01, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Rondas e iluminação na saída do metrô Santa Cruz'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'camila.rodrigues@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(2.2, 'DAY'));
-- proposta #9 - Cobertura nos pontos de ônibus da Av. Jacu-Pêssego (11 apoios)
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Cobertura nos pontos de ônibus da Av. Jacu-Pêssego'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'juliana.lima@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(47.03, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Cobertura nos pontos de ônibus da Av. Jacu-Pêssego'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'cidadao@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(44.06, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Cobertura nos pontos de ônibus da Av. Jacu-Pêssego'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'vizinho@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(41.09, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Cobertura nos pontos de ônibus da Av. Jacu-Pêssego'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'ana.ribeiro@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(38.12, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Cobertura nos pontos de ônibus da Av. Jacu-Pêssego'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'ricardo.almeida@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(35.15, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Cobertura nos pontos de ônibus da Av. Jacu-Pêssego'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'fernanda.costa@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(32.18, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Cobertura nos pontos de ônibus da Av. Jacu-Pêssego'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'lucas.souza@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(29.21, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Cobertura nos pontos de ônibus da Av. Jacu-Pêssego'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'patricia.nogueira@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(26.24, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Cobertura nos pontos de ônibus da Av. Jacu-Pêssego'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'diego.rocha@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(23.27, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Cobertura nos pontos de ônibus da Av. Jacu-Pêssego'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'camila.rodrigues@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(20.3, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Cobertura nos pontos de ônibus da Av. Jacu-Pêssego'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'thiago.alves@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(10.175, 'DAY'));
-- proposta #10 - Reabertura da biblioteca comunitária de Itaquera (9 apoios)
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Reabertura da biblioteca comunitária de Itaquera'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'bruno.santos@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(117.787, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Reabertura da biblioteca comunitária de Itaquera'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'cidadao@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(115.275, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Reabertura da biblioteca comunitária de Itaquera'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'vizinho@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(112.763, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Reabertura da biblioteca comunitária de Itaquera'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'ana.ribeiro@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(110.25, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Reabertura da biblioteca comunitária de Itaquera'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'ricardo.almeida@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(107.737, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Reabertura da biblioteca comunitária de Itaquera'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'fernanda.costa@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(105.225, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Reabertura da biblioteca comunitária de Itaquera'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'lucas.souza@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(102.713, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Reabertura da biblioteca comunitária de Itaquera'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'patricia.nogueira@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(100.2, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Reabertura da biblioteca comunitária de Itaquera'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'diego.rocha@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(95.15, 'DAY'));
-- proposta #11 - Tapa-buracos na Rua Victório Santim (6 apoios)
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Tapa-buracos na Rua Victório Santim'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'juliana.lima@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(5.3214, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Tapa-buracos na Rua Victório Santim'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'cidadao@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(4.4429, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Tapa-buracos na Rua Victório Santim'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'vizinho@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(3.5643, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Tapa-buracos na Rua Victório Santim'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'ana.ribeiro@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(2.6857, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Tapa-buracos na Rua Victório Santim'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'ricardo.almeida@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(1.8071, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Tapa-buracos na Rua Victório Santim'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'fernanda.costa@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(0.9286, 'DAY'));
-- proposta #12 - Pediatra todos os dias na UBS Vila Brasilândia (10 apoios)
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Pediatra todos os dias na UBS Vila Brasilândia'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'patricia.nogueira@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(39.11, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Pediatra todos os dias na UBS Vila Brasilândia'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'cidadao@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(38.12, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Pediatra todos os dias na UBS Vila Brasilândia'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'vizinho@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(37.13, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Pediatra todos os dias na UBS Vila Brasilândia'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'ana.ribeiro@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(36.14, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Pediatra todos os dias na UBS Vila Brasilândia'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'bruno.santos@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(35.15, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Pediatra todos os dias na UBS Vila Brasilândia'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'juliana.lima@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(34.16, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Pediatra todos os dias na UBS Vila Brasilândia'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'ricardo.almeida@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(33.17, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Pediatra todos os dias na UBS Vila Brasilândia'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'fernanda.costa@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(32.18, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Pediatra todos os dias na UBS Vila Brasilândia'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'diego.rocha@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(31.19, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Pediatra todos os dias na UBS Vila Brasilândia'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'camila.rodrigues@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(30.2, 'DAY'));
-- proposta #13 - Coleta seletiva semanal na Brasilândia (3 apoios)
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Coleta seletiva semanal na Brasilândia'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'lucas.souza@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(3.8375, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Coleta seletiva semanal na Brasilândia'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'cidadao@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(2.575, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Coleta seletiva semanal na Brasilândia'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'vizinho@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(1.3125, 'DAY'));
-- proposta #14 - Iluminação da escadaria da Rua Parapuã (10 apoios)
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Iluminação da escadaria da Rua Parapuã'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'lucas.souza@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(13.81, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Iluminação da escadaria da Rua Parapuã'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'cidadao@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(12.42, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Iluminação da escadaria da Rua Parapuã'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'vizinho@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(11.03, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Iluminação da escadaria da Rua Parapuã'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'ana.ribeiro@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(9.64, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Iluminação da escadaria da Rua Parapuã'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'bruno.santos@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(8.25, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Iluminação da escadaria da Rua Parapuã'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'juliana.lima@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(6.86, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Iluminação da escadaria da Rua Parapuã'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'ricardo.almeida@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(5.47, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Iluminação da escadaria da Rua Parapuã'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'fernanda.costa@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(4.08, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Iluminação da escadaria da Rua Parapuã'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'diego.rocha@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(2.69, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Iluminação da escadaria da Rua Parapuã'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'camila.rodrigues@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(1.3, 'DAY'));
-- proposta #15 - Linha de ônibus noturna Grajaú - Terminal Santo Amaro (8 apoios)
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Linha de ônibus noturna Grajaú - Terminal Santo Amaro'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'camila.rodrigues@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(77.55, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Linha de ônibus noturna Grajaú - Terminal Santo Amaro'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'cidadao@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(75.1, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Linha de ônibus noturna Grajaú - Terminal Santo Amaro'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'vizinho@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(72.65, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Linha de ônibus noturna Grajaú - Terminal Santo Amaro'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'ana.ribeiro@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(70.2, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Linha de ônibus noturna Grajaú - Terminal Santo Amaro'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'bruno.santos@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(67.75, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Linha de ônibus noturna Grajaú - Terminal Santo Amaro'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'juliana.lima@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(65.3, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Linha de ônibus noturna Grajaú - Terminal Santo Amaro'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'ricardo.almeida@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(62.85, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Linha de ônibus noturna Grajaú - Terminal Santo Amaro'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'fernanda.costa@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(60.4, 'DAY'));
-- proposta #16 - Revitalização da Praça do Jardim Shangri-lá (8 apoios)
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Revitalização da Praça do Jardim Shangri-lá'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'diego.rocha@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(147.613, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Revitalização da Praça do Jardim Shangri-lá'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'cidadao@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(145.125, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Revitalização da Praça do Jardim Shangri-lá'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'vizinho@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(142.637, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Revitalização da Praça do Jardim Shangri-lá'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'ana.ribeiro@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(140.15, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Revitalização da Praça do Jardim Shangri-lá'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'bruno.santos@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(137.662, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Revitalização da Praça do Jardim Shangri-lá'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'juliana.lima@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(135.175, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Revitalização da Praça do Jardim Shangri-lá'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'ricardo.almeida@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(132.688, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Revitalização da Praça do Jardim Shangri-lá'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'fernanda.costa@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(130.2, 'DAY'));
-- proposta #17 - Horta comunitária na Praça Kennedy (2 apoios)
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Horta comunitária na Praça Kennedy'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'cidadao@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(2.6833, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Horta comunitária na Praça Kennedy'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'vizinho@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(1.3667, 'DAY'));
-- proposta #18 - Academia ao ar livre no Parque Santo Dias (2 apoios)
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Academia ao ar livre no Parque Santo Dias'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'cidadao@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(1.95, 'DAY'));
INSERT INTO VB_APOIO (PROPOSTA_ID, USUARIO_ID, DT_APOIO) VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Academia ao ar livre no Parque Santo Dias'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'vizinho@vozdobairro.com'), SYSTIMESTAMP - NUMTODSINTERVAL(1, 'DAY'));

-- ---------------------------------------------------------------------
-- 6) Comentários
-- ---------------------------------------------------------------------
INSERT INTO VB_COMENTARIO (PROPOSTA_ID, USUARIO_ID, TEXTO, DT_CRIACAO, DT_EDICAO)
  VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Iluminação na Rua Agnaldo Macedo'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'ana.ribeiro@vozdobairro.com'),
          'Apoio total! Minha filha volta do cursinho por essa rua e tem medo.', SYSTIMESTAMP - NUMTODSINTERVAL(11.8, 'DAY'), NULL);
INSERT INTO VB_COMENTARIO (PROPOSTA_ID, USUARIO_ID, TEXTO, DT_CRIACAO, DT_EDICAO)
  VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Iluminação na Rua Agnaldo Macedo'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'gestor@vozdobairro.com'),
          'Solicitação registrada. A Ilume vai fazer vistoria técnica no trecho.', SYSTIMESTAMP - NUMTODSINTERVAL(9.5, 'DAY'), NULL);
INSERT INTO VB_COMENTARIO (PROPOSTA_ID, USUARIO_ID, TEXTO, DT_CRIACAO, DT_EDICAO)
  VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Faixa de pedestre em frente à EMEF'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'cidadao@vozdobairro.com'),
          'Já vi duas crianças quase serem atropeladas na saída das 12h.', SYSTIMESTAMP - NUMTODSINTERVAL(10.1, 'DAY'), NULL);
INSERT INTO VB_COMENTARIO (PROPOSTA_ID, USUARIO_ID, TEXTO, DT_CRIACAO, DT_EDICAO)
  VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Reforma da quadra do CEU Capão Redondo'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'vizinho@vozdobairro.com'),
          'O CEU é o principal espaço de esporte dos jovens daqui. Precisa muito!', SYSTIMESTAMP - NUMTODSINTERVAL(20, 'DAY'), SYSTIMESTAMP - NUMTODSINTERVAL(19.5, 'DAY'));
INSERT INTO VB_COMENTARIO (PROPOSTA_ID, USUARIO_ID, TEXTO, DT_CRIACAO, DT_EDICAO)
  VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'UBS do Capão Redondo aberta aos sábados'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'ana.ribeiro@vozdobairro.com'),
          'Já passou do prazo e ninguém respondeu. Vamos cobrar!', SYSTIMESTAMP - NUMTODSINTERVAL(9, 'DAY'), NULL);
INSERT INTO VB_COMENTARIO (PROPOSTA_ID, USUARIO_ID, TEXTO, DT_CRIACAO, DT_EDICAO)
  VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Limpeza do córrego Pirajuçara-Mirim'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'cidadao@vozdobairro.com'),
          'As caçambas chegaram ontem, obrigado a todos que apoiaram.', SYSTIMESTAMP - NUMTODSINTERVAL(25, 'DAY'), NULL);
INSERT INTO VB_COMENTARIO (PROPOSTA_ID, USUARIO_ID, TEXTO, DT_CRIACAO, DT_EDICAO)
  VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Ciclofaixa na Rua Sena Madureira'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'ricardo.almeida@vozdobairro.com'),
          'Uma pena a recusa, vamos acompanhar o projeto da CET.', SYSTIMESTAMP - NUMTODSINTERVAL(37.5, 'DAY'), NULL);
INSERT INTO VB_COMENTARIO (PROPOSTA_ID, USUARIO_ID, TEXTO, DT_CRIACAO, DT_EDICAO)
  VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Rondas e iluminação na saída do metrô Santa Cruz'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'fernanda.costa@vozdobairro.com'),
          'Fui assaltada nessa saída mês passado. Apoiado.', SYSTIMESTAMP - NUMTODSINTERVAL(15, 'DAY'), NULL);
INSERT INTO VB_COMENTARIO (PROPOSTA_ID, USUARIO_ID, TEXTO, DT_CRIACAO, DT_EDICAO)
  VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Cobertura nos pontos de ônibus da Av. Jacu-Pêssego'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'juliana.lima@vozdobairro.com'),
          'Minha mãe tem 72 anos e espera o ônibus em pé no sol.', SYSTIMESTAMP - NUMTODSINTERVAL(30, 'DAY'), NULL);
INSERT INTO VB_COMENTARIO (PROPOSTA_ID, USUARIO_ID, TEXTO, DT_CRIACAO, DT_EDICAO)
  VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Reabertura da biblioteca comunitária de Itaquera'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'bruno.santos@vozdobairro.com'),
          'Biblioteca reaberta e cheia de estudantes. Deu certo!', SYSTIMESTAMP - NUMTODSINTERVAL(57, 'DAY'), NULL);
INSERT INTO VB_COMENTARIO (PROPOSTA_ID, USUARIO_ID, TEXTO, DT_CRIACAO, DT_EDICAO)
  VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Pediatra todos os dias na UBS Vila Brasilândia'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'patricia.nogueira@vozdobairro.com'),
          'Respondeu fora do prazo, mas pelo menos aceitaram.', SYSTIMESTAMP - NUMTODSINTERVAL(11.5, 'DAY'), NULL);
INSERT INTO VB_COMENTARIO (PROPOSTA_ID, USUARIO_ID, TEXTO, DT_CRIACAO, DT_EDICAO)
  VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Iluminação da escadaria da Rua Parapuã'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'lucas.souza@vozdobairro.com'),
          'Subo essa escadaria todo dia às 5h, no escuro total.', SYSTIMESTAMP - NUMTODSINTERVAL(10, 'DAY'), NULL);
INSERT INTO VB_COMENTARIO (PROPOSTA_ID, USUARIO_ID, TEXTO, DT_CRIACAO, DT_EDICAO)
  VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Linha de ônibus noturna Grajaú - Terminal Santo Amaro'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'camila.rodrigues@vozdobairro.com'),
          'A N632 não passa no nosso trecho, a resposta não resolve.', SYSTIMESTAMP - NUMTODSINTERVAL(39, 'DAY'), NULL);
INSERT INTO VB_COMENTARIO (PROPOSTA_ID, USUARIO_ID, TEXTO, DT_CRIACAO, DT_EDICAO)
  VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Revitalização da Praça do Jardim Shangri-lá'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'diego.rocha@vozdobairro.com'),
          'A praça ficou ótima, as crianças voltaram a brincar lá.', SYSTIMESTAMP - NUMTODSINTERVAL(75, 'DAY'), NULL);
INSERT INTO VB_COMENTARIO (PROPOSTA_ID, USUARIO_ID, TEXTO, DT_CRIACAO, DT_EDICAO)
  VALUES ((SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Horta comunitária na Praça Kennedy'), (SELECT ID FROM VB_USUARIO WHERE EMAIL = 'thiago.alves@vozdobairro.com'),
          'Posso doar mudas e ajudar no mutirão de sábado.', SYSTIMESTAMP - NUMTODSINTERVAL(3, 'DAY'), SYSTIMESTAMP - NUMTODSINTERVAL(2.8, 'DAY'));

-- ---------------------------------------------------------------------
-- 7) Notificações (autor + todos os GESTOR quando vira DEMANDA/ATRASADA;
--    autor quando há resposta/conclusão). Lidas = mais antigas que 7 dias.
-- ---------------------------------------------------------------------
INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM, LIDA, DT_CRIACAO)
  VALUES ((SELECT ID FROM VB_USUARIO WHERE EMAIL = 'ana.ribeiro@vozdobairro.com'), (SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Reforma da quadra do CEU Capão Redondo'),
          'Sua proposta "Reforma da quadra do CEU Capão Redondo" atingiu a meta de 8 apoios e virou DEMANDA. A prefeitura tem 15 dias para responder.', 0, SYSTIMESTAMP - NUMTODSINTERVAL(3.399, 'DAY'));
INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM, LIDA, DT_CRIACAO)
  SELECT u.ID, p.ID, 'Nova DEMANDA no bairro Capão Redondo: "Reforma da quadra do CEU Capão Redondo". Prazo de resposta de 15 dias.', 0, SYSTIMESTAMP - NUMTODSINTERVAL(3.399, 'DAY')
    FROM VB_USUARIO u CROSS JOIN VB_PROPOSTA p
   WHERE u.PAPEL = 'GESTOR' AND p.TITULO = 'Reforma da quadra do CEU Capão Redondo';
INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM, LIDA, DT_CRIACAO)
  VALUES ((SELECT ID FROM VB_USUARIO WHERE EMAIL = 'cidadao@vozdobairro.com'), (SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'UBS do Capão Redondo aberta aos sábados'),
          'Sua proposta "UBS do Capão Redondo aberta aos sábados" atingiu a meta de 10 apoios e virou DEMANDA. A prefeitura tem 15 dias para responder.', 1, SYSTIMESTAMP - NUMTODSINTERVAL(25.499, 'DAY'));
INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM, LIDA, DT_CRIACAO)
  SELECT u.ID, p.ID, 'Nova DEMANDA no bairro Capão Redondo: "UBS do Capão Redondo aberta aos sábados". Prazo de resposta de 15 dias.', 1, SYSTIMESTAMP - NUMTODSINTERVAL(25.499, 'DAY')
    FROM VB_USUARIO u CROSS JOIN VB_PROPOSTA p
   WHERE u.PAPEL = 'GESTOR' AND p.TITULO = 'UBS do Capão Redondo aberta aos sábados';
INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM, LIDA, DT_CRIACAO)
  VALUES ((SELECT ID FROM VB_USUARIO WHERE EMAIL = 'cidadao@vozdobairro.com'), (SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'UBS do Capão Redondo aberta aos sábados'),
          'O prazo de resposta da proposta "UBS do Capão Redondo aberta aos sábados" venceu sem resposta. Status: ATRASADA.', 1, SYSTIMESTAMP - NUMTODSINTERVAL(10.4, 'DAY'));
INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM, LIDA, DT_CRIACAO)
  SELECT u.ID, p.ID, 'Demanda ATRASADA: "UBS do Capão Redondo aberta aos sábados" (Capão Redondo) está sem resposta após o prazo.', 1, SYSTIMESTAMP - NUMTODSINTERVAL(10.4, 'DAY')
    FROM VB_USUARIO u CROSS JOIN VB_PROPOSTA p
   WHERE u.PAPEL = 'GESTOR' AND p.TITULO = 'UBS do Capão Redondo aberta aos sábados';
INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM, LIDA, DT_CRIACAO)
  VALUES ((SELECT ID FROM VB_USUARIO WHERE EMAIL = 'vizinho@vozdobairro.com'), (SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Limpeza do córrego Pirajuçara-Mirim'),
          'Sua proposta "Limpeza do córrego Pirajuçara-Mirim" atingiu a meta de 8 apoios e virou DEMANDA. A prefeitura tem 15 dias para responder.', 1, SYSTIMESTAMP - NUMTODSINTERVAL(40.199, 'DAY'));
INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM, LIDA, DT_CRIACAO)
  SELECT u.ID, p.ID, 'Nova DEMANDA no bairro Capão Redondo: "Limpeza do córrego Pirajuçara-Mirim". Prazo de resposta de 15 dias.', 1, SYSTIMESTAMP - NUMTODSINTERVAL(40.199, 'DAY')
    FROM VB_USUARIO u CROSS JOIN VB_PROPOSTA p
   WHERE u.PAPEL = 'GESTOR' AND p.TITULO = 'Limpeza do córrego Pirajuçara-Mirim';
INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM, LIDA, DT_CRIACAO)
  VALUES ((SELECT ID FROM VB_USUARIO WHERE EMAIL = 'vizinho@vozdobairro.com'), (SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Limpeza do córrego Pirajuçara-Mirim'),
          'A prefeitura respondeu sua proposta "Limpeza do córrego Pirajuçara-Mirim": ACEITA.', 1, SYSTIMESTAMP - NUMTODSINTERVAL(30.099, 'DAY'));
INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM, LIDA, DT_CRIACAO)
  VALUES ((SELECT ID FROM VB_USUARIO WHERE EMAIL = 'fernanda.costa@vozdobairro.com'), (SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Ciclofaixa na Rua Sena Madureira'),
          'Sua proposta "Ciclofaixa na Rua Sena Madureira" atingiu a meta de 10 apoios e virou DEMANDA. A prefeitura tem 15 dias para responder.', 1, SYSTIMESTAMP - NUMTODSINTERVAL(50.299, 'DAY'));
INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM, LIDA, DT_CRIACAO)
  SELECT u.ID, p.ID, 'Nova DEMANDA no bairro Vila Mariana: "Ciclofaixa na Rua Sena Madureira". Prazo de resposta de 15 dias.', 1, SYSTIMESTAMP - NUMTODSINTERVAL(50.299, 'DAY')
    FROM VB_USUARIO u CROSS JOIN VB_PROPOSTA p
   WHERE u.PAPEL = 'GESTOR' AND p.TITULO = 'Ciclofaixa na Rua Sena Madureira';
INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM, LIDA, DT_CRIACAO)
  VALUES ((SELECT ID FROM VB_USUARIO WHERE EMAIL = 'fernanda.costa@vozdobairro.com'), (SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Ciclofaixa na Rua Sena Madureira'),
          'A prefeitura respondeu sua proposta "Ciclofaixa na Rua Sena Madureira": RECUSADA.', 1, SYSTIMESTAMP - NUMTODSINTERVAL(38.199, 'DAY'));
INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM, LIDA, DT_CRIACAO)
  VALUES ((SELECT ID FROM VB_USUARIO WHERE EMAIL = 'ricardo.almeida@vozdobairro.com'), (SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Rondas e iluminação na saída do metrô Santa Cruz'),
          'Sua proposta "Rondas e iluminação na saída do metrô Santa Cruz" atingiu a meta de 10 apoios e virou DEMANDA. A prefeitura tem 15 dias para responder.', 0, SYSTIMESTAMP - NUMTODSINTERVAL(2.199, 'DAY'));
INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM, LIDA, DT_CRIACAO)
  SELECT u.ID, p.ID, 'Nova DEMANDA no bairro Vila Mariana: "Rondas e iluminação na saída do metrô Santa Cruz". Prazo de resposta de 15 dias.', 0, SYSTIMESTAMP - NUMTODSINTERVAL(2.199, 'DAY')
    FROM VB_USUARIO u CROSS JOIN VB_PROPOSTA p
   WHERE u.PAPEL = 'GESTOR' AND p.TITULO = 'Rondas e iluminação na saída do metrô Santa Cruz';
INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM, LIDA, DT_CRIACAO)
  VALUES ((SELECT ID FROM VB_USUARIO WHERE EMAIL = 'bruno.santos@vozdobairro.com'), (SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Cobertura nos pontos de ônibus da Av. Jacu-Pêssego'),
          'Sua proposta "Cobertura nos pontos de ônibus da Av. Jacu-Pêssego" atingiu a meta de 10 apoios e virou DEMANDA. A prefeitura tem 15 dias para responder.', 1, SYSTIMESTAMP - NUMTODSINTERVAL(20.299, 'DAY'));
INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM, LIDA, DT_CRIACAO)
  SELECT u.ID, p.ID, 'Nova DEMANDA no bairro Itaquera: "Cobertura nos pontos de ônibus da Av. Jacu-Pêssego". Prazo de resposta de 15 dias.', 1, SYSTIMESTAMP - NUMTODSINTERVAL(20.299, 'DAY')
    FROM VB_USUARIO u CROSS JOIN VB_PROPOSTA p
   WHERE u.PAPEL = 'GESTOR' AND p.TITULO = 'Cobertura nos pontos de ônibus da Av. Jacu-Pêssego';
INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM, LIDA, DT_CRIACAO)
  VALUES ((SELECT ID FROM VB_USUARIO WHERE EMAIL = 'bruno.santos@vozdobairro.com'), (SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Cobertura nos pontos de ônibus da Av. Jacu-Pêssego'),
          'O prazo de resposta da proposta "Cobertura nos pontos de ônibus da Av. Jacu-Pêssego" venceu sem resposta. Status: ATRASADA.', 0, SYSTIMESTAMP - NUMTODSINTERVAL(5.2, 'DAY'));
INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM, LIDA, DT_CRIACAO)
  SELECT u.ID, p.ID, 'Demanda ATRASADA: "Cobertura nos pontos de ônibus da Av. Jacu-Pêssego" (Itaquera) está sem resposta após o prazo.', 0, SYSTIMESTAMP - NUMTODSINTERVAL(5.2, 'DAY')
    FROM VB_USUARIO u CROSS JOIN VB_PROPOSTA p
   WHERE u.PAPEL = 'GESTOR' AND p.TITULO = 'Cobertura nos pontos de ônibus da Av. Jacu-Pêssego';
INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM, LIDA, DT_CRIACAO)
  VALUES ((SELECT ID FROM VB_USUARIO WHERE EMAIL = 'juliana.lima@vozdobairro.com'), (SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Reabertura da biblioteca comunitária de Itaquera'),
          'Sua proposta "Reabertura da biblioteca comunitária de Itaquera" atingiu a meta de 8 apoios e virou DEMANDA. A prefeitura tem 15 dias para responder.', 1, SYSTIMESTAMP - NUMTODSINTERVAL(100.199, 'DAY'));
INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM, LIDA, DT_CRIACAO)
  SELECT u.ID, p.ID, 'Nova DEMANDA no bairro Itaquera: "Reabertura da biblioteca comunitária de Itaquera". Prazo de resposta de 15 dias.', 1, SYSTIMESTAMP - NUMTODSINTERVAL(100.199, 'DAY')
    FROM VB_USUARIO u CROSS JOIN VB_PROPOSTA p
   WHERE u.PAPEL = 'GESTOR' AND p.TITULO = 'Reabertura da biblioteca comunitária de Itaquera';
INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM, LIDA, DT_CRIACAO)
  VALUES ((SELECT ID FROM VB_USUARIO WHERE EMAIL = 'juliana.lima@vozdobairro.com'), (SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Reabertura da biblioteca comunitária de Itaquera'),
          'A prefeitura respondeu sua proposta "Reabertura da biblioteca comunitária de Itaquera": ACEITA.', 1, SYSTIMESTAMP - NUMTODSINTERVAL(90.099, 'DAY'));
INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM, LIDA, DT_CRIACAO)
  VALUES ((SELECT ID FROM VB_USUARIO WHERE EMAIL = 'juliana.lima@vozdobairro.com'), (SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Reabertura da biblioteca comunitária de Itaquera'),
          'A proposta "Reabertura da biblioteca comunitária de Itaquera" foi CONCLUÍDA. Obrigado pela participação!', 1, SYSTIMESTAMP - NUMTODSINTERVAL(58, 'DAY'));
INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM, LIDA, DT_CRIACAO)
  VALUES ((SELECT ID FROM VB_USUARIO WHERE EMAIL = 'lucas.souza@vozdobairro.com'), (SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Pediatra todos os dias na UBS Vila Brasilândia'),
          'Sua proposta "Pediatra todos os dias na UBS Vila Brasilândia" atingiu a meta de 10 apoios e virou DEMANDA. A prefeitura tem 15 dias para responder.', 1, SYSTIMESTAMP - NUMTODSINTERVAL(30.199, 'DAY'));
INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM, LIDA, DT_CRIACAO)
  SELECT u.ID, p.ID, 'Nova DEMANDA no bairro Brasilândia: "Pediatra todos os dias na UBS Vila Brasilândia". Prazo de resposta de 15 dias.', 1, SYSTIMESTAMP - NUMTODSINTERVAL(30.199, 'DAY')
    FROM VB_USUARIO u CROSS JOIN VB_PROPOSTA p
   WHERE u.PAPEL = 'GESTOR' AND p.TITULO = 'Pediatra todos os dias na UBS Vila Brasilândia';
INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM, LIDA, DT_CRIACAO)
  VALUES ((SELECT ID FROM VB_USUARIO WHERE EMAIL = 'lucas.souza@vozdobairro.com'), (SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Pediatra todos os dias na UBS Vila Brasilândia'),
          'O prazo de resposta da proposta "Pediatra todos os dias na UBS Vila Brasilândia" venceu sem resposta. Status: ATRASADA.', 1, SYSTIMESTAMP - NUMTODSINTERVAL(15.1, 'DAY'));
INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM, LIDA, DT_CRIACAO)
  SELECT u.ID, p.ID, 'Demanda ATRASADA: "Pediatra todos os dias na UBS Vila Brasilândia" (Brasilândia) está sem resposta após o prazo.', 1, SYSTIMESTAMP - NUMTODSINTERVAL(15.1, 'DAY')
    FROM VB_USUARIO u CROSS JOIN VB_PROPOSTA p
   WHERE u.PAPEL = 'GESTOR' AND p.TITULO = 'Pediatra todos os dias na UBS Vila Brasilândia';
INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM, LIDA, DT_CRIACAO)
  VALUES ((SELECT ID FROM VB_USUARIO WHERE EMAIL = 'lucas.souza@vozdobairro.com'), (SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Pediatra todos os dias na UBS Vila Brasilândia'),
          'A prefeitura respondeu sua proposta "Pediatra todos os dias na UBS Vila Brasilândia": ACEITA.', 1, SYSTIMESTAMP - NUMTODSINTERVAL(11.999, 'DAY'));
INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM, LIDA, DT_CRIACAO)
  VALUES ((SELECT ID FROM VB_USUARIO WHERE EMAIL = 'patricia.nogueira@vozdobairro.com'), (SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Iluminação da escadaria da Rua Parapuã'),
          'Sua proposta "Iluminação da escadaria da Rua Parapuã" atingiu a meta de 10 apoios e virou DEMANDA. A prefeitura tem 15 dias para responder.', 0, SYSTIMESTAMP - NUMTODSINTERVAL(1.299, 'DAY'));
INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM, LIDA, DT_CRIACAO)
  SELECT u.ID, p.ID, 'Nova DEMANDA no bairro Brasilândia: "Iluminação da escadaria da Rua Parapuã". Prazo de resposta de 15 dias.', 0, SYSTIMESTAMP - NUMTODSINTERVAL(1.299, 'DAY')
    FROM VB_USUARIO u CROSS JOIN VB_PROPOSTA p
   WHERE u.PAPEL = 'GESTOR' AND p.TITULO = 'Iluminação da escadaria da Rua Parapuã';
INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM, LIDA, DT_CRIACAO)
  VALUES ((SELECT ID FROM VB_USUARIO WHERE EMAIL = 'diego.rocha@vozdobairro.com'), (SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Linha de ônibus noturna Grajaú - Terminal Santo Amaro'),
          'Sua proposta "Linha de ônibus noturna Grajaú - Terminal Santo Amaro" atingiu a meta de 8 apoios e virou DEMANDA. A prefeitura tem 15 dias para responder.', 1, SYSTIMESTAMP - NUMTODSINTERVAL(60.399, 'DAY'));
INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM, LIDA, DT_CRIACAO)
  SELECT u.ID, p.ID, 'Nova DEMANDA no bairro Grajaú: "Linha de ônibus noturna Grajaú - Terminal Santo Amaro". Prazo de resposta de 15 dias.', 1, SYSTIMESTAMP - NUMTODSINTERVAL(60.399, 'DAY')
    FROM VB_USUARIO u CROSS JOIN VB_PROPOSTA p
   WHERE u.PAPEL = 'GESTOR' AND p.TITULO = 'Linha de ônibus noturna Grajaú - Terminal Santo Amaro';
INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM, LIDA, DT_CRIACAO)
  VALUES ((SELECT ID FROM VB_USUARIO WHERE EMAIL = 'diego.rocha@vozdobairro.com'), (SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Linha de ônibus noturna Grajaú - Terminal Santo Amaro'),
          'O prazo de resposta da proposta "Linha de ônibus noturna Grajaú - Terminal Santo Amaro" venceu sem resposta. Status: ATRASADA.', 1, SYSTIMESTAMP - NUMTODSINTERVAL(45.3, 'DAY'));
INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM, LIDA, DT_CRIACAO)
  SELECT u.ID, p.ID, 'Demanda ATRASADA: "Linha de ônibus noturna Grajaú - Terminal Santo Amaro" (Grajaú) está sem resposta após o prazo.', 1, SYSTIMESTAMP - NUMTODSINTERVAL(45.3, 'DAY')
    FROM VB_USUARIO u CROSS JOIN VB_PROPOSTA p
   WHERE u.PAPEL = 'GESTOR' AND p.TITULO = 'Linha de ônibus noturna Grajaú - Terminal Santo Amaro';
INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM, LIDA, DT_CRIACAO)
  VALUES ((SELECT ID FROM VB_USUARIO WHERE EMAIL = 'diego.rocha@vozdobairro.com'), (SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Linha de ônibus noturna Grajaú - Terminal Santo Amaro'),
          'A prefeitura respondeu sua proposta "Linha de ônibus noturna Grajaú - Terminal Santo Amaro": RECUSADA.', 1, SYSTIMESTAMP - NUMTODSINTERVAL(40.199, 'DAY'));
INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM, LIDA, DT_CRIACAO)
  VALUES ((SELECT ID FROM VB_USUARIO WHERE EMAIL = 'camila.rodrigues@vozdobairro.com'), (SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Revitalização da Praça do Jardim Shangri-lá'),
          'Sua proposta "Revitalização da Praça do Jardim Shangri-lá" atingiu a meta de 8 apoios e virou DEMANDA. A prefeitura tem 15 dias para responder.', 1, SYSTIMESTAMP - NUMTODSINTERVAL(130.199, 'DAY'));
INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM, LIDA, DT_CRIACAO)
  SELECT u.ID, p.ID, 'Nova DEMANDA no bairro Grajaú: "Revitalização da Praça do Jardim Shangri-lá". Prazo de resposta de 15 dias.', 1, SYSTIMESTAMP - NUMTODSINTERVAL(130.199, 'DAY')
    FROM VB_USUARIO u CROSS JOIN VB_PROPOSTA p
   WHERE u.PAPEL = 'GESTOR' AND p.TITULO = 'Revitalização da Praça do Jardim Shangri-lá';
INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM, LIDA, DT_CRIACAO)
  VALUES ((SELECT ID FROM VB_USUARIO WHERE EMAIL = 'camila.rodrigues@vozdobairro.com'), (SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Revitalização da Praça do Jardim Shangri-lá'),
          'A prefeitura respondeu sua proposta "Revitalização da Praça do Jardim Shangri-lá": ACEITA.', 1, SYSTIMESTAMP - NUMTODSINTERVAL(120.399, 'DAY'));
INSERT INTO VB_NOTIFICACAO (USUARIO_ID, PROPOSTA_ID, MENSAGEM, LIDA, DT_CRIACAO)
  VALUES ((SELECT ID FROM VB_USUARIO WHERE EMAIL = 'camila.rodrigues@vozdobairro.com'), (SELECT ID FROM VB_PROPOSTA WHERE TITULO = 'Revitalização da Praça do Jardim Shangri-lá'),
          'A proposta "Revitalização da Praça do Jardim Shangri-lá" foi CONCLUÍDA. Obrigado pela participação!', 1, SYSTIMESTAMP - NUMTODSINTERVAL(78.3, 'DAY'));

COMMIT;

-- ---------------------------------------------------------------------
-- Conferências (devem retornar os valores indicados)
-- ---------------------------------------------------------------------
-- a) TOTAL_APOIOS x contagem real em VB_APOIO -> esperado: nenhuma linha
SELECT p.ID, p.TITULO, p.TOTAL_APOIOS, COUNT(a.ID) AS APOIOS_REAIS
  FROM VB_PROPOSTA p LEFT JOIN VB_APOIO a ON a.PROPOSTA_ID = p.ID
 GROUP BY p.ID, p.TITULO, p.TOTAL_APOIOS
HAVING p.TOTAL_APOIOS <> COUNT(a.ID);

-- b) Quantidades carregadas
--    esperado: BAIRROS=6 USUARIOS=15 PROPOSTAS=18 RESPOSTAS=6 APOIOS=133 COMENTARIOS=15 NOTIFICACOES=68
SELECT (SELECT COUNT(*) FROM VB_BAIRRO)      AS BAIRROS,
       (SELECT COUNT(*) FROM VB_USUARIO)     AS USUARIOS,
       (SELECT COUNT(*) FROM VB_PROPOSTA)    AS PROPOSTAS,
       (SELECT COUNT(*) FROM VB_RESPOSTA)    AS RESPOSTAS,
       (SELECT COUNT(*) FROM VB_APOIO)       AS APOIOS,
       (SELECT COUNT(*) FROM VB_COMENTARIO)  AS COMENTARIOS,
       (SELECT COUNT(*) FROM VB_NOTIFICACAO) AS NOTIFICACOES
  FROM DUAL;
