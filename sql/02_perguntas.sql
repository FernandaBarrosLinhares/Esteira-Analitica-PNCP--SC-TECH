USE pncp_controladoria;

-- P1: economia global (só itens comparáveis; percentual = soma ÷ soma)

SELECT 
    SUM(CASE
        WHEN comparavel = 1 THEN valor_total_estimado
        ELSE 0
    END) AS estimado_comparavel,
    SUM(economia_valor) AS economia_rs,
    SUM(economia_valor) / NULLIF(SUM(CASE
                WHEN comparavel = 1 THEN valor_total_estimado
                ELSE 0
            END),
            0) * 100 AS economia_pct
FROM
    fato_item_contratado;

-- P1 (apoio): itens comparáveis e itens com sobrepreço
SELECT
    COUNT(*) AS itens_total,
    SUM(comparavel = 1) AS itens_comparaveis,
    ROUND(SUM(comparavel = 1) * 100 / COUNT(*), 1) AS pct_comparaveis,
    SUM(comparavel = 1 AND valor_total_homologado > valor_total_estimado) AS itens_sobrepreco
FROM fato_item_contratado;

-- P2: top 10 fornecedores por volume e % do volume total

SELECT
    d.ni_fornecedor,
    d.nome_fornecedor,
    SUM(f.valor_total_homologado) AS volume,
    SUM(f.valor_total_homologado) * 100 /
        (SELECT SUM(valor_total_homologado) FROM fato_item_contratado) AS pct_do_total
FROM fato_item_contratado f
JOIN dim_fornecedor d ON d.sk_fornecedor = f.sk_fornecedor
GROUP BY d.ni_fornecedor, d.nome_fornecedor
ORDER BY volume DESC
LIMIT 10;    

-- P2 (complemento): concentração dos 10 maiores

SELECT
    SUM(volume) AS volume_top10,
    SUM(volume) * 100 / (SELECT SUM(valor_total_homologado) FROM fato_item_contratado) AS pct_top10
FROM (
    SELECT SUM(valor_total_homologado) AS volume
    FROM fato_item_contratado
    GROUP BY sk_fornecedor
    ORDER BY volume DESC
    LIMIT 10
) t;

-- Detalhes Now Seguro

SELECT numero_controle_pncp, numero_item, descricao_item, quantidade,
       valor_unitario_homologado, valor_total_homologado
FROM fato_item_contratado f
JOIN dim_fornecedor d ON d.sk_fornecedor = f.sk_fornecedor
WHERE d.ni_fornecedor = '46973571000103'
ORDER BY valor_total_homologado DESC;

-- P3: deságio e volume por modalidade

SELECT
    m.nome_modalidade,
    COUNT(*) AS itens,
    SUM(f.valor_total_homologado) AS volume,
    ROUND(SUM(f.valor_total_homologado) * 100 /
        (SELECT SUM(valor_total_homologado) FROM fato_item_contratado), 2) AS pct_volume,
    SUM(f.economia_valor) AS economia_rs,
    ROUND(SUM(f.economia_valor) * 100 /
        NULLIF(SUM(CASE WHEN f.comparavel = 1 THEN f.valor_total_estimado ELSE 0 END), 0), 2) AS desagio_pct
FROM fato_item_contratado f
JOIN dim_modalidade m ON m.sk_modalidade = f.sk_modalidade
GROUP BY m.nome_modalidade
ORDER BY volume DESC;

-- P4: ciclo médio por órgão (nome padronizado; só órgãos com 5+ itens com ciclo)

SELECT
    o.nome_orgao,
    COUNT(DISTINCT o.cnpj_orgao) AS unidades,
    COUNT(f.dias_ciclo) AS itens_com_ciclo,
    ROUND(AVG(f.dias_ciclo), 1) AS ciclo_medio_dias,
    MAX(f.dias_ciclo) AS ciclo_max_dias
FROM fato_item_contratado f
JOIN dim_orgao o ON o.sk_orgao = f.sk_orgao
GROUP BY o.nome_orgao
HAVING COUNT(f.dias_ciclo) >= 5
ORDER BY ciclo_medio_dias DESC;

-- P4 (conferência): ciclo geral 

SELECT
    COUNT(dias_ciclo) AS itens_com_ciclo,
    ROUND(AVG(dias_ciclo), 1) AS ciclo_medio,
    MAX(dias_ciclo) AS ciclo_max,
    COUNT(*) - COUNT(dias_ciclo) AS itens_sem_ciclo
FROM fato_item_contratado;

-- P4 (apoio): 5 maiores ciclos individuais

SELECT numero_controle_pncp, numero_item, dias_ciclo
FROM fato_item_contratado
ORDER BY dias_ciclo DESC, numero_controle_pncp, numero_item
LIMIT 5;

-- P4 (apoio): órgão do maior ciclo 

SELECT cnpj_orgao, nome_orgao FROM dim_orgao
WHERE cnpj_orgao = '00394452000103';

-- P4 (apoio): órgão do ciclo de 437 dias 
SELECT cnpj_orgao, nome_orgao FROM dim_orgao
WHERE cnpj_orgao = '04892707000100';


-- P5a: despesa e desconto por UF

SELECT
    l.uf_sigla,
    l.regiao,
    COUNT(DISTINCT o.cnpj_orgao) AS unidades_compradoras,
    SUM(f.valor_total_homologado) AS volume,
    ROUND(SUM(f.valor_total_homologado) * 100 /
        (SELECT SUM(valor_total_homologado) FROM fato_item_contratado), 2) AS pct_volume,
    ROUND(SUM(f.economia_valor) * 100 /
        NULLIF(SUM(CASE WHEN f.comparavel = 1 THEN f.valor_total_estimado ELSE 0 END), 0), 2) AS desagio_pct
FROM fato_item_contratado f
JOIN dim_localidade l ON l.sk_localidade = f.sk_localidade
JOIN dim_orgao o ON o.sk_orgao = f.sk_orgao
GROUP BY l.uf_sigla, l.regiao
ORDER BY volume DESC;

-- P5b: despesa e desconto por região

SELECT
    l.regiao,
    COUNT(DISTINCT o.cnpj_orgao) AS unidades_compradoras,
    SUM(f.valor_total_homologado) AS volume,
    ROUND(SUM(f.valor_total_homologado) * 100 /
        (SELECT SUM(valor_total_homologado) FROM fato_item_contratado), 2) AS pct_volume,
    ROUND(SUM(f.economia_valor) * 100 /
        NULLIF(SUM(CASE WHEN f.comparavel = 1 THEN f.valor_total_estimado ELSE 0 END), 0), 2) AS desagio_pct
FROM fato_item_contratado f
JOIN dim_localidade l ON l.sk_localidade = f.sk_localidade
JOIN dim_orgao o ON o.sk_orgao = f.sk_orgao
GROUP BY l.regiao
ORDER BY volume DESC;

-- P5 (apoio): maiores itens do DF
SELECT f.numero_controle_pncp, f.numero_item, f.valor_total_homologado
FROM fato_item_contratado f
JOIN dim_localidade l ON l.sk_localidade = f.sk_localidade
WHERE l.uf_sigla = 'DF'
ORDER BY f.valor_total_homologado DESC
LIMIT 5;