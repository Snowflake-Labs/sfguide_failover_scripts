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

use warehouse etl_wh;

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

use role sysadmin;

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


-- Create objects with cross-database dependencies
-- (use SNOWFLAKE_SAMPLE_DATA shared database)

create or replace share global_sales_share;
grant usage on database global_sales to share global_sales_share;
grant usage on schema global_sales.online_retail to share global_sales_share;
grant select on table global_sales.online_retail.customer to share global_sales_share;
grant select on table global_sales.online_retail.lineitem to share global_sales_share;
grant select on table global_sales.online_retail.nation to share global_sales_share;


-- REFERENCES DB contains a masking policy, row-access policy, and tags.

use database references;
create or replace table lookups.household_demographics as
  select * from snowflake_sample_data.tpcds_sf10tcl.household_demographics;
create or replace table lookups.time_dim as
  select * from snowflake_sample_data.tpcds_sf10tcl.time_dim;
create or replace table lookups.store as
  select * from snowflake_sample_data.tpcds_sf10tcl.store;


-- SALES DB has tables that are periodically updated

use database sales;
create or replace table store_sales as select * from snowflake_sample_data.tpcds_sf10tcl.store_sales sample (3000 rows);
create or replace table web_sales as select * from snowflake_sample_data.tpcds_sf10tcl.web_sales sample (3000 rows);
create or replace table catalog_sales as select * from snowflake_sample_data.tpcds_sf10tcl.catalog_sales sample (3000 rows);
alter table store_sales add column ss_last_update_time timestamp;
update store_sales set ss_last_update_time = current_timestamp();
alter table web_sales add column ws_last_update_time timestamp;
update web_sales set ws_last_update_time = current_timestamp();
alter table catalog_sales add column cs_last_update_time timestamp;
update catalog_sales set cs_last_update_time = current_timestamp();
create or replace secure view total_sales (sold_date_sk, item_sk, quantity, last_update_time) as
 with sales_union (date_sk, item_sk, quant, last_update) as 
 (
 select ss_sold_date_sk, ss_item_sk, ss_quantity, ss_last_update_time from store_sales union
 select ws_sold_date_sk, ws_item_sk, ws_quantity, ws_last_update_time from web_sales union
 select cs_sold_date_sk, cs_item_sk, cs_quantity, cs_last_update_time from catalog_sales
 )
 select * from sales_union order by last_update desc;


-- CRM DB has a secure MV and tags on CUSTOMER_DEMOGRAPHICS

use database crm;
create or replace table customer as select * from snowflake_sample_data.tpcds_sf10tcl.customer sample (1000 rows);
create or replace table customer_address as select * from snowflake_sample_data.tpcds_sf10tcl.customer_address sample (1000 rows);
create or replace table customer_demographics as select * from snowflake_sample_data.tpcds_sf10tcl.customer_demographics sample (1000 rows);
create or replace secure materialized view customers_by_state (state, customer_count) as
  select ca_state, count(*) 
  from crm.public.customer_address
  group by 1;


-- PRODUCTS DB has a row access policy on ITEM and a secure UDF

use database products;
create or replace table products.internal.inventory as 
  select * from snowflake_sample_data.tpcds_sf10tcl.inventory sample (1000 rows);
create or replace table products.public.item as 
  select * from snowflake_sample_data.tpcds_sf10tcl.item;

create or replace secure function products.internal.item_quantity()
returns table(item_id varchar, product_name varchar, quantity number)
as 'select i_item_id, i_product_name, inv_quantity_on_hand 
    from products.internal.inventory
    join products.public.item on inv_item_sk = i_item_sk
    '
;


-- CROSS_DATABASE DB contains a secure view that has a dependency on SALES, REFERENCES

use database cross_database;
create or replace table cross_database..income_band as 
  select * from snowflake_sample_data.tpcds_sf10tcl.income_band;
create or replace secure view cross_database..morning_sales (num_stores, lead_manager, num_employees) as 
select count(*), any_value(s_manager), median(s_number_employees)
from sales.public.store_sales
    ,references.lookups.household_demographics
    ,references.lookups.time_dim, references.lookups.store
where ss_sold_time_sk = time_dim.t_time_sk
    and ss_hdemo_sk = household_demographics.hd_demo_sk
    and ss_store_sk = s_store_sk
    and time_dim.t_hour < 12
order by count(*);


-- EXTERNALS DB contains an external table 

use database externals;
create or replace table promotions as 
  select * from snowflake_sample_data.tpcds_sf10tcl.promotion;
create or replace file format parquet_format type = parquet trim_space = true;
create or replace stage click_stream_stage storage_integration = s3click_int
  url = 's3://sfc-demo-data/click-stream-data/processed/date=2019-05-17/'
  file_format = externals.public.parquet_format;

list @public.click_stream_stage;

--Fails on GCP Primary with because storage type different from cloud provider.
/*create external table if not exists external_db.public.clickstream_ext
  location = @external_db.public.click_stream_stage
  file_format = external_db.public.parquet_format;*/

create or replace external table externals.public.clickstream_ext
  location = @externals.public.click_stream_stage
  file_format = externals.public.parquet_format;
  
describe external table externals.public.clickstream_ext;
select * from externals.public.clickstream_ext limit 10;

alter warehouse etl_wh set warehouse_size='X-Small';

-- Setup SHARES with various characteristics

-- SALES_HISTORY_SHARE: all objects contained in SALES DB
create or replace share sales_history_share;
grant usage on database sales to share sales_history_share;
grant usage on schema sales.public to share sales_history_share;
grant select on view sales.public.total_sales to share sales_history_share;

-- CRM_SHARE: REFERENCE_USAGE on REFERENCES for tag on CUSTOMER_DEMOGRAPHICS
create or replace share crm_share;
grant usage on database crm to share crm_share;
grant usage on schema crm.public to share crm_share;
grant select on all tables in schema crm.public to share crm_share;
grant reference_usage on database references to share crm_share;
grant select on view crm.public.customers_by_state to share crm_share;

-- INVENTORY_SHARE: REFERENCE_USAGE on REFERENCES for row-access policy on ITEM
create or replace share inventory_share;
grant usage on database products to share inventory_share;
grant usage on schema products.internal to share inventory_share;
grant usage on schema products.public to share inventory_share;
grant reference_usage on database references to share inventory_share;
grant usage on function products.internal.item_quantity() to share inventory_share;

-- CROSS_DATABASE_SHARE: view MORNING_SALES references tables in SALES, REFERENCES
create or replace share cross_database_share;
grant usage on database cross_database to share cross_database_share;
grant usage on schema cross_database.public to share cross_database_share;
grant reference_usage on database sales to share cross_database_share;
grant reference_usage on database references to share cross_database_share;
grant select on view cross_database.public.morning_sales to share cross_database_share;


-- SQL Stored Proc to modify sales tables
create or replace procedure sales..update_sales()
returns varchar
language sql
as
-- add the "$$" delimiter if running in classic UI
-- $$ 
begin
  insert into sales..store_sales select *, current_timestamp() 
    from snowflake_sample_data.tpcds_sf10tcl.store_sales sample (100 rows);
  insert into sales..web_sales select *, current_timestamp() 
    from snowflake_sample_data.tpcds_sf10tcl.web_sales sample (100 rows);
  insert into sales..catalog_sales select *, current_timestamp() 
    from snowflake_sample_data.tpcds_sf10tcl.catalog_sales sample (100 rows);

  update sales..store_sales set ss_quantity = (store_sales.ss_quantity + abs(random()%100)) 
    where  minute(ss_last_update_time) > (minute(current_timestamp())-3);
  update sales..web_sales set ws_quantity = (web_sales.ws_quantity + abs(random()%100)) 
    where  minute(ws_last_update_time) > (minute(current_timestamp())-3);
  update sales..catalog_sales set cs_quantity = (catalog_sales.cs_quantity + abs(random()%100)) 
    where  minute(cs_last_update_time) > (minute(current_timestamp())-3);

  insert into references.lookups.household_demographics 
    select * from snowflake_sample_data.tpcds_sf10tcl.household_demographics sample (5 rows);
  insert into crm..customer 
    select * from snowflake_sample_data.tpcds_sf10tcl.customer sample (5 rows);
  insert into products..item 
    select * from snowflake_sample_data.tpcds_sf10tcl.item sample (5 rows);
  insert into cross_database..income_band 
    select * from snowflake_sample_data.tpcds_sf10tcl.income_band sample (5 rows);
  
  commit;

  return('Done!');
end;
-- $$
-- ;

-- Account Failover objects
--
use schema snowflake_ha_monitor.public;
create or replace table snowflake_ha_monitor_event (last_test_ts timestamp_ltz);

-- Canary Query that verifies account liveness
create or replace procedure snowflake_ha_monitor_sp()
returns string
language javascript
as
$$
// truncate table before inserting a new timestamp
snowflake.execute({sqlText: "truncate snowflake_ha_monitor_event"});
// insert a new timestamp into the event table
snowflake.execute({sqlText: "insert into snowflake_ha_monitor_event values (current_timestamp)"});
// select the newly inserted row
snowflake.execute({sqlText: "select * from snowflake_ha_monitor_event"});
return "Success";
$$
;
