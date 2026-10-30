USE pncp_controladoria;

-- 1. Contagem da fato (esperado: 6126)
SELECT COUNT(*) FROM fato_item_contratado;

-- 2. Soma do homologado (esperado: 8044498805.74)
SELECT SUM(valor_total_homologado) FROM fato_item_contratado;

-- 3. FK solta: órgão (esperado: 0)
SELECT COUNT(*) FROM fato_item_contratado f
LEFT JOIN dim_orgao o ON o.sk_orgao = f.sk_orgao
WHERE o.sk_orgao IS NULL;

-- 4. FK solta: fornecedor (esperado: 0)
SELECT COUNT(*) FROM fato_item_contratado f
LEFT JOIN dim_fornecedor d ON d.sk_fornecedor = f.sk_fornecedor
WHERE d.sk_fornecedor IS NULL;

-- 5. FK solta: modalidade (esperado: 0)
SELECT COUNT(*) FROM fato_item_contratado f
LEFT JOIN dim_modalidade m ON m.sk_modalidade = f.sk_modalidade
WHERE m.sk_modalidade IS NULL;

-- 6. FK solta: localidade (esperado: 0)
SELECT COUNT(*) FROM fato_item_contratado f
LEFT JOIN dim_localidade l ON l.sk_localidade = f.sk_localidade
WHERE l.sk_localidade IS NULL;

-- 7. Duplicidade do grão (esperado: nenhuma linha)
SELECT numero_controle_pncp, numero_item, COUNT(*)
FROM fato_item_contratado
GROUP BY numero_controle_pncp, numero_item
HAVING COUNT(*) > 1;