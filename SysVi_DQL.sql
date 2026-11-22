-- DQL - Consultas utilizadas pelo SysVi
-- Os parâmetros @... são preenchidos pela aplicação C#.

USE grupo_vicentinos;

-- 1. Verifica se já existem usuários (UsuarioService.CriarUsuariosIniciais)
SELECT COUNT(*) FROM usuarios;

-- 2. Consulta usuário para autenticação (UsuarioService.ValidarLogin)
SELECT id, usuario, senha_hash, perfil, ativo
FROM usuarios
WHERE usuario = @usuario
LIMIT 1;

-- 3. Localiza a conferência ativa (FamiliaService.ObterConferencia)
SELECT id
FROM conferencias
WHERE nome = @nome
  AND ativa = TRUE
LIMIT 1;

-- 4. Verifica se a reserva da ficha existe e está ativa (FamiliaService.Salvar)
SELECT COUNT(*)
FROM ficha_sindicancia
WHERE ficha_numero = @ficha_id
  AND numero_ficha = @numero_ficha
  AND excluida_em IS NULL;

-- 5. Recupera os dados completos da família (FamiliaService.ObterFamiliaCompleta)
SELECT
    fs.ficha_numero,
    fs.numero_ficha,
    fs.conferencia_id,
    fs.usuario_id,
    df.nome_completo AS nome_atendido,
    df.idade AS idade_atendido,
    df.cpf AS cpf_atendido,
    df.rg AS rg_atendido,
    df.endereco,
    df.numero,
    df.bairro AS bairro_atendido,
    df.naturalidade AS naturalidade_atendido,
    df.profissao AS profissao_atendido,
    df.emprego,
    df.possui_conjuge,
    df.possui_dependentes,
    dc.nome_completo AS nome_conjuge,
    dc.idade AS idade_conjuge,
    dc.cpf AS cpf_conjuge,
    dc.rg AS rg_conjuge,
    dc.naturalidade AS naturalidade_conjuge,
    dc.bairro AS bairro_conjuge,
    dc.profissao AS profissao_conjuge,
    dc.estado_civil,
    dc.pretende_casar_civil,
    dc.pretende_casar_igreja,
    ir.catolicos,
    ir.praticantes,
    ir.alguem_sem_batismo,
    ir.alguem_primeira_eucaristia,
    ir.quantidade_primeira_eucaristia,
    sf.qtd_pessoas_trabalham,
    sf.renda_familiar,
    sf.casa_propria,
    sf.valor_aluguel,
    sf.paga_prestacao,
    sf.qual_prestacao,
    sf.prestacao_valor,
    aus.recebe_auxilio,
    aus.qual_auxilio,
    aus.ha_doentes,
    aus.quem,
    aus.assistencia_medica,
    aus.onde,
    av.necessita_ser_adotada,
    av.admitida_em,
    av.ate_quando,
    av.foi_promovida,
    av.prazo_indeterminado,
    si.feita_por,
    si.data_sindicancia,
    si.observacoes
FROM ficha_sindicancia fs
INNER JOIN dados_familia df
    ON df.ficha_numero = fs.ficha_numero
LEFT JOIN dados_conjuge dc
    ON dc.ficha_numero = fs.ficha_numero
LEFT JOIN informacoes_religiosas ir
    ON ir.ficha_numero = fs.ficha_numero
LEFT JOIN situacao_financeira sf
    ON sf.ficha_numero = fs.ficha_numero
LEFT JOIN auxilio_saude aus
    ON aus.ficha_numero = fs.ficha_numero
LEFT JOIN admissao_visita av
    ON av.ficha_numero = fs.ficha_numero
LEFT JOIN sindicancia si
    ON si.ficha_numero = fs.ficha_numero
WHERE fs.ficha_numero = @ficha_id;

-- 6. Recupera dependentes da família (FamiliaService.ObterFamiliaCompleta)
SELECT nome, idade, sexo, parentesco
FROM dependentes
WHERE ficha_numero = @ficha_id
ORDER BY id;

-- 7. Pesquisa famílias pelo nome, incluindo ativas e excluídas (BuscarNome.PesquisarFamilias)
SELECT
    ficha_numero AS id_interno,
    numero_ficha,
    nome_atendido,
    cpf,
    idade,
    bairro,
    ultima_atualizacao,
    situacao
FROM vw_busca_todas_familias
WHERE nome_atendido LIKE @nome
ORDER BY nome_atendido;

-- 8. Pesquisa famílias pelo CPF, incluindo ativas e excluídas (BuscarCpf.PesquisarFamilias)
SELECT
    ficha_numero AS id_interno,
    numero_ficha,
    nome_atendido,
    cpf,
    idade,
    bairro,
    ultima_atualizacao,
    situacao
FROM vw_busca_todas_familias
WHERE cpf = @cpf
ORDER BY nome_atendido;

-- 9. Bloqueia o registro de controle de numeração durante a reserva (FOR UPDATE)
SELECT id
FROM controle_numeracao_fichas
WHERE id = 1
FOR UPDATE;

-- 10. Obtém os números de ficha já utilizados para localizar o próximo número livre
SELECT numero_ficha
FROM ficha_sindicancia
WHERE numero_ficha IS NOT NULL
ORDER BY numero_ficha;

-- 11. Verifica a existência de ficha antes da atualização (FamiliaService.Atualizar)
SELECT COUNT(*)
FROM ficha_sindicancia
WHERE ficha_numero = @ficha_id
  AND numero_ficha = @numero_ficha
  AND excluida_em IS NULL;
