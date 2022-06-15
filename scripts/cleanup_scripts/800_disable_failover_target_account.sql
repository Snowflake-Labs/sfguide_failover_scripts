#Drop FG and connection on the secondary account first
use role accountadmin;

drop failover group sales_payroll_failover;
drop connection sfsummitfailover;
