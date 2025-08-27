create or replace temp table tmp_tbl as
    WITH
    empty_serviceid AS (
        SELECT 
            id,
            TRIM(TRAILING ', ' FROM 
                CASE WHEN COALESCE(NC_BP_SERVICE_ID, '') = '' THEN 'NC_BP_SERVICE_ID, ' ELSE '' END ||
                CASE WHEN COALESCE(NC_VOIP_EP_SERVICE_ID, '') = '' THEN 'NC_VOIP_EP_SERVICE_ID, ' ELSE '' END ||
                CASE WHEN COALESCE(NC_INTERNET_EP_SERVICE_ID, '') = '' THEN 'NC_INTERNET_EP_SERVICE_ID, ' ELSE '' END ||
                CASE WHEN COALESCE(NC_VOIP_CFS_SERVICE_ID, '') = '' THEN 'NC_VOIP_CFS_SERVICE_ID, ' ELSE '' END ||
                CASE WHEN COALESCE(NC_INTERNET_CFS_SERVICE_ID, '') = '' THEN 'NC_INTERNET_CFS_SERVICE_ID, ' ELSE '' END ||
                CASE WHEN COALESCE(NC_ACCESS_CFS_SERVICE_ID, '') = '' THEN 'NC_ACCESS_CFS_SERVICE_ID, ' ELSE '' END ||
                CASE WHEN COALESCE(NC_ACCESS_RFS_SERVICE_ID, '') = '' THEN 'NC_ACCESS_RFS_SERVICE_ID, ' ELSE '' END
            ) AS EMPTY_SERVICE_ID
        FROM nc_tbl
    ),

    /*
    BP Wireline
    - NC_VOIP_EP_SERVICE_ID
    NC_BP_SERVICE_ID
    NC_VOIP_CFS_SERVICE_ID
    NC_ACCESS_CFS_SERVICE_ID
    NC_ACCESS_RFS_SERVICE_ID


    Data Only Wireline
    - NC_INTERNET_EP_SERVICE_ID
    NC_BP_SERVICE_ID
    NC_INTERNET_CFS_SERVICE_ID
    NC_ACCESS_CFS_SERVICE_ID
    NC_ACCESS_RFS_SERVICE_ID


    BP Wireless
    - NC_VOIP_CFS_SERVICE_ID
    NC_BP_SERVICE_ID
    NC_ACCESS_CFS_SERVICE_ID
    NC_ACCESS_RFS_SERVICE_ID


    Data Only Wireless
    - NC_INTERNET_CFS_SERVICE_ID
    NC_BP_SERVICE_ID
    NC_ACCESS_CFS_SERVICE_ID
    NC_ACCESS_RFS_SERVICE_ID
    */

    reference_serviceid_column AS (
        SELECT 
            id,
            CASE
                WHEN LOWER(NC_BP_TYPE) = 'bundled' 
                AND  LOWER(NC_ACCESS_RFS_TYPE) = 'wireline' 
                -- AND  COALESCE(NC_VOIP_EP_SERVICE_ID, '') != ''
                THEN 'bundled_wireline NC_VOIP_EP_SERVICE_ID'

                WHEN LOWER(NC_BP_TYPE) = 'bundled' 
                AND  LOWER(NC_ACCESS_RFS_TYPE) = 'wireless' 
                -- AND  COALESCE(NC_VOIP_CFS_SERVICE_ID, '') != ''
                THEN 'bundled_wirless NC_VOIP_CFS_SERVICE_ID'

                WHEN LOWER(NC_BP_TYPE) = 'data only' 
                AND  LOWER(NC_INTERNET_RFS_TYPE) = 'wireline' 
                -- AND  COALESCE(NC_INTERNET_EP_SERVICE_ID, '') != ''
                THEN 'data_only_wireline NC_INTERNET_EP_SERVICE_ID' 

                WHEN LOWER(NC_BP_TYPE) = 'data only' 
                AND  LOWER(NC_INTERNET_RFS_TYPE) = 'wireless' 
                -- AND  COALESCE(NC_INTERNET_CFS_SERVICE_ID, '') != ''
                THEN 'data_only_wireless NC_INTERNET_CFS_SERVICE_ID'

                ELSE ''
            END AS REFERENCE_SERVICEID_COLUMN
        FROM
            nc_tbl
    ),
    misaligned_serviceid_vs_ref_serviceid AS (
        SELECT 
            id,
            CASE
                WHEN LOWER(NC_BP_TYPE) = 'bundled' AND LOWER(NC_ACCESS_RFS_TYPE) = 'wireline' THEN
                    CASE
                        WHEN NC_BP_SERVICE_ID != NC_VOIP_EP_SERVICE_ID THEN 'NC_BP_SERVICE_ID, '
                        ELSE ''
                    END
                    || 
                    CASE
                        WHEN NC_VOIP_CFS_SERVICE_ID != NC_VOIP_EP_SERVICE_ID THEN 'NC_VOIP_CFS_SERVICE_ID, '
                        ELSE ''
                    END
                    || 
                    CASE
                        WHEN NC_ACCESS_CFS_SERVICE_ID != NC_VOIP_EP_SERVICE_ID THEN 'NC_ACCESS_CFS_SERVICE_ID, '
                        ELSE ''
                    END
                    || 
                    CASE
                        WHEN NC_ACCESS_RFS_SERVICE_ID != NC_VOIP_EP_SERVICE_ID THEN 'NC_ACCESS_RFS_SERVICE_ID, '
                        ELSE ''
                    END

                WHEN LOWER(NC_BP_TYPE) = 'bundled' AND LOWER(NC_ACCESS_RFS_TYPE) = 'wireless' THEN
                    CASE
                        WHEN NC_BP_SERVICE_ID != NC_VOIP_CFS_SERVICE_ID THEN 'NC_BP_SERVICE_ID, '
                        ELSE ''
                    END
                    || 
                    CASE
                        WHEN NC_ACCESS_CFS_SERVICE_ID != NC_VOIP_CFS_SERVICE_ID THEN 'NC_ACCESS_CFS_SERVICE_ID, '
                        ELSE ''
                    END
                    || 
                    CASE
                        WHEN NC_ACCESS_RFS_SERVICE_ID != NC_VOIP_CFS_SERVICE_ID THEN 'NC_ACCESS_RFS_SERVICE_ID, '
                        ELSE ''
                    END

                WHEN LOWER(NC_BP_TYPE) = 'data only' AND LOWER(NC_INTERNET_RFS_TYPE) = 'wireline' THEN
                    CASE
                        WHEN  NC_BP_SERVICE_ID != NC_INTERNET_EP_SERVICE_ID THEN 'NC_BP_SERVICE_ID, '
                        ELSE ''
                    END
                    || 
                    CASE
                        WHEN  NC_INTERNET_CFS_SERVICE_ID != NC_INTERNET_EP_SERVICE_ID THEN 'NC_INTERNET_CFS_SERVICE_ID, '
                        ELSE ''
                    END
                    || 
                    CASE
                        WHEN  NC_ACCESS_CFS_SERVICE_ID != NC_INTERNET_EP_SERVICE_ID THEN 'NC_ACCESS_CFS_SERVICE_ID, '
                        ELSE ''
                    END
                    || 
                    CASE
                        WHEN  NC_ACCESS_RFS_SERVICE_ID != NC_INTERNET_EP_SERVICE_ID THEN 'NC_ACCESS_RFS_SERVICE_ID, '
                        ELSE ''
                    END

                WHEN LOWER(NC_BP_TYPE) = 'data only' AND  LOWER(NC_INTERNET_RFS_TYPE) = 'wireless'  THEN
                    CASE
                        WHEN  NC_BP_SERVICE_ID != NC_INTERNET_CFS_SERVICE_ID THEN 'NC_BP_SERVICE_ID, '
                        ELSE ''
                    END
                    || 
                    CASE
                        WHEN  NC_ACCESS_CFS_SERVICE_ID != NC_INTERNET_CFS_SERVICE_ID THEN 'NC_ACCESS_CFS_SERVICE_ID, '
                        ELSE ''
                    END
                    || 
                    CASE
                        WHEN  NC_ACCESS_RFS_SERVICE_ID != NC_INTERNET_CFS_SERVICE_ID THEN 'NC_ACCESS_RFS_SERVICE_ID, '
                        ELSE ''
                    END
                ELSE ''
            END AS MISALIGNED_SERVICEID_VS_REF_SERVICEID
        FROM
            nc_tbl
    ),
    empty_ref_serviceid AS (
        SELECT 
            id,
            CASE
                WHEN LOWER(NC_BP_TYPE) = 'bundled' 
                AND  LOWER(NC_ACCESS_RFS_TYPE) = 'wireline' 
                AND  COALESCE(NC_VOIP_EP_SERVICE_ID, '') = ''
                THEN 'NC_VOIP_EP_SERVICE_ID'

                WHEN LOWER(NC_BP_TYPE) = 'bundled'
                AND  LOWER(NC_ACCESS_RFS_TYPE) = 'wireless'
                AND  COALESCE(NC_VOIP_CFS_SERVICE_ID, '') = ''
                THEN 'NC_VOIP_CFS_SERVICE_ID'

                WHEN LOWER(NC_BP_TYPE) = 'data only' 
                AND  LOWER(NC_INTERNET_RFS_TYPE) = 'wireline' 
                AND  COALESCE(NC_INTERNET_EP_SERVICE_ID, '') = ''
                THEN 'NC_INTERNET_EP_SERVICE_ID' 

                WHEN LOWER(NC_BP_TYPE) = 'data only' 
                AND  LOWER(NC_INTERNET_RFS_TYPE) = 'wireless' 
                AND  COALESCE(NC_INTERNET_CFS_SERVICE_ID, '') = ''
                THEN 'NC_INTERNET_CFS_SERVICE_ID'

                ELSE ''
            END AS EMPTY_REF_SERVICEID
        FROM
            nc_tbl
    ),

    ref_serviceid AS (
        SELECT 
            id,
            CASE
                WHEN LOWER(NC_BP_TYPE) = 'bundled' 
                AND  LOWER(NC_ACCESS_RFS_TYPE) = 'wireline' 
                AND  COALESCE(NC_VOIP_EP_SERVICE_ID, '') != ''
                THEN NC_VOIP_EP_SERVICE_ID

                WHEN LOWER(NC_BP_TYPE) = 'bundled'
                AND  LOWER(NC_ACCESS_RFS_TYPE) = 'wireless'
                AND  COALESCE(NC_VOIP_CFS_SERVICE_ID, '') != ''
                THEN NC_VOIP_CFS_SERVICE_ID

                WHEN LOWER(NC_BP_TYPE) = 'data only' 
                AND  LOWER(NC_INTERNET_RFS_TYPE) = 'wireline' 
                AND  COALESCE(NC_INTERNET_EP_SERVICE_ID, '') != ''
                THEN NC_INTERNET_EP_SERVICE_ID 

                WHEN LOWER(NC_BP_TYPE) = 'data only' 
                AND  LOWER(NC_INTERNET_RFS_TYPE) = 'wireless' 
                AND  COALESCE(NC_INTERNET_CFS_SERVICE_ID, '') != ''
                THEN NC_INTERNET_CFS_SERVICE_ID

                ELSE ''
            END AS REF_SERVICEID
        FROM
            nc_tbl
    ),
    duplicated_ref_serviceid AS (
        SELECT 
            id,
            REF_SERVICEID,
            CASE 
                WHEN COUNT(*) OVER (PARTITION BY REF_SERVICEID) > 1 
                THEN 'TRUE'
                ELSE ''
            END AS DUPLICATED_REF_SERVICE_ID
        FROM 
            ref_serviceid
        WHERE 
            COALESCE(REF_SERVICEID, '') != ''

    ),
    duplicated_bp_serviceid AS (
        SELECT 
            id,
            CASE 
                WHEN COUNT(*) OVER (PARTITION BY NC_BP_SERVICE_ID) > 1 
                THEN 'TRUE'
                ELSE ''
            END AS DUPLICATED_BP_SERVICE_ID
        FROM 
            nc_tbl
        WHERE 
            COALESCE(NC_BP_SERVICE_ID, '') != ''

    )

    SELECT
        a.*,
        b.EMPTY_SERVICE_ID,
        c.REFERENCE_SERVICEID_COLUMN,
        g.REF_SERVICEID,
        d.EMPTY_REF_SERVICEID,
        f.MISALIGNED_SERVICEID_VS_REF_SERVICEID,
        g.DUPLICATED_REF_SERVICE_ID,
        h.DUPLICATED_BP_SERVICE_ID,
        CASE
            WHEN d.EMPTY_REF_SERVICEID = ''
            AND  f.MISALIGNED_SERVICEID_VS_REF_SERVICEID != '' THEN 'TRUE'
            ELSE ''
        END AS FOR_DF
    FROM
        nc_tbl AS a
    LEFT JOIN
        empty_serviceid AS b
        ON a.id = b.id
    LEFT JOIN
        reference_serviceid_column AS c
        ON a.id = c.id
    LEFT JOIN
        empty_ref_serviceid AS d
        ON a.id = d.id
    LEFT JOIN
        misaligned_serviceid_vs_ref_serviceid AS f
        ON a.id = f.id
    LEFT JOIN
        duplicated_ref_serviceid AS g
        ON a.id = g.id
    LEFT JOIN
        duplicated_bp_serviceid AS h
        ON a.id = h.id
;
-- Change filename as needed
-- except <target_path> which is the target path
copy (
    select *
    from tmp_tbl
    order by id
) to '<target_path>' (HEADER, DELIMITER ',')
;
-- Output to parquet
-- copy (
--     select *
--     from tmp_tbl
--     order by id
-- ) to '<target_path>' (FORMAT 'parquet')
-- ;