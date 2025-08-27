-- Tables creation
-- Do not change lines:
--    'nms_csv_path/*.csv', 

create or replace temp table nms_tbl as
    select *
    from
        read_csv_auto(
            'nms_csv_path/*.csv',
            all_varchar = true,
            union_by_name = true
        );
