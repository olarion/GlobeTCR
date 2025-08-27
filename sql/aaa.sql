-- Tables creation
-- Do not change lines:
--    'aaa_csv_path/*.csv', 

create or replace temp table aaa_tbl as
    select *
    from
        read_csv_auto(
            'aaa_csv_path/*.csv',
            all_varchar = true,
            union_by_name = true
        );
