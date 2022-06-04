use role securityadmin;

create role if not exists sales_admin;
create role if not exists marketing_admin;
create role if not exists data_science;
create role if not exists finance_admin;
create role if not exists hr_admin;
create role if not exists product_manager;
create role if not exists governance_admin;
create role if not exists sales_analyst;
create role if not exists marketing_analyst;
create role if not exists finance_analyst;
create role if not exists hr_analyst;
create role if not exists master_data_access;

--Roles hierarchy
grant role sales_analyst to role sales_admin;
grant role hr_analyst to role hr_admin;
grant role finance_analyst to role finance_admin;
grant role marketing_analyst to role marketing_admin;
grant role marketing_admin to role master_data_access;
grant role finance_admin to role master_data_access;
grant role hr_admin to role master_data_access;
grant role sales_admin to role master_data_access;
grant role master_data_access to role product_manager;
grant role master_data_access to role data_science;
grant role product_manager to role sysadmin;
grant role data_science to role sysadmin;
grant role governance_admin to role sysadmin;

use role sysadmin;

create database if not exists global_sales;
create database if not exists inventory;
create database if not exists loyalty;
create database if not exists payroll;
create database if not exists salesforce;
create database if not exists common;
create database if not exists stores;
create database if not exists suppliers;
create database if not exists support;
create database if not exists web_logs;
create schema if not exists common.utility;
create schema if not exists global_sales.online_retail;
create schema if not exists payroll.noam_northeast;

create warehouse if not exists accounting_wh
    warehouse_size = 'x-small'
    initially_suspended = true
    auto_suspend = 180;
    
create warehouse if not exists analytics_wh
    warehouse_size = 'x-small'
    initially_suspended = true
    auto_suspend = 180;

create warehouse if not exists etl_wh
    warehouse_size = 'x-small'
    initially_suspended = true
    auto_suspend = 180;
    
create warehouse if not exists bi_reporting_wh
    warehouse_size = 'x-small'
    initially_suspended = true
    auto_suspend = 180;
    
create warehouse if not exists finance_wh
    warehouse_size = 'x-small'
    initially_suspended = true
    auto_suspend = 180;
    
create warehouse if not exists hr_wh
    warehouse_size = 'x-small'
    initially_suspended = true
    auto_suspend = 180;
    
create warehouse if not exists it_wh
    warehouse_size = 'x-small'
    initially_suspended = true
    auto_suspend = 180;
    
create warehouse if not exists data_science_wh
    warehouse_size = 'x-small'
    initially_suspended = true
    auto_suspend = 180;
    
create warehouse if not exists product_wh
    warehouse_size = 'x-small'
    initially_suspended = true
    auto_suspend = 180;
    
create warehouse if not exists sales_wh
    warehouse_size = 'x-small'
    initially_suspended = true
    auto_suspend = 180;
    
create warehouse if not exists ops_support_wh
    warehouse_size = 'x-small'
    initially_suspended = true
    auto_suspend = 180;
    
create warehouse if not exists sandbox_wh
    warehouse_size = 'x-small'
    initially_suspended = true
    auto_suspend = 180;

create warehouse if not exists snowflake_ha_monitor_1_wh with warehouse_size = 'xsmall' 
    auto_suspend = 10800 auto_resume = true min_cluster_count = 1 max_cluster_count = 1 scaling_policy = 'standard';
create warehouse if not exists snowflake_ha_monitor_2_wh with warehouse_size = 'xsmall' 
    auto_suspend = 60 auto_resume = true min_cluster_count = 1 max_cluster_count = 1 scaling_policy = 'standard';

use role accountadmin;

--Create resource monitors and apply to WHs that require credit monitoring.
create resource monitor if not exists toplimit with credit_quota=300
    frequency = monthly
    start_timestamp = immediately
    triggers on 100 percent do suspend;
    
create resource monitor if not exists dailylimit with credit_quota=100
    frequency = daily
    start_timestamp = immediately
    triggers on 75 percent do notify
             on 100 percent do suspend;

alter warehouse finance_wh set resource_monitor = dailylimit;
alter warehouse bi_reporting_wh set resource_monitor = dailylimit;
