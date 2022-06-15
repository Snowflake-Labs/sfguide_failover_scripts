#Drop FG and connection on the source account
use role accountadmin;
alter connection sfsummitfailover disable failover to accounts <orgname.target_account_name>;
drop connection sfsummitfailover;

drop failover group sales_payroll_failover;
