-- Tables creation
-- Do not change lines:
--    'lfdno_csv_path/*.csv', 

create or replace temp table lfdno_tbl as
    select *
    from
        read_csv_auto(
            'lfdno_csv_path/*.csv',
            all_varchar = true,
            union_by_name = true
        );
