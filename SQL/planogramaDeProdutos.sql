SELECT
    PRO.CODPROD AS CODIGO_RAMPAP,
    UPPER(PRO.MARCA) AS FABRICANTE,
    UPPER(PRO.DESCRPROD) AS DESCRICAO,
    DEPARTAMENTO.DESCRGRUPOPROD AS DEPARTAMENTO,
    SECAO.DESCRGRUPOPROD AS SECAO,
    CATEGORIA.DESCRGRUPOPROD AS CATEGORIA,
    SUBCATEGORIA.DESCRGRUPOPROD AS SUBCATEGORIA,
    PRO.ALTURA AS ALTURA,
    PRO.LARGURA AS LARGURA,
    PRO.ESPESSURA AS ESPESSURA,
    PRO.CODVOL AS UNDMEDIDA,
    TO_CHAR (
        (
            SELECT
                EXC.VLRVENDA
            FROM
                TGFEXC EXC
            WHERE
                EXC.CODPROD = PRO.CODPROD
                AND EXC.NUTAB = (
                    SELECT
                        MAX(EXC2.NUTAB)
                    FROM
                        TGFEXC EXC2
                        INNER JOIN TGFTAB TAB ON TAB.NUTAB = EXC2.NUTAB
                    WHERE
                        EXC2.CODPROD = EXC.CODPROD
                        AND TAB.CODTAB = 3
                )
        ),
        'FM999G999D00',
        'NLS_NUMERIC_CHARACTERS = '',.'''
    ) AS PRECOBEMOL,
    (
        CASE
            WHEN PRO.CARACTERISTICAS LIKE '%descont%' THEN 'PRODUTO DESCONTINUADO!'
            WHEN PRO.CARACTERISTICAS LIKE '%Inativ%' THEN 'PRODUTO DESCONTINUADO!'
            ELSE PRO.CARACTERISTICAS
        END
    ) AS OBSERVACAO,
    (
        SELECT
            SUM(ESTOQUE)
        FROM
            TGFEST EST
        WHERE
            EST.CODPROD = PRO.CODPROD
            AND CODLOCAL IN (1008000)
            AND ESTOQUE IS NOT NULL
    ) AS ESTOQUE
FROM
    TGFPRO PRO
    LEFT JOIN TGFPAR PAR ON PAR.CODPARC = PRO.CODPARCFORN
    LEFT JOIN TGFGRU subcategoria ON subcategoria.codgrupoprod = pro.codgrupoprod
    AND subcategoria.analitico = 'S'
    LEFT JOIN TGFGRU categoria ON categoria.codgrupoprod = subcategoria.codgrupai
    AND categoria.analitico = 'N'
    LEFT JOIN TGFGRU secao ON secao.codgrupoprod = categoria.codgrupai
    AND secao.analitico = 'N'
    LEFT JOIN TGFGRU departamento ON departamento.codgrupoprod = secao.codgrupai
    AND departamento.analitico = 'N'
WHERE
    PRO.CODPROD <> 0
    AND PRO.AD_CODBEMOL IS NOT NULL
ORDER BY
    PRO.CODPROD ASC