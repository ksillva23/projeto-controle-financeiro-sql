-- =========================================
-- CRIAÇÃO DO BANCO DE DADOS
-- =========================================

-- Cria o banco de dados para controle financeiro
CREATE DATABASE controle_financeiro;

-- Define o banco de dados ativo
USE controle_financeiro;

-- =========================================
-- CRIAÇÃO DAS TABELAS
-- =========================================

-- Tabela responsável por armazenar as contas financeiras
-- Ex: banco, carteira, cartão de crédito
CREATE TABLE contas (
    id_conta INT PRIMARY KEY,
    nome_conta VARCHAR(100),
    tipo_conta VARCHAR(100)
);

-- Tabela de categorias das transações
-- O campo "tipo" define se é Receita ou Despesa
CREATE TABLE categorias (
    id_categoria INT PRIMARY KEY,
    nome_categoria VARCHAR(100),
    tipo VARCHAR(50)
);

-- Tabela principal de transações financeiras
-- Relaciona contas e categorias através de chaves estrangeiras
CREATE TABLE transacoes (
    id_transacao INT PRIMARY KEY,
    data DATE,
    descricao VARCHAR(200),
    valor DECIMAL(10,2),
    id_categoria INT,
    id_conta INT,
    FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria),
    FOREIGN KEY (id_conta) REFERENCES contas(id_conta)
);

-- =========================================
-- INSERÇÃO DE DADOS
-- =========================================

-- Inserindo dados de contas
INSERT INTO contas (id_conta, nome_conta, tipo_conta)
VALUES
(1, 'Banco Principal', 'Corrente'),
(2, 'Carteira', 'Dinheiro'),
(3, 'Cartão Crédito', 'Crédito');

-- Verificação dos dados inseridos
SELECT * FROM contas;

-- Inserindo categorias de receitas e despesas
INSERT INTO categorias (id_categoria, nome_categoria, tipo)
VALUES
(1, 'Salário', 'Receita'),
(2, 'Freelance', 'Receita'),
(3, 'Alimentação', 'Despesa'),
(4, 'Aluguel', 'Despesa'),
(5, 'Transporte', 'Despesa'),
(6, 'Lazer', 'Despesa');

-- Verificação das categorias
SELECT * FROM categorias;

-- Inserindo transações financeiras simuladas (Janeiro a Março)
INSERT INTO transacoes (id_transacao, data, descricao, valor, id_categoria, id_conta)
VALUES
(1, '2025-01-05', 'Salário', 3000, 1, 1),
(2, '2025-01-10', 'Aluguel', 900, 4, 1),
(3, '2025-01-12', 'Supermercado', 250, 3, 3),
(4, '2025-01-14', 'Transporte', 120, 5, 1),
(5, '2025-01-18', 'Lanche', 40, 3, 2),
(6, '2025-01-20', 'Cinema', 80, 6, 3),
(7, '2025-01-25', 'Freelance', 400, 2, 1),
(8, '2025-02-05', 'Salário', 3000, 1, 1),
(9, '2025-02-08', 'Freelance', 250, 2, 1),
(10, '2025-02-10', 'Aluguel', 900, 4, 1),
(11, '2025-02-12', 'Supermercado', 270, 3, 3),
(12, '2025-02-14', 'Transporte', 110, 5, 1),
(13, '2025-02-18', 'Restaurante', 95, 3, 3),
(14, '2025-02-22', 'Streaming', 40, 6, 1),
(15, '2025-03-05', 'Salário', 3000, 1, 1),
(16, '2025-03-10', 'Aluguel', 900, 4, 1),
(17, '2025-03-11', 'Supermercado', 300, 3, 3),
(18, '2025-03-13', 'Transporte', 130, 5, 1),
(19, '2025-03-16', 'Freelance', 350, 2, 1),
(20, '2025-03-18', 'Lanche', 50, 3, 2),
(21, '2025-03-25', 'Cinema', 90, 6, 3);

-- Visualização geral das transações
SELECT * FROM transacoes;

-- =========================================
-- CONSULTAS DE ANÁLISE
-- =========================================

-- Filtrando transações de um período específico (Março)
SELECT *
FROM transacoes
WHERE data BETWEEN '2025-03-01' AND '2025-03-31';

-- Relacionando transações com categorias
SELECT *
FROM transacoes t
JOIN categorias c
ON t.id_categoria = c.id_categoria;

-- Exibindo detalhes das transações com tipo (Receita/Despesa)
SELECT
    t.data,
    t.descricao,
    t.valor,
    c.nome_categoria,
    c.tipo
FROM transacoes t
JOIN categorias c
ON t.id_categoria = c.id_categoria;

-- Total de receitas
SELECT SUM(t.valor) AS total_receitas
FROM transacoes t
JOIN categorias c
ON t.id_categoria = c.id_categoria
WHERE c.tipo = 'Receita';

-- Total de despesas
SELECT SUM(t.valor) AS total_despesas
FROM transacoes t
JOIN categorias c
ON t.id_categoria = c.id_categoria
WHERE c.tipo = 'Despesa';

-- Cálculo do saldo final (Receitas - Despesas)
SELECT
(SELECT SUM(t.valor)
 FROM transacoes t
 JOIN categorias c ON t.id_categoria = c.id_categoria
 WHERE c.tipo = 'Receita')
-
(SELECT SUM(t.valor)
 FROM transacoes t
 JOIN categorias c ON t.id_categoria = c.id_categoria
 WHERE c.tipo = 'Despesa')
AS saldo_final;

-- =========================================
-- ANÁLISES AGRUPADAS
-- =========================================

-- Total de despesas por categoria
SELECT c.nome_categoria, SUM(t.valor) AS total_despesas
FROM transacoes t
JOIN categorias c
ON t.id_categoria = c.id_categoria
WHERE c.tipo = 'Despesa'
GROUP BY c.nome_categoria;

-- Total de receitas por categoria
SELECT c.nome_categoria, SUM(t.valor) AS total_receitas
FROM transacoes t
JOIN categorias c
ON t.id_categoria = c.id_categoria
WHERE c.tipo = 'Receita'
GROUP BY c.nome_categoria;

-- Total mensal de despesas
SELECT MONTH(data) AS 'Mês', SUM(t.valor) AS total_despesas
FROM transacoes t
GROUP BY MONTH(data);

-- Total mensal separado por tipo (Receita / Despesa)
SELECT
    MONTH(data) AS 'Mês',
    c.tipo,
    SUM(t.valor) AS total
FROM transacoes t
JOIN categorias c
ON t.id_categoria = c.id_categoria
GROUP BY MONTH(data), c.tipo;

-- Receita, despesa e saldo mensal usando CASE
SELECT
    MONTH(data) AS 'Mês',
    SUM(CASE WHEN c.tipo = 'Receita' THEN t.valor ELSE 0 END) AS total_receitas,
    SUM(CASE WHEN c.tipo = 'Despesa' THEN t.valor ELSE 0 END) AS total_despesas,
    SUM(CASE WHEN c.tipo = 'Receita' THEN t.valor ELSE 0 END) -
    SUM(CASE WHEN c.tipo = 'Despesa' THEN t.valor ELSE 0 END) AS saldo
FROM transacoes t
JOIN categorias c
ON t.id_categoria = c.id_categoria
GROUP BY MONTH(data);