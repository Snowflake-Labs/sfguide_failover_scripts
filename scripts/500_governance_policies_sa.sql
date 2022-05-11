--------Governance policies---------------
use role governance_admin;
create tag if not exists common.utility.cost_center allowed_values 'accounting','IT','Marketing','HR'; 
create tag if not exists common.utility.security_classification allowed_values 'sensitive','confidential','public';

alter table payroll.noam_northeast.employee_detail set tag common.utility.cost_center='HR';
alter table payroll.noam_northeast.employee_detail modify column email set tag common.utility.security_classification = 'sensitive';
alter table payroll.noam_northeast.employee_detail modify column ssn set tag common.utility.security_classification = 'confidential';
alter table payroll.noam_northeast.employee_detail modify column iban set tag common.utility.security_classification = 'confidential';
alter table payroll.noam_northeast.employee_detail modify column salary set tag common.utility.security_classification = 'sensitive';
alter table payroll.noam_northeast.employee_detail modify column cc set tag common.utility.security_classification = 'confidential';
alter table payroll.noam_northeast.employee_detail modify column first_name set tag common.utility.security_classification = 'sensitive';
alter table payroll.noam_northeast.employee_detail modify column last_name set tag common.utility.security_classification = 'sensitive';

create masking policy if not exists common.utility.mask_email as (email string) returns string ->
    case
        when current_role() in ('HR_ADMIN','PRODUCT_MANAGER') then email
        else regexp_replace(email,'.+\@','*****@')
    end;

 create masking policy if not exists common.utility.mask_iban as (iban string) returns string ->
    case
        when current_role() in ('HR_ADMIN','PRODUCT_MANAGER') then iban
        else '********'
    end;

 create masking policy if not exists common.utility.mask_cc as (cc string) returns string ->
    case
        when current_role() in ('HR_ADMIN','PRODUCT_MANAGER') then cc
        else '********'
    end;

 create masking policy if not exists common.utility.mask_ssn as (ssn string) returns string ->
    case
        when current_role() in ('HR_ADMIN','PRODUCT_MANAGER') then ssn
        else '********'
    end;

 create masking policy if not exists common.utility.mask_salary as (salary number) returns number ->
    case
        when current_role() in ('HR_ADMIN','PRODUCT_MANAGER') then salary
        else 0.00
    end;

alter table payroll.noam_northeast.employee_detail modify column email set masking policy common.utility.mask_email;
alter table payroll.noam_northeast.employee_detail modify column ssn set masking policy common.utility.mask_ssn;
alter table payroll.noam_northeast.employee_detail modify column iban set masking policy common.utility.mask_iban;
alter table payroll.noam_northeast.employee_detail modify column salary set masking policy common.utility.mask_salary;
alter table payroll.noam_northeast.employee_detail modify column cc set masking policy common.utility.mask_cc;

create row access policy if not exists common.utility.mkt_segment_rls_policy as (c_mktsegment varchar) returns boolean ->
     'PRODUCT_MANAGER' = current_role()
     or  
     exists (select 1 from 
              common.utility.mkt_segment_mapping 
              where sales_role = current_role() 
              and market_segment = c_mktsegment);

alter table global_sales.online_retail.customer add row access policy common.utility.mkt_segment_rls_policy on (c_mktsegment);


