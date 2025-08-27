-- Tables creation
-- Do not change lines:
--    'bsscsv_path/*.csv', 

create or replace temp table bss_tbl as
    select *
    from
        read_csv_auto(
            'bss_csv_path/*.csv',
            all_varchar = true,
            union_by_name = true
        );
