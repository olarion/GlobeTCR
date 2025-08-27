-- Tables creation
-- Do not change lines:
--    'nms_284_csv_path/*.csv', 

create or replace temp table fh_uservlan_tbl (
    OLT_NAME varchar, 
    SLOT varchar, 
    PORT varchar, 
    ONTID varchar, 
    USER_VLAN varchar, 
    SERVICE_TYPE varchar
);

create or replace temp table fh_localvlan_tbl (
    NE_NAME varchar, 
    VLAN varchar, 
    Vlan_Business_Type varchar
);

create or replace temp table fan_gemport_tbl (
    OLT_NAME varchar, 
    VLAN varchar, 
    GEMPORT_ID varchar, 
    SERVICE_TYPE varchar
);

create or replace temp table fan_onu_tbl (
    NOMBRE varchar, 
    SLOT varchar, 
    PORT varchar, 
    ONTID varchar, 
    UNISIDEVLAN varchar, 
    VLANID varchar, 
    VENDOR_ID varchar
);

create or replace temp table cpe_gemport_tbl (
    PRIMARY_KEY_VLAN varchar, 
    OLT_NAME varchar, 
    VLAN varchar, 
    GEMPORT_ID varchar, 
    SERVICE_TYPE varchar, 
    InfoDate varchar
);

create or replace temp table cpe_onu_tbl (
    NOMBRE varchar, 
    SLOT varchar, 
    PORT varchar, 
    ONTID varchar, 
    UNISIDEVLAN varchar, 
    VLANID varchar, 
    VENDOR_ID varchar
);

insert into fh_uservlan_tbl
    select
        OLT_NAME, SLOT, PORT, ONTID, USER_VLAN, SERVICE_TYPE
    from
        read_csv_auto(
            'nms_284_csv_path/*FH_USERVLAN*.csv',
            all_varchar = true,
            union_by_name = true
        )
;
insert into fh_localvlan_tbl
    select
        NE_NAME, VLAN, Vlan_Business_Type
    from
        read_csv_auto(
            'nms_284_csv_path/*FH_LOCALVLAN*.csv',
            all_varchar = true,
            union_by_name = true
        )
;
insert into fan_gemport_tbl
    select
        OLT_NAME, VLAN, GEMPORT_ID, SERVICE_TYPE
    from
        read_csv_auto(
            'nms_284_csv_path/*FAN_GEMPORT*.csv',
            all_varchar = true,
            union_by_name = true
        )
;
insert into fan_onu_tbl
    select
        NOMBRE, SLOT, PORT, ONTID, UNISIDEVLAN, VLANID, VENDOR_ID
    from
        read_csv_auto(
            'nms_284_csv_path/*FAN_ONU*.csv',
            all_varchar = true,
            union_by_name = true
        )
;
insert into cpe_gemport_tbl
    select
        PRIMARY_KEY_VLAN, OLT_NAME, VLAN, GEMPORT_ID, SERVICE_TYPE, InfoDate
    from
        read_csv_auto(
            'nms_284_csv_path/*CPE_GEMPORT*.csv',
            all_varchar = true,
            union_by_name = true
        )
;
insert into cpe_onu_tbl
    select
        NOMBRE,SLOT,PORT,ONTID,UNISIDEVLAN,VLANID, VENDOR_ID
    from
        read_csv_auto(
            'nms_284_csv_path/*CPE_ONU*.csv',
            all_varchar = true,
            union_by_name = true
        )
;
