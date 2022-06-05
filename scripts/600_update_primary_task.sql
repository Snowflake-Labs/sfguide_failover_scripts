-----------------------------------------------------------------------------------------
---
--- 600_update_primary_task.sql
---
--- Create and start task to update Primary tables every 3 minutes
--- 
--  PLEASE REMEMBER TO SUSPEND TASK AFTER YOUR TESTING
-----------------------------------------------------------------------------------------

use role sysadmin;
use warehouse it_wh;

-- ALTER TASK REFERENCES..UPDATESALES SUSPEND;

CREATE OR REPLACE TASK REFERENCES..UPDATESALES
    WAREHOUSE = etl_wh
    SCHEDULE = '3 minute'
AS
    CALL sales..update_sales();

use role accountadmin;
ALTER TASK REFERENCES..UPDATESALES RESUME;

select name, database_name, state, scheduled_time, completed_time
  from table(references.information_schema.task_history())
  order by scheduled_time desc;
