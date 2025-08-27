-- Tables creation
-- Do not change lines:
--    'nc_csv_path/*.csv',

create or replace temp table nc_tbl as
    select 
        row_number() over () as id,
        *
    from
        read_csv(
            'nc_csv_path/*.csv',
            columns = {{COLUMNS}},
            --skip = 1,
            quote = '"',
            escape = '"',
            all_varchar = true,
            union_by_name = true,
            filename = true
        );
