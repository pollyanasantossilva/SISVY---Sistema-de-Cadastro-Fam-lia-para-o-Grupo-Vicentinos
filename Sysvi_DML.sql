-- DML - Manipulação de dados do SysVi
-- Os parâmetros @nome, @ficha etc. são preenchidos pela aplicação via MySqlCommand.
-- Para executar manualmente no MySQL Workbench, substitua os parâmetros por valores válidos.

USE grupo_vicentinos;

-- 1. Dados iniciais (script de carga inicial enviado pela equipe)
INSERT INTO conferencias (id, nome, ativa)
VALUES (1, 'Santa Cruz', 1);

-- Os hashes abaixo são os valores presentes no script de carga inicial.
-- As senhas em texto não são armazenadas diretamente; a aplicação usa BCrypt.
INSERT INTO usuarios (id, usuario, senha_hash, ativo, perfil)
VALUES
(1, 'administrador', '$2a$11$30N2F5W9LgxOUvknsCcxle2ujemLvh8Es3tTfzieZdbnBd2P8Kk5.', 1, 'ADMIN'),
(2, 'consulta', '$2a$11$6S4wsODGuzQJGnMUDEOAP.XKl5gXXGda7dOionYUkTzxiR7dp9eE2', 1, 'CONSULTA');

INSERT INTO controle_numeracao_fichas (id) VALUES (1);

-- 2. Criação de usuário (UsuarioService.CriarUsuario)
INSERT INTO usuarios (usuario, senha_hash, perfil, ativo)
VALUES (@usuario, @senha_hash, @perfil, TRUE);

-- 3. Reserva de ficha (FamiliaService.ReservarFicha)
INSERT INTO ficha_sindicancia (conferencia_id, usuario_id, numero_ficha)
VALUES (@conferencia_id, @usuario_id, @numero_ficha);

-- 4. Cadastro dos dados da família (FamiliaService.SalvarDadosFamilia)
INSERT INTO dados_familia
(ficha_numero, nome_completo, idade, cpf, rg, endereco, numero, bairro,
 naturalidade, profissao, emprego, possui_conjuge, possui_dependentes)
VALUES
(@ficha, @nome, @idade, @cpf, @rg, @endereco, @numero, @bairro,
 @naturalidade, @profissao, @emprego, @conjuge, @dependentes);

-- 5. Cadastro do cônjuge (FamiliaService.SalvarConjuge)
INSERT INTO dados_conjuge
(ficha_numero, nome_completo, idade, cpf, rg, naturalidade, bairro,
 profissao, estado_civil, pretende_casar_civil, pretende_casar_igreja)
VALUES
(@ficha, @nome, @idade, @cpf, @rg, @naturalidade, @bairro,
 @profissao, @estado_civil, @casar_civil, @casar_igreja);

-- 6. Cadastro dos dependentes (FamiliaService.SalvarDependentes)
INSERT INTO dependentes (ficha_numero, nome, idade, sexo, parentesco)
VALUES (@ficha, @nome, @idade, @sexo, @parentesco);

-- 7. Informações religiosas (FamiliaService.SalvarReligiao)
INSERT INTO informacoes_religiosas
(ficha_numero, catolicos, praticantes, alguem_sem_batismo,
 alguem_primeira_eucaristia, quantidade_primeira_eucaristia)
VALUES (@ficha, @catolicos, @praticantes, @batismo, @eucaristia, @quantidade);

-- 8. Situação financeira (FamiliaService.SalvarFinanceiro)
INSERT INTO situacao_financeira
(ficha_numero, qtd_pessoas_trabalham, renda_familiar, casa_propria,
 valor_aluguel, paga_prestacao, qual_prestacao, prestacao_valor)
VALUES (@ficha, @trabalham, @renda, @casa, @aluguel, @prestacao, @qual, @valor);

-- 9. Auxílio e saúde (FamiliaService.SalvarSaude)
INSERT INTO auxilio_saude
(ficha_numero, recebe_auxilio, qual_auxilio, ha_doentes, quem,
 assistencia_medica, onde)
VALUES (@ficha, @auxilio, @qual, @doentes, @quem, @assistencia, @onde);

-- 10. Admissão e visita (FamiliaService.SalvarAdmissao)
INSERT INTO admissao_visita
(ficha_numero, necessita_ser_adotada, ate_quando, admitida_em,
 foi_promovida, prazo_indeterminado)
VALUES (@ficha, @adotada, @prazo, @admissao, @promovida, @indeterminado);

-- 11. Dados da sindicância (FamiliaService.SalvarSindicancia)
INSERT INTO sindicancia (ficha_numero, feita_por, data_sindicancia, observacoes)
VALUES (@ficha, @feita_por, @data, @observacoes);

-- 12. Atualização da ficha durante a edição (FamiliaService.Atualizar)
UPDATE ficha_sindicancia
SET conferencia_id = @conferencia_id,
    ultima_atualizacao = CURRENT_TIMESTAMP
WHERE ficha_numero = @ficha_id
  AND excluida_em IS NULL;

-- 13. Exclusão dos dados complementares antes de gravar novamente na edição.
-- A aplicação executa estes DELETEs dentro de uma transação e depois reinsere os dados.
DELETE FROM dependentes WHERE ficha_numero = @ficha_id;
DELETE FROM dados_conjuge WHERE ficha_numero = @ficha_id;
DELETE FROM informacoes_religiosas WHERE ficha_numero = @ficha_id;
DELETE FROM situacao_financeira WHERE ficha_numero = @ficha_id;
DELETE FROM auxilio_saude WHERE ficha_numero = @ficha_id;
DELETE FROM admissao_visita WHERE ficha_numero = @ficha_id;
DELETE FROM sindicancia WHERE ficha_numero = @ficha_id;
DELETE FROM dados_familia WHERE ficha_numero = @ficha_id;

-- 14. Cancelamento de uma reserva ainda sem cadastro familiar (FamiliaService.CancelarReserva)
DELETE FROM ficha_sindicancia
WHERE ficha_numero = @ficha_id
  AND NOT EXISTS (
      SELECT 1
      FROM dados_familia
      WHERE dados_familia.ficha_numero = ficha_sindicancia.ficha_numero
  );

-- 15. Exclusão lógica de uma família (FamiliaService.ExcluirFamilia)
-- Os dados são preservados para permitir consultas posteriores.
UPDATE ficha_sindicancia
SET excluida_em = CURRENT_TIMESTAMP
WHERE ficha_numero = @ficha_id
  AND excluida_em IS NULL
  AND EXISTS (
      SELECT 1
      FROM dados_familia
      WHERE dados_familia.ficha_numero = ficha_sindicancia.ficha_numero
  );
