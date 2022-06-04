use role securityadmin;

grant usage,operate on warehouse finance_wh to role finance_analyst;
grant usage on database stores  to role finance_analyst;
grant usage on database support to role finance_analyst;
grant usage on all schemas in database stores to role finance_analyst;
grant usage on all schemas in database support to role finance_analyst;
grant usage on future schemas in database stores to role finance_analyst;
grant usage on future schemas in database support to role finance_analyst;

grant usage,modify on warehouse finance_wh to role finance_admin;
grant usage,modify,create schema on database stores to role finance_admin;
grant usage,modify,create schema on database support to role finance_admin;
grant usage,create table,create view on all schemas in database stores to role finance_admin;
grant usage,create table,create view on future schemas in database stores to role finance_admin;
grant usage,create table,create view on all schemas in database support to role finance_admin;
grant usage,create table,create view on future schemas in database support to role finance_admin;

grant usage,operate on warehouse sales_wh to role sales_analyst;
grant usage on database global_sales to role sales_analyst;
grant usage on database inventory to role sales_analyst;
grant usage on all schemas in database global_sales to role sales_analyst;
grant usage on all schemas in database inventory to role sales_analyst;
grant usage on future schemas in database global_sales to role sales_analyst;
grant usage on future schemas in database inventory to role sales_analyst;
grant select on future tables in schema global_sales.online_retail to role sales_analyst;

grant usage,modify on warehouse sales_wh to role sales_admin;
grant usage,modify,create schema on database global_sales to role sales_admin;
grant usage,modify,create schema on database inventory to role sales_admin;
grant usage,create table,create view on all schemas in database global_sales to role sales_admin;
grant usage,create table,create view on future schemas in database global_sales to role sales_admin;
grant usage,create table,create view on all schemas in database inventory to role sales_admin;
grant usage,create table,create view on future schemas in database inventory to role sales_admin;
grant select on future tables in schema global_sales.online_retail to role sales_admin;

grant usage,operate on warehouse bi_reporting_wh to role marketing_analyst;
grant usage on database salesforce to role marketing_analyst;
grant usage on database loyalty to role marketing_analyst;
grant usage on all schemas in database salesforce to role marketing_analyst;
grant usage on all schemas in database loyalty to role marketing_analyst;
grant usage on future schemas in database salesforce to role marketing_analyst;
grant usage on future schemas in database loyalty to role marketing_analyst;

grant usage,modify on warehouse bi_reporting_wh to role marketing_admin;
grant usage,modify,create schema on database salesforce to role marketing_admin;
grant usage,modify,create schema on database loyalty to role marketing_admin; 
grant usage,create table,create view on all schemas in database salesforce to role marketing_admin;
grant usage,create table,create view on future schemas in database salesforce to role marketing_admin;
grant usage,create table,create view on all schemas in database loyalty to role marketing_admin;
grant usage,create table,create view on future schemas in database loyalty to role marketing_admin;

grant usage,operate on warehouse hr_wh to role hr_analyst;
grant usage on database payroll to role hr_analyst;
grant usage on database suppliers to role hr_analyst;
grant usage on all schemas in database payroll to role hr_analyst;
grant usage on all schemas in database suppliers to role hr_analyst;
grant usage on future schemas in database payroll to role hr_analyst;
grant usage on future schemas in database suppliers to role hr_analyst;
grant select on future tables in schema payroll.noam_northeast to role hr_analyst;

grant usage,modify on warehouse hr_wh to role hr_admin;
grant usage,modify,create schema on database payroll to role hr_admin;
grant usage,modify,create schema on database suppliers to role hr_admin;
grant usage,create table,create view on all schemas in database payroll to role hr_admin;
grant usage,create table,create view on future schemas in database payroll to role hr_admin;
grant usage,create table,create view on all schemas in database suppliers to role hr_admin;
grant usage,create table,create view on future schemas in database suppliers to role hr_admin;
grant select on future tables in schema payroll.noam_northeast to role hr_admin;

grant usage,modify,create schema on database common to role governance_admin;
grant usage,create table,create view on schema common.utility to role governance_admin;
grant select on all tables in schema common.utility to role governance_admin;
grant select on future tables in schema common.utility to role governance_admin;
grant create masking policy on schema common.utility to role governance_admin;
grant create row access policy on schema common.utility to role governance_admin;
grant create tag on schema common.utility to role governance_admin;

--Account level grants for gov admin
use role accountadmin;
grant apply masking policy on account to role governance_admin;
grant apply row access policy on account to role governance_admin;
grant apply tag on account to role governance_admin;

-- Share creation privilege for sysadmin
grant create share on account to role sysadmin;
grant import share on account to role sysadmin;

----------------------Create Personas------------------
use role securityadmin;

-- REPLACE with your username
grant role product_manager to user REPLACEME;
grant role data_science to user REPLACEME;
grant role governance_admin to user REPLACEME;

grant role finance_analyst to user Adam;
grant role finance_analyst to user Jenna;
grant role finance_analyst to user Anand;

grant role finance_admin to user Dan;
grant role finance_admin to user Sachin;
grant role finance_admin to user Aaron;

grant role sales_analyst to user Alex;
grant role sales_analyst to user Brett;
grant role sales_analyst to user Brian;

grant role sales_admin to user Caroline;
grant role sales_admin to user Dinesh;
grant role sales_admin to user Diana;

grant role marketing_analyst to user Divya;
grant role marketing_analyst to user Emma;
grant role marketing_analyst to user Grace;

grant role marketing_admin to user Irina;
grant role marketing_admin to user Jack;
grant role marketing_admin to user Justin;

grant role hr_analyst to user Zack;
grant role hr_analyst to user Frank;
grant role hr_analyst to user Praveen;

grant role hr_admin to user David;
grant role hr_admin to user Prasanna;
grant role hr_admin to user Padmaja;
