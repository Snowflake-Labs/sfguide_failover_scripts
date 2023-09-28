-- Run this on the Secondary first, then you will be allowed to cleanup the Primary
use role accountadmin;

drop failover group if exists sales_payroll_financials;
drop connection if exists prodsnowgrid;
