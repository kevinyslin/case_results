## Questions ##

# ___________________________________________________________________________________________________

/*
Moddified Invoice table that is using through the analysis:
- Partitioning by invoice-transaction pairs, and ordering by the most recent pair ('Actice' Matches).
- Creating columns to pull previous values of 2 columns: expert_type and expert_opinion.
*/
create or replace table `Re_cap.invoices_mod` as
  select
    *,
    lead (expert_type) over (partition by invoice_id, transaction_id order by created_at desc) as prev_expert,
    lead (expert_opinion) over (partition by invoice_id, transaction_id order by created_at desc) as prev_opinion,
    row_number() over (partition by invoice_id, transaction_id order by created_at desc) as rn
  from `Re_cap.invoices`
  order by 1, 2, 9
;

# Data check, to observe the first rule:
# If there is a user “approved” match, it cannot be overwritten by a system match.
select
  *
from `Re_cap.invoices_mod`
where prev_expert = 'user'
  and prev_opinion = 'approved'
  and expert_type = 'system'
;

/* Results:
Returns null, so data is valid.
*/

# ___________________________________________________________________________________________________
# 1. For what percentage of invoices did the system propose at least one match?
# We filter by rn =1, to only get "Active" pairs
select 
  count (distinct invoice_id) as total_invoices,
  count (distinct case when expert_type = "system" then invoice_id end) as system_invoices,
  count (distinct case when expert_type = "system" then invoice_id end) *100.0 / count (distinct invoice_id) as perc_sys_invoices
from `Re_cap.invoices_mod`
where rn = 1
;

/* Results:
Total unique Invoices = 850
Unique Sytem Invoices = 549
Percentage of invoices from system = 64.59%
*/

# ___________________________________________________________________________________________________
# 2. What is the total amount of invoices that have at least one active rejected match by our customers?
select 
  count (distinct invoice_id) as total_invoices,
from `Re_cap.invoices_mod`
where rn = 1
  and expert_opinion = "rejected"
  and expert_type = "user"
;

/* Results:
Total unique Invoices = 208
*/

# ___________________________________________________________________________________________________
# 3. Which 5 customers have the most reconciled invoices? What percentage of those were reconciled by the system versus the customers?
with
# Counting all permutations of active matches per invoice
invoice_agg as (
  select
    invoice_id,
    count (case when expert_type = "system" and expert_opinion = "approved" then invoice_id end) as approved_system,
    count (case when expert_type = "user" and expert_opinion = "approved" then invoice_id end) as approved_user,
    count (case when expert_type = "system" and expert_opinion = "rejected" then invoice_id end) as rejected_system,
    count (case when expert_type = "user" and expert_opinion = "rejected" then invoice_id end) as rejected_user,
  from `Re_cap.invoices_mod`
  where rn =1
  group by 1
),
# Join with exported data, and detail company_id with invoice data. Since question is about reconciled invoices we only pull that data.
# Definition: An invoice is considered “reconciled” if it has at least one active approved match.
main as (
  select distinct
    a.company_id,
    a.company_name,
    a.invoice_id,
    b.approved_system,
    b.approved_user,
    b.approved_system + b.approved_user as total_reconciled
  from `Re_cap.endpoint_export` as a
  left join invoice_agg as b
    on a.invoice_id = b.invoice_id
)
select 
  company_id,
  company_name,
  count (distinct invoice_id) as total_invoices,
  count (distinct case when total_reconciled > 0 then invoice_id end) as reconciled_invoices,
  count (distinct case when approved_system > 0 then invoice_id end) as invoice_system,
  count (distinct case when approved_user > 0 then invoice_id end) as invoice_user,
from main
group by 1,2
order by 4 desc
limit 5
;

/* Results:
company_id	                            company_name	        total_invoices	reconciled_invoices	invoice_system	invoice_user
d66bfb15-e693-4219-9cb0-c5ecbb61a994	ETL Enterprises	        107	            92	                64	            28
da36911c-7145-4c19-8e82-35c39f3a2e9c	AlgoRhythm Solutions	  98	            79	                56	            23
c5ccae70-d802-4502-8b25-9be976292ccb	Pipeline Pioneers AG	  95	            73	                53	            20
ed811a71-439e-4c49-bfb8-8fb407c39428	DataLake Ventures	      88	            69	                44	            25
640cf7f1-51c7-4c74-bff4-074303a1b191	Vector Velocity Inc	    84	            69	                55	            14
*/