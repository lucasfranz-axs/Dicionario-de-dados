CREATE OR REPLACE VIEW sapiens.vw_contas_a_receber_bi AS
SELECT con.usu_codcon                  AS codcon,
       cad.usu_nomcon                  AS nomcon,
       cvs.usu_uncger                  AS uncusi,
       tcr.codemp                      AS codemp,
       emp.nomemp                      AS nomemp,
       tcr.codfil                      AS codfil,
       fil.codfil                      AS nomfil,
       fil.numcgc                      AS numcgc,
       ctr.numctr                      AS numctr,
       tcr.codcli                      AS codcli,
       cli.nomcli                      AS nomcli,
       cvs.usu_geranu                  AS geranu,
       round((cvs.usu_geranu / 12), 2) AS germes,
       ctr.usu_codunc                  AS codunc,
       ctr.sitctr                      AS sitctr,
       tcr.codrep                      AS codrep,
       isv.codser                      AS codser,
       cli.foncli                      AS foncli,
       cli.intnet                      AS intnet,
       ctr.diafix                      AS diafix,
       tcr.datemi                      AS datemi,
       isv.datcpt                      AS datcpt,
       nfv.numnfv                      AS numnfv,
       nfv.codsnf                      AS codsnf,
       tcr.numtit                      AS numtit,
       tcr.codtpt                      AS codtpt,
       isv.seqisv                      AS seqisv,
       cvs.seqcvs                      AS seqcvs,
       tcr.sittit                      AS sittit,
       nfv.sitnfv                      AS sitnfv,
       tcr.vlrori                      AS vlrori,
       tcr.datppt                      AS datppt,
       CASE
           WHEN tcr.ultpgt = TO_DATE('31/12/1900', 'DD/MM/YYYY') THEN NULL
           ELSE tcr.ultpgt
       END                             AS ultpgt,
       lib.datlib,
       tcr.perjrs                      AS perjrs,
       tcr.permul                      AS permul,
       tcr.tipjrs                      AS tipjrs,
       cvs.usu_codmod                  AS mod_fatura,
       CASE
           WHEN ( tcr.sittit = 'LQ'
                  AND tcr.ultpgt = TO_DATE('31/12/1900', 'DD/MM/YYYY') ) THEN 'Cancelado (Abatimento)'
           WHEN tcr.sittit = 'CA' THEN 'Cancelado'
           WHEN ( tcr.sittit = 'LP'
                  OR ( tcr.sittit = 'LQ'
                       AND tcr.numtit LIKE '%P%' ) ) THEN 'Liquidado (Protestado)'
           WHEN tcr.sittit = 'LC' THEN 'Liquidado (Cartório)'
           WHEN tcr.sittit = 'LS' THEN 'Baixa Substituição'
           WHEN tcr.sittit LIKE '%L%' THEN 'Liquidado'
           WHEN ( tcr.sittit = 'AB'
                  AND tcr.numtit LIKE '%P%' ) THEN 'Aberto (Protestado)'
           WHEN ( tcr.sittit = 'AP'
                  OR tcr.sittit = 'AC' ) THEN 'Protestado'
           ELSE 'Aberto'
       END                             AS cartorio_protesto,
       CASE
           WHEN ( tcr.sittit = 'LQ'
                  AND tcr.ultpgt = TO_DATE('31/12/1900', 'DD/MM/YYYY') )
                OR tcr.sittit = 'LS' THEN 'Cancelado/Subst./Abat.'
           WHEN tcr.sittit = 'CA'     THEN 'Cancelado'
           WHEN tcr.vlrabe = 0        THEN 'Liquidado'
           WHEN tcr.vctpro >= sysdate THEN 'À pagar'
           WHEN ( tcr.vctpro < sysdate
                  AND ( tcr.sittit = 'AP'
                        OR tcr.sittit = 'AC' ) ) THEN 'Protestado'
           WHEN ( tcr.vctpro < sysdate
                  AND NOT ( tcr.sittit = 'AP'
                            OR tcr.sittit = 'AC' ) ) THEN 'Em atraso'
           ELSE NULL
       END                             AS situacao,
       CASE
           WHEN ( tcr.vctpro < sysdate
                  AND NOT ( tcr.sittit = 'AP'
                            OR tcr.sittit = 'AC' ) )
                OR ( tcr.vctpro < sysdate
                     AND ( tcr.sittit = 'AP'
                           OR tcr.sittit = 'AC' ) ) THEN round(sysdate - tcr.vctpro, 0)
           ELSE 1000000
       END                             AS dias_desde_vct,
       CASE
           WHEN tcr.numtit LIKE '%P%' THEN 1
           ELSE 0
       END                             AS protestado,
       CASE
           WHEN tcr.numtit LIKE '%N%' THEN 1
           ELSE 0
       END                             AS negociado,
       CASE
           WHEN (
               CASE
                   WHEN ( tcr.vctpro < sysdate
                          AND NOT ( tcr.sittit = 'AP'
                                    OR tcr.sittit = 'AC' ) )
                        OR ( tcr.vctpro < sysdate
                             AND ( tcr.sittit = 'AP'
                                   OR tcr.sittit = 'AC' ) ) THEN round(sysdate - tcr.vctpro, 0)
                   ELSE 1000000
               END
           ) = 1000000 THEN '1000000'
           WHEN (
               CASE
                   WHEN ( tcr.vctpro < sysdate
                          AND NOT ( tcr.sittit = 'AP'
                                    OR tcr.sittit = 'AC' ) )
                        OR ( tcr.vctpro < sysdate
                             AND ( tcr.sittit = 'AP'
                                   OR tcr.sittit = 'AC' ) ) THEN round(sysdate - tcr.vctpro, 0)
                   ELSE 1000000
               END
           ) >= 90     THEN 'mais de 90'
           WHEN (
               CASE
                   WHEN ( tcr.vctpro < sysdate
                          AND NOT ( tcr.sittit = 'AP'
                                    OR tcr.sittit = 'AC' ) )
                        OR ( tcr.vctpro < sysdate
                             AND ( tcr.sittit = 'AP'
                                   OR tcr.sittit = 'AC' ) ) THEN round(sysdate - tcr.vctpro, 0)
                   ELSE 1000000
               END
           ) >= 31     THEN '31 à 89'
           WHEN (
               CASE
                   WHEN ( tcr.vctpro < sysdate
                          AND NOT ( tcr.sittit = 'AP'
                                    OR tcr.sittit = 'AC' ) )
                        OR ( tcr.vctpro < sysdate
                             AND ( tcr.sittit = 'AP'
                                   OR tcr.sittit = 'AC' ) ) THEN round(sysdate - tcr.vctpro, 0)
                   ELSE 1000000
               END
           ) >= 1      THEN '01 à 30'
           ELSE NULL
       END                             AS faixa_diavct
FROM sapiens.e301tcr     tcr
LEFT JOIN sapiens.e140nfv     nfv ON nfv.codemp = tcr.codemp
                                 AND nfv.codfil = tcr.codfil
                                 AND nfv.numnfv = tcr.numnfv
                                 AND nfv.codsnf = tcr.codsnf
LEFT JOIN sapiens.e140isv     isv ON isv.codemp = nfv.codemp
                                 AND isv.codfil = nfv.codfil
                                 AND isv.codsnf = nfv.codsnf
                                 AND isv.numnfv = nfv.numnfv
LEFT JOIN sapiens.e160cvs     cvs ON cvs.codemp = isv.codemp
                                 AND cvs.codfil = isv.filctr
                                 AND cvs.numctr = isv.numctr
                                 AND cvs.datcpt = isv.datcpt
                                 AND cvs.seqcvs = isv.seqcvs
LEFT JOIN sapiens.e160ctr     ctr ON ctr.codemp = isv.codemp
                                 AND ctr.codfil = isv.filctr
                                 AND ctr.numctr = isv.numctr
LEFT JOIN sapiens.usu_tconfil con ON con.usu_codemp = tcr.codemp
                                     AND con.usu_codfil = tcr.codfil
LEFT JOIN sapiens.usu_tcadcon cad ON cad.usu_codcon = con.usu_codcon
LEFT JOIN (
    SELECT codemp,
           codfil,
           numtit,
           codtpt,
           MAX(datlib) AS datlib
    FROM sapiens.e301mcr
    WHERE codtns IN ( 90350, 90358 )
    GROUP BY codemp,
             codfil,
             numtit,
             codtpt
)                   lib ON tcr.codemp = lib.codemp
         AND tcr.codfil = lib.codfil
         AND tcr.numtit = lib.numtit
         AND tcr.codtpt = lib.codtpt
LEFT JOIN sapiens.e085cli     cli ON tcr.codcli = cli.codcli
LEFT JOIN sapiens.e070emp     emp ON emp.codemp = tcr.codemp
LEFT JOIN sapiens.e070fil     fil ON fil.codemp = tcr.codemp
                                 AND fil.codfil = tcr.codfil
WHERE tcr.codemp IN ( 12, 13, 21, 22, 23,
                      24 )
      AND tcr.codtpt IN ( '', '01', 'FAT', 'ADT' )
      AND cli.codcli NOT IN ( 122, 1432 ) -- REMOVER OS CLIENTES COOPERATIVA E CONSÓRCIO 01
ORDER BY nfv.cptfat ASC,
         tcr.numtit;
         ----comentário