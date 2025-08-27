-- Validation and other queries:
--     The <target_path> in the final statement will be 
--     programmatically replaced with the full absolute path.

with
service_type_nc_vs_bss as (
    select 
        nc.EXTERNALID
    from nc_tbl
    join bss_tbl
        on  nc.EXTERNALID = bss.PRODUCT_INSTANCE_ID
        and nc.SERVICE_TYPE != bss.SERV_TYPE
)

select *
from service_type_nc_vs_bss;


-- Change filename as needed
-- except <target_path> which is the target path
COPY nc TO '<target_path>/302_validated.csv' (HEADER, DELIMITER ',');
-- Output to parquet
-- COPY nc TO '<target_path>/302_validated.csv' (FORMAT 'parquet');
