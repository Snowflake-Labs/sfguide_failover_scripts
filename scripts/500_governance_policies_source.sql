--------Governance policies---------------
use role governance_admin;
create tag if not exists common.utility.cost_center allowed_values 'accounting','IT','Marketing','HR'; 
create tag if not exists common.utility.security_classification allowed_values 'sensitive','confidential','public';
create tag if not exists references.tags.gender allowed_values 'male','female','non-binary', 'trans','unknown';
create tag if not exists references.tags.owner;

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

create masking policy if not exists references.policies.name_mask as (val string) returns string ->
  case
    when current_role() in ('PRODUCT_MANAGER') then val
    when invoker_share() in ('CROSS_DATABASE_SHARE') then val
    else '**********'
  end;
create row access policy if not exists references.policies.rap_item_history as (limit_date date) returns boolean ->
  case
    when current_role() in ('PRODUCT_MANAGER') then true
    when year(limit_date) < 2000 then true
    else false
  end;

alter table references.lookups.store modify column s_manager set masking policy references.policies.name_mask;
alter table products.public.item add row access policy references.policies.rap_item_history on (i_rec_start_date);
alter table crm.public.customer_demographics modify column cd_gender set tag references.tags.gender = 'unknown';

alter warehouse bi_reporting_wh set tag references.tags.owner = 'labrunner';
alter warehouse etl_wh set tag references.tags.owner = 'non-binary';
