create or replace temp table tmp_tbl as
    WITH
    fh_uservlan AS (
        SELECT DISTINCT
            OLT_NAME,
            SLOT,
            PORT,
            ONTID,
            USER_VLAN,
            SERVICE_TYPE
        FROM
            fh_uservlan_tbl
    ),
    fh_localvlan AS (
        SELECT DISTINCT
            NE_NAME,
            VLAN,
            Vlan_Business_Type
        FROM
            fh_localvlan_tbl
    ),
    fh_all AS (
        SELECT DISTINCT
            a.OLT_NAME,
            a.SLOT,
            a.PORT,
            a.ONTID,
            a.SERVICE_TYPE,
            b.VLAN AS NETWORK_VLAN,
            a.USER_VLAN,
            '' AS GEMPORT_ID,
            '' AS VENDOR_ID,
            'FH_USERVLAN-LOCALVLAN' AS SOURCE_FILE
        FROM
            fh_uservlan AS a
        LEFT JOIN
            fh_localvlan AS b
            ON a.OLT_NAME = b.NE_NAME
            AND a.SERVICE_TYPE = b.Vlan_Business_Type
    ),
    fan_onu AS (
        SELECT DISTINCT
            NOMBRE, 
            SLOT, 
            PORT, 
            ONTID,
            VLANID,
            UNISIDEVLAN,
            VENDOR_ID
        FROM
            fan_onu_tbl
    ),
    fan_gemport AS (
        SELECT DISTINCT
            OLT_NAME,
            SERVICE_TYPE,
            VLAN,
            GEMPORT_ID
        FROM
            fan_gemport_tbl
    ),
    fan_all AS (
        SELECT
            b.OLT_NAME,
            a.SLOT,
            a.PORT,
            a.ONTID,
            b.SERVICE_TYPE,
            b.VLAN AS NETWORK_VLAN,
            a.UNISIDEVLAN AS USER_VLAN,
            b.GEMPORT_ID,
            a.VENDOR_ID,
            'FAN_ONU_GEMPORT' AS SOURCE_FILE
        FROM
            fan_onu AS a
        INNER JOIN
            fan_gemport AS b
            ON a.NOMBRE = b.OLT_NAME
            AND a.UNISIDEVLAN = b.GEMPORT_ID
            AND a.VLANID = b.VLAN
    ),
    cpe_onu AS (
        SELECT DISTINCT
            NOMBRE, 
            SLOT, 
            PORT, 
            ONTID,
            VLANID,
            UNISIDEVLAN,
            VENDOR_ID
        FROM
            cpe_onu_tbl
    ),
    cpe_gemport AS (
        SELECT DISTINCT
            OLT_NAME,
            SERVICE_TYPE,
            VLAN,
            GEMPORT_ID
        FROM
            cpe_gemport_tbl
    ),
    cpe_all AS (
        SELECT
            b.OLT_NAME,
            a.SLOT,
            a.PORT,
            a.ONTID,
            b.SERVICE_TYPE,
            b.VLAN AS NETWORK_VLAN,
            a.UNISIDEVLAN AS USER_VLAN,
            b.GEMPORT_ID,
            a.VENDOR_ID,
            'CPE_ONU_GEMPORT' AS SOURCE_FILE
        FROM
            cpe_onu AS a
        INNER JOIN
            cpe_gemport AS b
            ON a.NOMBRE = b.OLT_NAME
            AND a.UNISIDEVLAN = b.GEMPORT_ID
            AND a.VLANID = b.VLAN
    ),
    nc_vs_fh AS (
        SELECT DISTINCT
            a.id,
            b.SERVICE_TYPE,
            b.VENDOR_ID,
            b.SOURCE_FILE,
            CASE
                WHEN LOWER(b.SERVICE_TYPE) IN  ('data', 'ipoe') 
                THEN b.NETWORK_VLAN 
                ELSE ''
            END AS internet_ep_VLAN_ID,

            CASE
                WHEN LOWER(b.SERVICE_TYPE) IN  ('data', 'ipoe') 
                THEN b.USER_VLAN 
                ELSE ''
            END AS internet_ep_USER_VLAN,

            '' AS internet_ep_User_VLAN_GEMPORT,

            CASE
                WHEN LOWER(b.SERVICE_TYPE) IN  ('voice', 'voip') 
                THEN b.NETWORK_VLAN 
                ELSE ''
            END AS voip_ep_VLAN_ID,

            CASE
                WHEN LOWER(b.SERVICE_TYPE) IN  ('voice', 'voip') 
                THEN b.USER_VLAN 
                ELSE ''
            END AS voip_ep_USER_VLAN,

            CASE
                WHEN LOWER(b.SERVICE_TYPE) IN ('voice', 'voip') 
                THEN b.GEMPORT_ID 
                ELSE ''
            END AS voip_ep_User_VLAN_GEMPORT
        FROM
            nc_tbl AS a
        INNER JOIN
            fh_all AS b
            ON a.NC_CABINET_NAME = b.OLT_NAME
            AND a.NC_CABINET_SLOT = b.SLOT
            AND a.NC_CABINET_PORT = b.PORT
            AND a.NC_ONT_ID = b.ONTID
    ),
    nc_vs_fan AS (
        SELECT DISTINCT
            a.id,
            b.SERVICE_TYPE,
            b.VENDOR_ID,
            b.SOURCE_FILE,
            CASE
                WHEN LOWER(b.SERVICE_TYPE) IN  ('data', 'ipoe') 
                THEN b.NETWORK_VLAN 
                ELSE ''
            END AS internet_ep_VLAN_ID,

            CASE
                WHEN LOWER(b.SERVICE_TYPE) IN  ('data', 'ipoe') 
                THEN b.USER_VLAN 
                ELSE ''
            END AS internet_ep_USER_VLAN,

            CASE
                WHEN LOWER(b.SERVICE_TYPE) IN ('data', 'ipoe') 
                THEN b.GEMPORT_ID
                ELSE ''
            END AS internet_ep_User_VLAN_GEMPORT,

            CASE
                WHEN LOWER(b.SERVICE_TYPE) IN  ('voice', 'voip') 
                THEN b.NETWORK_VLAN 
                ELSE ''
            END AS voip_ep_VLAN_ID,

            CASE
                WHEN LOWER(b.SERVICE_TYPE) IN  ('voice', 'voip') 
                THEN b.USER_VLAN 
                ELSE ''
            END AS voip_ep_USER_VLAN,

            CASE
                WHEN LOWER(b.SERVICE_TYPE) IN ('voice', 'voip') 
                THEN b.GEMPORT_ID 
                ELSE ''
            END AS voip_ep_User_VLAN_GEMPORT
        FROM
            nc_tbl AS a
        INNER JOIN
            fan_all AS b
            ON a.NC_CABINET_NAME = b.OLT_NAME
            AND a.NC_CABINET_SLOT = b.SLOT
            AND a.NC_CABINET_PORT = b.PORT
            AND a.NC_ONT_ID = b.ONTID
    ),
    nc_vs_cpe AS (
        SELECT DISTINCT
            a.id,
            b.SERVICE_TYPE,
            b.VENDOR_ID,
            b.SOURCE_FILE,
            CASE
                WHEN LOWER(b.SERVICE_TYPE) IN  ('data', 'ipoe') 
                THEN b.NETWORK_VLAN 
                ELSE ''
            END AS internet_ep_VLAN_ID,

            CASE
                WHEN LOWER(b.SERVICE_TYPE) IN  ('data', 'ipoe') 
                THEN b.USER_VLAN 
                ELSE ''
            END AS internet_ep_USER_VLAN,

            CASE
                WHEN LOWER(b.SERVICE_TYPE) IN ('data', 'ipoe') 
                THEN b.GEMPORT_ID
                ELSE ''
            END AS internet_ep_User_VLAN_GEMPORT,

            CASE
                WHEN LOWER(b.SERVICE_TYPE) IN  ('voice', 'voip') 
                THEN b.NETWORK_VLAN 
                ELSE ''
            END AS voip_ep_VLAN_ID,

            CASE
                WHEN LOWER(b.SERVICE_TYPE) IN  ('voice', 'voip') 
                THEN b.USER_VLAN 
                ELSE ''
            END AS voip_ep_USER_VLAN,

            CASE
                WHEN LOWER(b.SERVICE_TYPE) IN ('voice', 'voip') 
                THEN b.GEMPORT_ID 
                ELSE ''
            END AS voip_ep_User_VLAN_GEMPORT

        FROM
            nc_tbl AS a
        INNER JOIN
            cpe_all AS b
            ON a.NC_CABINET_NAME = b.OLT_NAME
            AND a.NC_CABINET_SLOT = b.SLOT
            AND a.NC_CABINET_PORT = b.PORT
            AND a.NC_ONT_ID = b.ONTID
    ),
    nc_vs_vlan_all AS (
        SELECT * FROM nc_vs_fh
        UNION
        SELECT * FROM nc_vs_fan
        UNION
        SELECT * FROM nc_vs_cpe
    ),
    uc_match AS (
        SELECT DISTINCT
            id,
            CASE
                WHEN COALESCE(NC_INTERNET_EP_VLAN_ID, '') = ''
                    AND COALESCE(NC_INTERNET_EP_VLAN_INTERFACE, '') = ''
                    AND COALESCE(NC_INTERNET_EP_USER_VLAN, '') = ''
                    AND COALESCE(NC_INTERNET_EP_USER_VLAN_GEM_PORT, '') = ''
                    THEN '27'
                WHEN COALESCE(NC_INTERNET_EP_VLAN_ID, '') = ''
                    AND COALESCE(NC_INTERNET_EP_USER_VLAN, '') = ''
                    AND COALESCE(NC_INTERNET_EP_USER_VLAN_GEM_PORT, '') = ''
                    THEN '35'
                WHEN COALESCE(NC_INTERNET_EP_USER_VLAN, '') = ''
                    AND COALESCE(NC_INTERNET_EP_USER_VLAN_GEM_PORT, '') = ''
                    THEN '23' -- same with 26
                /*
                WHEN COALESCE(NC_INTERNET_EP_USER_VLAN, '') = ''
                    AND COALESCE(NC_INTERNET_EP_USER_VLAN_GEM_PORT, '') = ''
                    THEN '26' -- same with 23
                */
                WHEN COALESCE(NC_INTERNET_EP_VLAN_ID, '') = ''
                    AND COALESCE(NC_INTERNET_EP_VLAN_INTERFACE, '') = ''
                    THEN '37'
                WHEN COALESCE(NC_INTERNET_EP_VLAN_INTERFACE, '') = ''
                    THEN '22'
                WHEN COALESCE(NC_INTERNET_EP_USER_VLAN, '') = '' 
                    THEN '24'
                WHEN COALESCE(NC_INTERNET_EP_USER_VLAN_GEM_PORT, '') = '' 
                    THEN '25'


                WHEN COALESCE(NC_VOIP_EP_VLAN_ID, '') = ''
                    AND COALESCE(NC_VOIP_EP_VLAN_INTERFACE, '') = ''
                    AND COALESCE(NC_VOIP_EP_USER_VLAN, '') = ''
                    AND COALESCE(NC_VOIP_EP_USER_VLAN_GEM_PORT, '') = ''
                    THEN '15' -- same with 32
                /*
                WHEN COALESCE(NC_VOIP_EP_VLAN_ID, '') = ''
                    AND COALESCE(NC_VOIP_EP_VLAN_INTERFACE, '') = ''
                    AND COALESCE(NC_VOIP_EP_USER_VLAN, '') = ''
                    AND COALESCE(NC_VOIP_EP_USER_VLAN_GEM_PORT, '') = ''
                    THEN '32' -- same with 15
                */
                WHEN COALESCE(NC_VOIP_EP_VLAN_ID, '') = ''
                    AND COALESCE(NC_VOIP_EP_VLAN_INTERFACE, '') = ''
                    THEN '28'
                WHEN COALESCE(NC_VOIP_EP_USER_VLAN, '') = ''
                    AND COALESCE(NC_VOIP_EP_USER_VLAN_GEM_PORT, '') = ''
                    THEN '31'
                WHEN COALESCE(NC_VOIP_EP_USER_VLAN, '') = ''
                    THEN '29'
                WHEN COALESCE(NC_VOIP_EP_USER_VLAN_GEM_PORT, '') = ''
                    THEN '30'
                WHEN COALESCE(NC_VOIP_EP_VLAN_INTERFACE, '') = ''
                    THEN '36'

                ELSE ''
            END AS "UC_NUM"
        FROM 
            nc_tbl
    ),
    all_internet AS (
        SELECT DISTINCT
            id,
            VENDOR_ID,
            SERVICE_TYPE,
            SOURCE_FILE,
            internet_ep_VLAN_ID,
            internet_ep_USER_VLAN,
            internet_ep_User_VLAN_GEMPORT
        FROM 
            nc_vs_vlan_all
        WHERE  COALESCE(internet_ep_VLAN_ID, '') != ''
            OR COALESCE(internet_ep_USER_VLAN, '') != ''
            OR COALESCE(internet_ep_User_VLAN_GEMPORT, '') != ''
    ),
    all_voip AS (
        SELECT DISTINCT
            id,
            VENDOR_ID,
            SERVICE_TYPE,
            SOURCE_FILE,
            voip_ep_VLAN_ID,
            voip_ep_USER_VLAN,
            voip_ep_User_VLAN_GEMPORT
        FROM 
            nc_vs_vlan_all
        WHERE  COALESCE(voip_ep_VLAN_ID, '') != ''
            OR COALESCE(voip_ep_USER_VLAN, '') != ''
            OR COALESCE(voip_ep_User_VLAN_GEMPORT, '') != ''
    ),
    new_internet_vlan_int_inf_match AS (
        SELECT 
            id,
        FROM
            nc_tbl
        WHERE COALESCE(NEW__INTERNET_VLAN_INT_REF, '') != ''
        AND COALESCE(NC_INTERNET_EP_OBJID, '') != ''
    ),
    new_voip_vlan_int_inf_match AS (
        SELECT 
            id,
        FROM
            nc_tbl
        WHERE COALESCE(NEW__VOIP_VLAN_INT_REF, '') != ''
        AND COALESCE(NC_VOIP_EP_OBJID, '') != ''
    )

    SELECT DISTINCT
        a.*,
        b.internet_ep_VLAN_ID,
        b.internet_ep_VLAN_ID AS internet_ep_VLAN_INTERFACE,
        b.internet_ep_USER_VLAN,
        b.internet_ep_User_VLAN_GEMPORT,
        c.voip_ep_VLAN_ID,
        c.voip_ep_VLAN_ID AS voip_ep_VLAN_INTERFACE,
        c.voip_ep_USER_VLAN,
        c.voip_ep_User_VLAN_GEMPORT,
        d.UC_NUM,

        CASE
            WHEN b.SOURCE_FILE IS NOT NULL THEN b.SOURCE_FILE
            WHEN c.SOURCE_FILE IS NOT NULL THEN c.SOURCE_FILE
            ELSE ''
        END AS SOURCE_FILE,
        CASE
            WHEN b.id IS NOT NULL OR c.id IS NOT NULL THEN 'TRUE'
            ELSE ''
        END AS "NC_vs_NMS MATCH",
        CASE
            WHEN b.id IS NOT NULL OR c.id IS NOT NULL THEN
                TRIM(
                    TRAILING ', ' FROM (
                    CASE WHEN COALESCE(b.internet_ep_VLAN_ID, '') = '' 
                        THEN 'internet_ep_VLAN_ID, ' ELSE '' END ||
                    CASE WHEN COALESCE(b.internet_ep_USER_VLAN, '') = '' 
                        THEN 'internet_ep_USER_VLAN, ' ELSE '' END ||
                    CASE WHEN COALESCE(b.internet_ep_User_VLAN_GEMPORT, '') = '' 
                        THEN 'internet_User_VLAN_GEMPORT, ' ELSE '' END ||
                    CASE WHEN COALESCE(c.voip_ep_VLAN_ID, '') = '' 
                        THEN 'voip_ep_VLAN_ID, ' ELSE '' END ||
                    CASE WHEN COALESCE(c.voip_ep_USER_VLAN, '') = '' 
                        THEN 'voip_ep_USER_VLAN, ' ELSE '' END ||
                    CASE WHEN COALESCE(c.voip_ep_User_VLAN_GEMPORT, '') = '' 
                        THEN 'voip_ep_User_VLAN_GEMPORT, ' ELSE '' END ||
                    CASE WHEN COALESCE(b.internet_ep_VLAN_ID, '') = '' 
                        AND COALESCE(b.internet_ep_USER_VLAN, '') = '' 
                        AND COALESCE(b.internet_ep_User_VLAN_GEMPORT, '') = '' 
                        AND COALESCE(c.voip_ep_VLAN_ID, '') = '' 
                        AND COALESCE(c.voip_ep_USER_VLAN, '') = '' 
                        AND COALESCE(c.voip_ep_User_VLAN_GEMPORT, '') = '' 
                        THEN 'all VLANs not found in NMS' 
                        ELSE '' 
                    END
                    )
                )
            ELSE 'not found in NMS' 
        END AS vlan_not_found_in_NMS,
        CASE
            WHEN e.id IS NOT NULL THEN 1 ELSE 0
        END AS new_intenet,
        CASE
            WHEN f.id IS NOT NULL THEN 1 ELSE 0
        END AS new_voip,
        CASE 
            WHEN COALESCE(b.VENDOR_ID, '') != '' THEN b.VENDOR_ID
            WHEN COALESCE(c.VENDOR_ID, '') != '' THEN c.VENDOR_ID
            ELSE ''
        END AS "Vendor",
        CASE
            WHEN b.id IS NOT NULL AND e.id IS NOT NULL THEN 'Update. RI match. Update empty VLAN objects.'
            WHEN c.id IS NOT NULL AND f.id IS NOT NULL THEN 'Update. RI match. Update empty VLAN objects.'
            WHEN b.id IS NOT NULL OR e.id IS NULL THEN 'Retain. NEW__INTERNET_VLAN_INT_REF or NC_INTERNET_EP_OBJID is empty'
            WHEN c.id IS NOT NULL OR f.id IS NULL THEN 'Retain. NEW__VOIP_VLAN_INT_REF or NC_VOIP_EP_OBJID is empty'
            WHEN LOWER(b.VENDOR_ID) = 'nokia' THEN 'Retain. Nokia cabinet. VLAN ID should be empty.'
            WHEN LOWER(b.VENDOR_ID) = 'huawei' THEN 'Fallout. VLAN not found in NMS extract.'
            ELSE ''
        END AS "Validation Rules",
        CASE
            WHEN b.id IS NOT NULL AND e.id IS NOT NULL THEN 'Update'
            WHEN c.id IS NOT NULL AND f.id IS NOT NULL THEN 'Update'
            WHEN b.id IS NOT NULL OR e.id IS NULL THEN 'Retain'
            WHEN c.id IS NOT NULL OR f.id IS NULL THEN 'Retain'
            WHEN LOWER(b.VENDOR_ID) = 'nokia' THEN 'Retain'
            WHEN LOWER(b.VENDOR_ID) = 'huawei' THEN 'Fallout'
            ELSE ''
        END AS "Remarks_",

    FROM
        nc_tbl AS a
    LEFT JOIN
        all_internet AS b
        ON a.id = b.id
    LEFT JOIN
        all_voip AS c
        ON a.id = c.id
    LEFT JOIN
        uc_match AS d
        ON a.id = d.id
    LEFT JOIN
        new_internet_vlan_int_inf_match AS e
        ON a.id = e.id
    LEFT JOIN
        new_voip_vlan_int_inf_match AS f
        ON a.id = f.id
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