use role sysadmin;

create table if not exists payroll.noam_northeast.employee_detail (
   first_name varchar
   ,last_name varchar
   ,email varchar
   ,gender varchar
   ,ssn varchar
   ,street varchar
   ,city varchar
   ,state varchar
   ,postcode varchar
   ,age varchar
   ,birthday date
   ,iban varchar
   ,card_type varchar
   ,cc varchar
   ,ccexp varchar
   ,occupation varchar
   ,salary number
   ,education varchar
   ,credit_score_provider varchar
   ,credit_score number
   ,company varchar
);


create file format if not exists common.utility.csv_standard
    type = csv
    field_delimiter = ','
    skip_header = 1
    null_if = ('NULL','null')
    empty_field_as_null = true
    compression = gzip;

use schema global_sales.online_retail;
use warehouse etl_wh;

use schema payroll.noam_northeast;
use warehouse etl_wh;

put file:///Users/pparashar/Downloads/hr_data_sample.csv @%employee_detail;

-- Create storage integration, which is an account-level object, which we will use to create an external stage and table.
use role accountadmin;
create storage integration if not exists s3click_int
  type = external_stage
  storage_provider = s3
  storage_aws_role_arn = 'arn:aws:iam::179725674134:role/sfcdemorole'
  enabled = true
  storage_allowed_locations = ('s3://sfc-demo-data/click-stream-data/processed/');

--We'll create other objects using sysadmin, so grant "usage" privilege on this storage integration to role sysadmin.
grant usage on integration s3click_int to role sysadmin;

--Create an external stage
use role sysadmin;
create file format if not exists external_db.public.parquet_format 
    type = parquet 
    trim_space = true;

create stage if not exists external_db.public.click_stream_stage 
    storage_integration = s3click_int
    url = 's3://sfc-demo-data/click-stream-data/processed/date=2019-05-17/'
    file_format = external_db.public.parquet_format;

--Ensure that you can list files in the stage
--list @click_stream_stage;

copy into employee_detail
    from @%employee_detail
    file_format = (format_name = common.utility.csv_standard);


alter warehouse etl_wh set warehouse_size='X-Large';

create table if not exists global_sales.online_retail.customer as select * from snowflake_sample_data.tpch_sf1.customer; 
create table if not exists global_sales.online_retail.lineitem as select * from snowflake_sample_data.tpch_sf1.lineitem;
create table if not exists global_sales.online_retail.nation as select * from snowflake_sample_data.tpch_sf1.nation;
create table if not exists global_sales.online_retail.orders as select * from snowflake_sample_data.tpch_sf1.orders;
create table if not exists global_sales.online_retail.part as select * from snowflake_sample_data.tpch_sf1.part;
create table if not exists global_sales.online_retail.partsupp as select * from snowflake_sample_data.tpch_sf1.partsupp;
create table if not exists global_sales.online_retail.region as select * from snowflake_sample_data.tpch_sf1.region;
create table if not exists global_sales.online_retail.supplier as select * from snowflake_sample_data.tpch_sf1.supplier;

update global_sales.online_retail.orders set o_orderdate=dateadd(day,-1,current_date()) 
    where o_orderdate=(select max(o_orderdate) from global_sales.online_retail.orders);

alter warehouse etl_wh set warehouse_size='X-Small';

create table if not exists common.utility.mkt_segment_mapping (
      sales_role varchar(30),
      market_segment varchar(30)
);

insert overwrite into common.utility.mkt_segment_mapping values 
    ('SALES_ANALYST','AUTOMOBILE'),
    ('SALES_ANALYST','MACHINERY'),
    ('SALES_ADMIN','BUILDING'),
    ('SALES_ADMIN','HOUSEHOLD'),
    ('SALES_ADMIN','AUTOMOBILE'),
    ('SALES_ADMIN','MACHINERY');

create secure materialized view if not exists global_sales.online_retail.part_container_count (parts_container, total)
    as select p_container,count(1)  
    from 
    global_sales.online_retail.part
    group by p_container;
                                
use role accountadmin;
create share if not exists global_sales_share;
grant usage on database global_sales to share global_sales_share;
grant usage on schema global_sales.online_retail to share global_sales_share;
grant select on table global_sales.online_retail.customer to share global_sales_share;
grant select on table global_sales.online_retail.lineitem to share global_sales_share;
grant select on table global_sales.online_retail.nation to share global_sales_share;

-- EXTERNAL DB contains an external table 

--Failing on GCP Primary with because storage type different from cloud provider.
/*create external table if not exists external_db.public.clickstream_ext
  location = @external_db.public.click_stream_stage
  file_format = external_db.public.parquet_format;*/