-- DDL - Definição da estrutura do banco de dados SysVi
-- Cria o banco, as tabelas, chaves, índices e views.

CREATE DATABASE IF NOT EXISTS `grupo_vicentinos`
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

USE `grupo_vicentinos`;


CREATE TABLE `conferencias` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `ativa` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `nome` (`nome`)
) ENGINE=InnoDB;

CREATE TABLE `usuarios` (
  `id` int NOT NULL AUTO_INCREMENT,
  `usuario` varchar(100) NOT NULL,
  `senha_hash` varchar(255) NOT NULL,
  `ativo` tinyint(1) NOT NULL DEFAULT '1',
  `perfil` enum('CONSULTA','ADMIN') NOT NULL DEFAULT 'CONSULTA',
  PRIMARY KEY (`id`),
  UNIQUE KEY `usuario` (`usuario`)
) ENGINE=InnoDB;



CREATE TABLE `controle_numeracao_fichas` (
  `id` tinyint NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;


CREATE TABLE `ficha_sindicancia` (
  `ficha_numero` int NOT NULL AUTO_INCREMENT,
  `conferencia_id` int NOT NULL,
  `usuario_id` int DEFAULT NULL,
  `ultima_atualizacao` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `excluida_em` datetime DEFAULT NULL,
  `numero_ficha` int unsigned DEFAULT NULL,
  PRIMARY KEY (`ficha_numero`),
  UNIQUE KEY `uk_numero_ficha` (`numero_ficha`),
  KEY `idx_ficha_atualizacao` (`ultima_atualizacao`),
  KEY `fk_ficha_conferencia` (`conferencia_id`),
  KEY `fk_ficha_usuario` (`usuario_id`),
  CONSTRAINT `fk_ficha_conferencia` FOREIGN KEY (`conferencia_id`) REFERENCES `conferencias` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_ficha_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;


CREATE TABLE `dados_familia` (
  `ficha_numero` int NOT NULL,
  `nome_completo` varchar(150) NOT NULL,
  `idade` smallint unsigned NOT NULL,
  `cpf` char(11) NOT NULL,
  `rg` varchar(20) DEFAULT NULL,
  `endereco` varchar(200) NOT NULL,
  `numero` varchar(10) DEFAULT NULL,
  `bairro` varchar(100) NOT NULL,
  `naturalidade` varchar(50) NOT NULL,
  `profissao` varchar(100) NOT NULL,
  `emprego` varchar(100) DEFAULT NULL,
  `possui_conjuge` char(1) DEFAULT NULL,
  `possui_dependentes` char(1) DEFAULT NULL,
  PRIMARY KEY (`ficha_numero`),
  UNIQUE KEY `uq_dados_familia_cpf` (`cpf`),
  KEY `idx_dados_familia_nome` (`nome_completo`),
  CONSTRAINT `fk_dados_familia_ficha` FOREIGN KEY (`ficha_numero`) REFERENCES `ficha_sindicancia` (`ficha_numero`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;


CREATE TABLE `dados_conjuge` (
  `ficha_numero` int NOT NULL,
  `nome_completo` varchar(150) DEFAULT NULL,
  `idade` smallint unsigned DEFAULT NULL,
  `cpf` char(11) DEFAULT NULL,
  `rg` varchar(20) DEFAULT NULL,
  `naturalidade` varchar(100) DEFAULT NULL,
  `bairro` varchar(100) DEFAULT NULL,
  `profissao` varchar(100) DEFAULT NULL,
  `estado_civil` varchar(30) DEFAULT NULL,
  `pretende_casar_civil` char(1) DEFAULT NULL,
  `pretende_casar_igreja` char(1) DEFAULT NULL,
  PRIMARY KEY (`ficha_numero`),
  UNIQUE KEY `uq_dados_conjuge_cpf` (`cpf`),
  CONSTRAINT `fk_dados_conjuge_ficha` FOREIGN KEY (`ficha_numero`) REFERENCES `ficha_sindicancia` (`ficha_numero`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;


CREATE TABLE `dependentes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `ficha_numero` int NOT NULL,
  `nome` varchar(150) DEFAULT NULL,
  `idade` decimal(4,1) unsigned DEFAULT NULL,
  `sexo` varchar(20) DEFAULT NULL,
  `parentesco` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_dependentes_ficha` (`ficha_numero`),
  CONSTRAINT `fk_dependentes_ficha` FOREIGN KEY (`ficha_numero`) REFERENCES `ficha_sindicancia` (`ficha_numero`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;



CREATE TABLE `informacoes_religiosas` (
  `ficha_numero` int NOT NULL,
  `catolicos` char(1) DEFAULT NULL,
  `praticantes` char(1) DEFAULT NULL,
  `alguem_sem_batismo` char(1) DEFAULT NULL,
  `alguem_primeira_eucaristia` char(1) DEFAULT NULL,
  `quantidade_primeira_eucaristia` smallint unsigned DEFAULT NULL,
  PRIMARY KEY (`ficha_numero`),
  CONSTRAINT `fk_religiosa_ficha` FOREIGN KEY (`ficha_numero`) REFERENCES `ficha_sindicancia` (`ficha_numero`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;


CREATE TABLE `situacao_financeira` (
  `ficha_numero` int NOT NULL,
  `qtd_pessoas_trabalham` smallint unsigned DEFAULT NULL,
  `renda_familiar` decimal(10,2) unsigned DEFAULT NULL,
  `casa_propria` char(1) DEFAULT NULL,
  `valor_aluguel` decimal(10,2) unsigned DEFAULT NULL,
  `paga_prestacao` char(1) DEFAULT NULL,
  `qual_prestacao` varchar(150) DEFAULT NULL,
  `prestacao_valor` decimal(10,2) unsigned DEFAULT NULL,
  PRIMARY KEY (`ficha_numero`),
  CONSTRAINT `fk_financeira_ficha` FOREIGN KEY (`ficha_numero`) REFERENCES `ficha_sindicancia` (`ficha_numero`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;



CREATE TABLE `auxilio_saude` (
  `ficha_numero` int NOT NULL,
  `recebe_auxilio` char(1) DEFAULT NULL,
  `qual_auxilio` varchar(200) DEFAULT NULL,
  `ha_doentes` char(1) DEFAULT NULL,
  `quem` varchar(255) DEFAULT NULL,
  `assistencia_medica` char(1) DEFAULT NULL,
  `onde` varchar(150) DEFAULT NULL,
  PRIMARY KEY (`ficha_numero`),
  CONSTRAINT `fk_auxilio_saude_ficha` FOREIGN KEY (`ficha_numero`) REFERENCES `ficha_sindicancia` (`ficha_numero`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;



CREATE TABLE `admissao_visita` (
  `ficha_numero` int NOT NULL,
  `necessita_ser_adotada` char(1) DEFAULT NULL,
  `ate_quando` date DEFAULT NULL,
  `admitida_em` date DEFAULT NULL,
  `foi_promovida` char(1) DEFAULT NULL,
  `prazo_indeterminado` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ficha_numero`),
  CONSTRAINT `fk_admissao_ficha` FOREIGN KEY (`ficha_numero`) REFERENCES `ficha_sindicancia` (`ficha_numero`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;



CREATE TABLE `sindicancia` (
  `ficha_numero` int NOT NULL,
  `feita_por` varchar(255) DEFAULT NULL,
  `data_sindicancia` date DEFAULT NULL,
  `observacoes` text,
  PRIMARY KEY (`ficha_numero`),
  CONSTRAINT `fk_sindicancia_ficha` FOREIGN KEY (`ficha_numero`) REFERENCES `ficha_sindicancia` (`ficha_numero`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;



CREATE  VIEW `vw_busca_todas_familias` AS select 
`f`.`ficha_numero` AS `ficha_numero`,
`f`.`numero_ficha` AS `numero_ficha`,
`df`.`nome_completo` AS `nome_atendido`,
`df`.`cpf` AS `cpf`,`df`.`idade` AS `idade`,
`df`.`bairro` AS `bairro`,
`c`.`nome` AS `conferencia`,
`f`.`ultima_atualizacao` AS `ultima_atualizacao`,
`f`.`excluida_em` AS `excluida_em`,
(case when (`f`.`excluida_em` is null) then 'ATIVA' else 'EXCLUÍDA' end) AS `situacao` 
from ((`ficha_sindicancia` `f` join `dados_familia` `df` 
on((`df`.`ficha_numero` = `f`.`ficha_numero`))) 
join `conferencias` `c` 
on((`c`.`id` = `f`.`conferencia_id`)));


CREATE  VIEW `vw_dados_completos_familia` AS select 
`fs`.`ficha_numero` AS `ficha_numero`,
`fs`.`conferencia_id` AS `conferencia_id`,
`fs`.`usuario_id` AS `usuario_id`,
`fs`.`ultima_atualizacao` AS `ultima_atualizacao`,
`fs`.`excluida_em` AS `excluida_em`,
`df`.`nome_completo` AS `nome_atendido`,
`df`.`idade` AS `idade_atendido`,
`df`.`cpf` AS `cpf_atendido`,
`df`.`rg` AS `rg_atendido`,
`df`.`endereco` AS `endereco`,
`df`.`numero` AS `numero`,
`df`.`bairro` AS `bairro_atendido`,
`df`.`naturalidade` AS `naturalidade_atendido`,
`df`.`profissao` AS `profissao_atendido`,
`df`.`emprego` AS `emprego`,
`df`.`possui_conjuge` AS `possui_conjuge`,
`df`.`possui_dependentes` AS `possui_dependentes`,
`dc`.`nome_completo` AS `nome_conjuge`,
`dc`.`idade` AS `idade_conjuge`,
`dc`.`cpf` AS `cpf_conjuge`,
`dc`.`rg` AS `rg_conjuge`,
`dc`.`naturalidade` AS `naturalidade_conjuge`,
`dc`.`bairro` AS `bairro_conjuge`,
`dc`.`profissao` AS `profissao_conjuge`,
`dc`.`estado_civil` AS `estado_civil`,
`dc`.`pretende_casar_civil` AS `pretende_casar_civil`,
`dc`.`pretende_casar_igreja` AS `pretende_casar_igreja`,
`dep`.`id` AS `dependente_id`,
`dep`.`nome` AS `nome_dependente`,
`dep`.`idade` AS `idade_dependente`,
`dep`.`sexo` AS `sexo_dependente`,
`dep`.`parentesco` AS `parentesco`,
`ir`.`catolicos` AS `catolicos`,
`ir`.`praticantes` AS `praticantes`,
`ir`.`alguem_sem_batismo` AS `alguem_sem_batismo`,
`ir`.`alguem_primeira_eucaristia` AS `alguem_primeira_eucaristia`,
`ir`.`quantidade_primeira_eucaristia` AS `quantidade_primeira_eucaristia`,
`sf`.`qtd_pessoas_trabalham` AS `qtd_pessoas_trabalham`,
`sf`.`renda_familiar` AS `renda_familiar`,
`sf`.`casa_propria` AS `casa_propria`,
`sf`.`valor_aluguel` AS `valor_aluguel`,
`sf`.`paga_prestacao` AS `paga_prestacao`,
`sf`.`qual_prestacao` AS `qual_prestacao`,
`sf`.`prestacao_valor` AS `prestacao_valor`,
`aus`.`recebe_auxilio` AS `recebe_auxilio`,
`aus`.`qual_auxilio` AS `qual_auxilio`,
`aus`.`ha_doentes` AS `ha_doentes`,
`aus`.`quem` AS `quem`,
`aus`.`assistencia_medica` AS `assistencia_medica`,
`aus`.`onde` AS `onde`,
`av`.`necessita_ser_adotada` AS `necessita_ser_adotada`,
`av`.`ate_quando` AS `ate_quando`,
`av`.`admitida_em` AS `admitida_em`,
`av`.`foi_promovida` AS `foi_promovida`,
`av`.`prazo_indeterminado` AS `prazo_indeterminado`,
`si`.`feita_por` AS `feita_por`,
`si`.`data_sindicancia` AS `data_sindicancia`,
`si`.`observacoes` AS `observacoes` 
from ((((((((`ficha_sindicancia` `fs` join `dados_familia` `df` 
on((`fs`.`ficha_numero` = `df`.`ficha_numero`))) 
left join `dados_conjuge` `dc` 
on((`fs`.`ficha_numero` = `dc`.`ficha_numero`))) 
left join `dependentes` `dep` 
on((`fs`.`ficha_numero` = `dep`.`ficha_numero`))) 
left join `informacoes_religiosas` `ir` 
on((`fs`.`ficha_numero` = `ir`.`ficha_numero`))) 
left join `situacao_financeira` `sf` 
on((`fs`.`ficha_numero` = `sf`.`ficha_numero`))) 
left join `auxilio_saude` `aus` 
on((`fs`.`ficha_numero` = `aus`.`ficha_numero`))) 
left join `admissao_visita` `av` 
on((`fs`.`ficha_numero` = `av`.`ficha_numero`))) 
left join `sindicancia` `si` 
on((`fs`.`ficha_numero` = `si`.`ficha_numero`)));



INSERT INTO `conferencias` VALUES (1,'Santa Cruz',1);

INSERT INTO `usuarios` VALUES
(1,'administrador','$2a$11$30N2F5W9LgxOUvknsCcxle2ujemLvh8Es3tTfzieZdbnBd2P8Kk5.',1,'ADMIN'),
(2,'consulta','$2a$11$6S4wsODGuzQJGnMUDEOAP.XKl5gXXGda7dOionYUkTzxiR7dp9eE2',1,'CONSULTA');

INSERT INTO `controle_numeracao_fichas` VALUES (1);
