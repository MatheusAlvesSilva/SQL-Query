SELECT
    f.Placa,
    a.AutoInfracao AS AIT,
    cok.CONTRATO_NRO,
    a.MultaID,
    convert(DATETIME, a.DataInfracao) AS DataInfracao,
    convert(DATETIME, a.DataLancamento) AS Datalancamento,
    v.ValorNominal,
    fi.Loja AS Loja_retirada,
    lol.REGIONAL as regional,
    a.Vencimento as data_Vencimento,
    pe.RazaoSocial AS nome_empresa,
    b.Orgao,
    us.Login AS Usu_Abertura,
    us.SAP as Matricula,
    estaInfra.Status as Status_dt_Infracao,
    ms.MStatus as Status_Vetor,
    con.DataA as Data_abertura,
    e.Status as Status_Atual,
    Motivo.Motivo,
    Pende.DataMotivo,
	ImpeUser.Nome,
    CASE 
        WHEN contrato.StatusID=0 Then  'Cancelado' 
        WHEN contrato.StatusID=1 Then  'Aberto'
        WHEN contrato.StatusID=2 Then  'Devolvido'
        WHEN contrato.StatusID=3 Then  'Encerrado'
    End as Status_Contrato,
    CASE 
        WHEN contrato.Modalidade=1 Then  'Eventual' 
        WHEN contrato.Modalidade=2 Then  'Mensal'
        WHEN contrato.Modalidade=3 Then  'Mensal Flex'
        WHEN contrato.Modalidade=4 Then  'Carsharing'
    End as Modalidade_Contrato
FROM 
    data_stage_vetor_racsn.dbo.M003_Pendencias AS Pende 
    LEFT JOIN data_stage_vetor_racsn.dbo.M003_MULTAS AS a ON a.MultaID = Pende.multaiD
    LEFT JOIN data_stage_vetor_racsn.dbo.M005_MOTIVOSNAOINDICACAO as Motivo on Pende.MotivoID = Motivo.MotivosNaoIndicacaoID
    LEFT JOIN data_stage_vetor_racsn.dbo.M004_ORGAOS AS b ON a.OrgaoID = b.OrgaoID
    LEFT JOIN data_stage_vetor_racsn.dbo.M003_MULTAS_A as c on a.MultaID = c.M003_Multas_MultaID
    LEFT JOIN data_stage_vetor_racsn.dbo.F001_FROTAS AS f ON a.FrotaID = f.FrotaID
    LEFT JOIN (SELECT
        a.*
        FROM data_stage_vetor_racsn.dbo.F022_MOVIMENTACOES AS a
        WHERE a.DataFim IS NULL) AS t ON a.FrotaID = t.F001_FrotaID
    LEFT JOIN data_stage_vetor_racsn.dbo.F023_STATUS AS e ON t.StatusId = e.StatusID
    LEFT JOIN data_stage_vetor_racsn.dbo.M002_INFRACAOVIGENCIA AS v ON a.InfracaoID = v.InfracaoID
    LEFT JOIN data_stage_vetor_racsn.dbo.L001_FILIAIS AS q ON t.FilialID = q.FilialID
    LEFT JOIN data_ods.dbo.TB_VETOR_RACSN_CONTRATOS as cok on a.ContratoNro = cok.CONTRATO_ID
    LEFT JOIN data_stage_vetor_racsn.dbo.T001_USUARIOS AS us ON cok.USUARIO_ABERTURA_ID = us.UsuarioID
    LEFT JOIN data_stage_vetor_racsn.dbo.L001_FILIAIS AS fi ON cok.FILIAL_RETIRADA_ID = fi.FilialID
    LEFT JOIN data_stage_vetor_racsn.dbo.B004_PESSOAS AS pe ON cok.PESSOA_ID_EMPRESA = pe.PessoaID
    LEFT JOIN data_stage_vetor_racsn.dbo.C009_CONTRATOS AS con ON cok.CONTRATO_ID = con.ContratoNro
    LEFT JOIN movidadw.mmd.VSA_LOJAS as lol on con.R_FilialID = lol.FILIAL_ID
    LEFT JOIN data_stage_vetor_racsn.dbo.F022_MOVIMENTACOES AS statinfra ON a.FrotaID = statinfra.F001_FrotaID AND a.DataInfracao >= statinfra.DataInicio AND a.DataInfracao <= CASE WHEN statinfra.DataFim IS NULL THEN getdate() ELSE statinfra.DataFim END
    LEFT JOIN data_stage_vetor_racsn.dbo.F023_STATUS AS estaInfra ON statinfra.StatusId = estaInfra.StatusID
    LEFT JOIN (SELECT
        a.*
        FROM data_stage_vetor_racsn.dbo.M003_PENDENCIAS AS a
        JOIN (
            SELECT
            a.MultaID,
            max(a.DataConclusao) AS Data
            FROM data_stage_vetor_racsn.dbo.M003_PENDENCIAS AS a
            GROUP BY
            a.MultaID) AS b ON a.MultaID = b.MultaID AND a.DataConclusao = b.Data) AS pen on a.MultaID = pen.MultaID
    LEFT JOIN data_stage_vetor_racsn.dbo.M005_MULTASTATUS as ms on pen.MStatusID = ms.MStatusID
	LEFT JOIN data_stage_vetor_racsn.dbo.C009_CONTRATOS as contrato on cok.CONTRATO_NRO = contrato.ContratoNro
    LEFT JOIN data_stage_vetor_racsn.dbo.T001_USUARIOS AS ImpeUser ON Pende.MotivoUsuarioID = ImpeUser.UsuarioID
WHERE 
    a.multaiD in ('2243513') 
    AND ms.MStatus =  'Enviado para o orgÃ£o'
	AND v.DataFinal is null
GROUP BY 
    a.AutoInfracao,
    f.Placa,
    cok.CONTRATO_NRO,
    a.MultaID,
    a.DataInfracao,
    a.DataLancamento,
    v.ValorNominal,
    fi.Loja,
    lol.REGIONAL,
    a.Vencimento,
    pe.RazaoSocial,
    b.Orgao,
    us.Login,
    us.SAP,
    estaInfra.Status,
    ms.MStatus,
    con.DataA,
    e.Status,
    Motivo.Motivo,
    Pende.DataMotivo,
	contrato.StatusID,
	contrato.Modalidade,
	ImpeUser.Nome
ORDER BY 
	Pende.DataMotivo DESC