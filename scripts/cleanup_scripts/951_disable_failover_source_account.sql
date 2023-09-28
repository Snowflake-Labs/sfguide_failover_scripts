-- Replica connection and failover group on the Secondary must be dropped first

use role accountadmin;
alter connection prodsnowgrid disable failover to accounts <orgname.target_account_name>;
drop connection if exists prodsnowgrid;

drop failover group if exists sales_payroll_financials;
