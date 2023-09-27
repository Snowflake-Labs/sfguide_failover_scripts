-- Scripts for the 3 Tiles in the dashboard
--

use role accountadmin;
use warehouse 

-- SALES METRICS
select count(*) TRANSACTIONS, median(quantity) MEDIAN_QTY, max(last_update_time) LAST_UPDATE
from sales..total_sales;

-- SNOWFLAKE ACCOUNT
select current_region() as CLOUD_REGION, current_account() as ACCOUNT_LOCATOR;

-- STORE SALES
select * from cross_database.public.morning_sales;