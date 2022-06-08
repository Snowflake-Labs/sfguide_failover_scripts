use role securityadmin;

--Finance Analysts
create user if not exists Adam
    password = SnowflakeHOL22
    login_name = Adam
    display_name = 'Adam'
    first_name = 'Adam'
    must_change_password = false
    default_role = finance_analyst
    default_warehouse = finance_wh;

create user if not exists Jenna
    password = SnowflakeHOL22
    login_name = Jenna
    display_name = 'Jenna'
    first_name = 'Jenna'
    must_change_password = false
    default_role = finance_analyst
    default_warehouse = finance_wh;

create user if not exists Anand
    password = SnowflakeHOL22
    login_name = Anand
    display_name = 'Anand'
    first_name = 'Anand'
    must_change_password = false
    default_role = finance_analyst
    default_warehouse = finance_wh;

--Finance Admin
create user if not exists Dan
    password = SnowflakeHOL22
    login_name = Dan
    display_name = 'Dan'
    first_name = 'Dan'
    must_change_password = false
    default_role = finance_admin
    default_warehouse = finance_wh;

create user if not exists Sachin
    password = SnowflakeHOL22
    login_name = Sachin
    display_name = 'Sachin'
    first_name = 'Sachin'
    must_change_password = false
    default_role = finance_admin
    default_warehouse = finance_wh;

create user if not exists Aaron
    password = SnowflakeHOL22
    login_name = Aaron
    display_name = 'Aaron'
    first_name = 'Aaron'
    must_change_password = false
    default_role = finance_admin
    default_warehouse = finance_wh;

--Sales Analyst
create user if not exists Alex
    password = SnowflakeHOL22
    login_name = Alex
    display_name = 'Alex'
    first_name = 'Alex'
    must_change_password = false
    default_role = sales_analyst
    default_warehouse = sales_wh;

create user if not exists Brett
    password = SnowflakeHOL22
    login_name = Brett
    display_name = 'Brett'
    first_name = 'Brett'
    must_change_password = false
    default_role = sales_analyst
    default_warehouse = sales_wh;

create user if not exists Brian
    password = SnowflakeHOL22
    login_name = Brian
    display_name = 'Brian'
    first_name = 'Brian'
    must_change_password = false
    default_role = sales_analyst
    default_warehouse = sales_wh;

--Sales Admin
create user if not exists Caroline
    password = SnowflakeHOL22
    login_name = Caroline
    display_name = 'Caroline'
    first_name = 'Caroline'
    must_change_password = false
    default_role = sales_admin
    default_warehouse = sales_wh;

create user if not exists Dinesh
    password = SnowflakeHOL22
    login_name = Dinesh
    display_name = 'Dinesh'
    first_name = 'Dinesh'
    must_change_password = false
    default_role = sales_admin
    default_warehouse = sales_wh;

create user if not exists Diana
    password = SnowflakeHOL22
    login_name = Diana
    display_name = 'Diana'
    first_name = 'Diana'
    must_change_password = false
    default_role = sales_admin
    default_warehouse = sales_wh;

--Marketing Analyst
create user if not exists Divya
    password = SnowflakeHOL22
    login_name = Divya
    display_name = 'Divya'
    first_name = 'Divya'
    must_change_password = false
    default_role = marketing_analyst
    default_warehouse = bi_reporting_wh;

create user if not exists Emma
    password = SnowflakeHOL22
    login_name = Emma
    display_name = 'Emma'
    first_name = 'Emma'
    must_change_password = false
    default_role = marketing_analyst
    default_warehouse = bi_reporting_wh;

create user if not exists Grace
    password = SnowflakeHOL22
    login_name = Grace
    display_name = 'Grace'
    first_name = 'Grace'
    must_change_password = false
    default_role = marketing_analyst
    default_warehouse = bi_reporting_wh;

--Marketing Admin
create user if not exists Irina
    password = SnowflakeHOL22
    login_name = Irina
    display_name = 'Irina'
    first_name = 'Irina'
    must_change_password = false
    default_role = marketing_admin
    default_warehouse = bi_reporting_wh;
    
create user if not exists Jack
    password = SnowflakeHOL22
    login_name = Jack
    display_name = 'Jack'
    first_name = 'Jack'
    must_change_password = false
    default_role = marketing_admin
    default_warehouse = bi_reporting_wh;
    
create user if not exists Justin
    password = SnowflakeHOL22
    login_name = Justin
    display_name = 'Justin'
    first_name = 'Justin'
    must_change_password = false
    default_role = marketing_admin
    default_warehouse = bi_reporting_wh;

--HR Analyst
create user if not exists Zack
    password = SnowflakeHOL22
    login_name = Zack
    display_name = 'Zack'
    first_name = 'Zack'
    must_change_password = false
    default_role = hr_analyst
    default_warehouse = hr_wh;
    
create user if not exists Frank
    password = SnowflakeHOL22
    login_name = Frank
    display_name = 'Frank'
    first_name = 'Frank'
    must_change_password = false
    default_role = hr_analyst
    default_warehouse = hr_wh;
    
create user if not exists Praveen
    password = SnowflakeHOL22
    login_name = Praveen
    display_name = 'Praveen'
    first_name = 'Praveen'
    must_change_password = false
    default_role = hr_analyst
    default_warehouse = hr_wh;

--HR Admin
create user if not exists David
    password = SnowflakeHOL22
    login_name = David
    display_name = 'David'
    first_name = 'David'
    must_change_password = false
    default_role = hr_admin
    default_warehouse = hr_wh;

create user if not exists Prasanna
    password = SnowflakeHOL22
    login_name = Prasanna
    display_name = 'Prasanna'
    first_name = 'Prasanna'
    must_change_password = false
    default_role = hr_admin
    default_warehouse = hr_wh;

create user if not exists Padmaja
    password = SnowflakeHOL22
    login_name = Padmaja
    display_name = 'Padmaja'
    first_name = 'Padmaja'
    must_change_password = false
    default_role = hr_admin
    default_warehouse = hr_wh;

-- Failover Detection User
create user if not exists "snowflake_ha_tester" 
    PASSWORD = SnowflakeHOL22 
    LOGIN_NAME = 'snowflake_ha_tester' 
    DISPLAY_NAME = 'snowflake_ha_tester' 
    FIRST_NAME = 'snowflake_ha_tester' 
    LAST_NAME = 'snowflake_ha_tester' 
    EMAIL = 'snowflake_ha_tester@acme.com' 
    DEFAULT_ROLE = "ACCOUNTADMIN" 
    DEFAULT_WAREHOUSE = 'snowflake_ha_monitor_1_wh' 
    MUST_CHANGE_PASSWORD = false;

grant role accountadmin TO user "snowflake_ha_tester";
