-- Validation and other queries:
--     < target_path> in the final statement will programmatically
--     be replaced with the full absolute path.
create or replace temp table tmp_tbl as
    select 
        nc.*,
        nc.NC_IP_ADDRESS as nc_ip_address,
        aaa."IP ADDRESS" as aaa_ip_address,
        nc.NC_IP_RANGE as nc_ip_range,
        aaa."NET ADDRESS" as aaa_net_address,
        case
            when coalesce(nc.NC_IP_ADDRESS, '') = ''
            then 'NC_IP_ADDRESS is empty// '
            else ''
        end ||
        case
            when coalesce(aaa."IP ADDRESS" , '') = ''
            then 'AAA IP ADDRESS is empty// '
            else ''
        end ||
        case
            when coalesce(nc.NC_IP_ADDRESS, '') != coalesce(aaa."IP ADDRESS", '')
            then 'Mismatch of IP Address between NC and AAA// '
            else ''
        end ||
        case
            when coalesce(nc.NC_IP_RANGE, '') = ''
            then 'NC_IP_RANGE is empty// '
            else ''
        end ||
        case
            when coalesce(aaa."NET ADDRESS" , '') = ''
            then 'AAA NET ADDRESS is empty// '
            else ''
        end ||
        case
            when coalesce(nc.NC_IP_RANGE, '') != coalesce(aaa."NET ADDRESS", '')
            then 'Mismatch of NC_IP_RANGE and AAA NET ADDRESS// '
            else ''
        end ||
        case
            when lower(nc."NC_INTERNET_PROTOCOL") in ('pppoe', 'new globe ipoe')
            then 'NC_INTERNET_PROTOCOL is included'
            else 'NC_INTERNET_PROTOCOL is neither PPPoE nor New Globe IPoE'
        end as globe_remarks,
        case
            when aaa."SERVICE NUMBER" is not null 
            and  lower(nc."NC_INTERNET_PROTOCOL") in ('pppoe', 'new globe ipoe')
            and  (
                coalesce(nc.NC_IP_ADDRESS, '') != coalesce(aaa."IP ADDRESS", '')
                or coalesce(nc.NC_IP_RANGE, '') != coalesce(aaa."NET ADDRESS", '')
            )
            then 1
            else 0
        end as forDF

    from nc_tbl as nc
    left join aaa_tbl as aaa
        on nc.NC_SERVICE_ID = aaa."SERVICE NUMBER"
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