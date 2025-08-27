-- Tables creation
-- Do not change lines:
--    'altip_csv_path/*.csv', 

create or replace temp table altip_tbl as
    select *
    from
        read_csv_auto(
            'altip_csv_path/*.csv',
            all_varchar = true,
            union_by_name = true
        );
