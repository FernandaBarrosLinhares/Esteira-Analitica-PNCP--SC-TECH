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


