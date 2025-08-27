-- Validation and other queries:
--     < target_path> in the final statement will programmatically
--     be replaced with the full absolute path.
create or replace temp table tmp_tbl as
    select
        nc.*,  -- all columns from nc_oss
        nc.NC_AAA_USERNAME as nc_username,
        aaa.USERNAME as aaa_username,
        case
            when coalesce(nc.NC_AAA_USERNAME, '') = ''
            then 'NC_AAA_USERNAME empty// '
            else ''
        end ||
        case
            when coalesce(aaa.USERNAME, '') = ''
            then 'AAA USERNAME empty// '
            else ''
        end ||
        case 
            when aaa."SERVICE NUMBER" is null 
            then 'No match on primary keys// ' 
            when  nc.NC_AAA_USERNAME != aaa.USERNAME 
            then 'Match on primary keys, mismatch of User Name between NC and AAA// '
            when nc.NC_AAA_USERNAME = aaa.USERNAME 
            then 'Match on primary keys, match of User Name between NC and AAA// '
            else ''
        end ||
        case
            when lower(nc."NC INTERNET PROTOCOL") in ('pppoe', 'new globe ipoe')
            then 'NC INTERNET PROTOCOL is included'
            else 'NC INTERNET PROTOCOL is neither PPPoE nor New Globe IPoE'
        end as globe_remarks,

        case
            when aaa."SERVICE NUMBER" is not null 
            and  nc.NC_AAA_USERNAME != aaa.USERNAME 
            and  lower(nc."NC INTERNET PROTOCOL") in ('pppoe', 'new globe ipoe')
            then 1
            else 0
        end as forDF
    from nc_tbl as nc
    left join aaa_tbl as aaa
        on  nc.NC_SERVICE_ID = aaa."SERVICE NUMBER"
        and nc.NC_CUSTOMER_NAME = aaa."CUSTOMER NAME"
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
-- ) to '<target_path>' (FORMAT 'pargquet')
-- ;

