USE pncp_controladoria;

-- P1: economia global (só itens comparáveis; percentual = soma ÷ soma)
SELECT
    SUM(CASE WHEN comparavel = 1 THEN valor_total_estimado ELSE 0 END) AS estimado_comparavel,
    SUM(economia_valor) AS economia_rs,
    SUM(economia_valor) /
        NULLIF(SUM(CASE WHEN comparavel = 1 THEN valor_total_estimado ELSE 0 END), 0) * 100 AS economia_pct
FROM fato_item_contratado;