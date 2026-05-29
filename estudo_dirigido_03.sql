-- ====================================================================
-- ESTUDO DIRIGIDO 03: PADRONIZAÇÃO DE BANCO DE DADOS
-- Sistema: E-commerce / Nexus Vendas
-- ====================================================================

-- Criação do banco padronizado
DROP DATABASE IF EXISTS ecommerce_padrao;
CREATE DATABASE ecommerce_padrao;
USE ecommerce_padrao;

-- ====================================================================
-- REGRAS APLICADAS NESTE SCRIPT:
-- 1. Nomenclatura: Tabelas no singular e minúsculas (cliente, produto).
-- 2. Nomenclatura PK/FK: Padrão 'id_nomeDaTabela'.
-- 3. Tipos de Dados: Uso correto de CHAR, DECIMAL e DATETIME.
-- 4. Integridade: PKs com AUTO_INCREMENT e FKs restritivas.
-- 5. Normalização (1FN): Telefones separados em tabela associativa.
-- ====================================================================

-- Tabela Cliente
CREATE TABLE cliente (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf CHAR(11) UNIQUE NOT NULL COMMENT 'CHAR(11) padroniza e economiza espaço',
    email VARCHAR(100) UNIQUE NOT NULL,
    data_cadastro DATE DEFAULT (CURRENT_DATE)
);

-- Tabela de Telefones (Aplicação da 1FN - Evita múltiplos valores em uma coluna)
CREATE TABLE telefone_cliente (
    id_telefone INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    numero VARCHAR(15) NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente) ON DELETE CASCADE
);

-- Tabela Produto
CREATE TABLE produto (
    id_produto INT AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(150) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    preco_base DECIMAL(10,2) NOT NULL COMMENT 'DECIMAL garante precisão monetária',
    CONSTRAINT chk_preco_produto CHECK (preco_base >= 0)
);

-- Tabela Venda
CREATE TABLE venda (
    id_venda INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    data_venda DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'DATETIME necessário para rastrear hora da venda',
    valor_total DECIMAL(10,2) DEFAULT 0,
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
);

-- Tabela Item Venda (Tabela associativa / Aplicação da 3FN)
CREATE TABLE item_venda (
    id_item INT AUTO_INCREMENT PRIMARY KEY,
    id_venda INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL,
    FOREIGN KEY (id_venda) REFERENCES venda(id_venda) ON DELETE CASCADE,
    FOREIGN KEY (id_produto) REFERENCES produto(id_produto),
    CONSTRAINT chk_quantidade CHECK (quantidade > 0)
);

-- ====================================================================
-- ÍNDICES (Otimização de Buscas)
-- ====================================================================
CREATE INDEX idx_cliente_email ON cliente(email);
CREATE INDEX idx_produto_categoria ON produto(categoria);

-- ====================================================================
-- SEGURANÇA E CONTROLE DE ACESSO (DCL)
-- ====================================================================
-- Remove usuário se existir para evitar erro
DROP USER IF EXISTS 'analista_vendas'@'localhost';

-- Criação de usuário com criptografia de senha nativa do MySQL
CREATE USER 'analista_vendas'@'localhost' IDENTIFIED BY 'SenhaForte123!';

-- Concessão do Princípio do Privilégio Mínimo
GRANT SELECT ON ecommerce_padrao.cliente TO 'analista_vendas'@'localhost';
GRANT SELECT, INSERT ON ecommerce_padrao.venda TO 'analista_vendas'@'localhost';

FLUSH PRIVILEGES;
