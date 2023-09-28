-- Force refresh of Dynamic Tables after a failover, when all are stuck in INITIALIZING state
use role accountadmin;

use schema tpcdi_wh.base;

alter dynamic table DIM_FINANCIAL_ROLL_YEAR_EPS refresh;

alter dynamic table DIM_SECURITY_NOW refresh;