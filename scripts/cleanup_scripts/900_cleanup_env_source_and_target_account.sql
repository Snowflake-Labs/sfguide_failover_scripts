#Run this on both source and target account
-----------------------------------------------------------------------------------------
---
--- CLEANUP_SOURCE_AND_TARGET_ACCOUNT
---
-----------------------------------------------------------------------------------------

use role accountadmin;

-- first drop all shares
drop share if exists global_sales_share;
drop share if exists sales_history_share;
drop share if exists crm_share;
drop share if exists inventory_share;
drop share if exists cross_database_share;

use role sysadmin;
-- now drop all databases
drop database if exists crm cascade;
drop database if exists cross_database cascade;
drop database if exists externals cascade;
drop database if exists products cascade;
drop database if exists references cascade;
drop database if exists sales cascade;
drop database if exists global_sales cascade;
drop database if exists inventory cascade;
drop database if exists loyalty cascade;
drop database if exists payroll cascade;
drop database if exists salesforce cascade;
drop database if exists common cascade;
drop database if exists stores cascade;
drop database if exists suppliers cascade;
drop database if exists support cascade;
drop database if exists web_logs cascade;
drop database if exists snowflake_ha_monitor cascade;

drop warehouse if exists load_wh;
drop warehouse if exists query_wh;
drop warehouse if exists sales_wh;
drop warehouse if exists accounting_wh;
drop warehouse if exists analytics_wh;
drop warehouse if exists etl_wh;
drop warehouse if exists bi_reporting_wh;
drop warehouse if exists finance_wh;
drop warehouse if exists hr_wh;
drop warehouse if exists it_wh;
drop warehouse if exists data_science_wh;
drop warehouse if exists product_wh;
drop warehouse if exists sales_wh;
drop warehouse if exists ops_support_wh;
drop warehouse if exists sandbox_wh;
drop warehouse if exists snowflake_ha_monitor_1_wh;
drop warehouse if exists snowflake_ha_monitor_2_wh;

use role securityadmin;
drop role if exists product_manager;
drop role if exists data_science;
drop role if exists governance_admin;
drop role if exists finance_analyst;
drop role if exists finance_admin;
drop role if exists sales_analyst;
drop role if exists sales_admin;
drop role if exists marketing_analyst;
drop role if exists marketing_admin;
drop role if exists master_data_access;
drop role if exists hr_analyst;
drop role if exists hr_admin;

drop user if exists Adam;
drop user if exists Jenna;
drop user if exists Anand;
drop user if exists Dan;
drop user if exists Sachin;
drop user if exists Aaron;
drop user if exists Alex;
drop user if exists Brett;
drop user if exists Brian;
drop user if exists Caroline;
drop user if exists Dinesh;
drop user if exists Diana;
drop user if exists Divya;
drop user if exists Emma;
drop user if exists Grace;
drop user if exists Irina;
drop user if exists Jack;
drop user if exists Justin;
drop user if exists Zack;
drop user if exists Frank;
drop user if exists Praveen;
drop user if exists David;
drop user if exists Prasanna;
drop user if exists Padmaja;
drop user if exists "snowflake_ha_tester";

use role accountadmin;
drop resource monitor if exists toplimit;
drop resource monitor if exists dailylimit;

drop storage integration if exists s3click_int;
