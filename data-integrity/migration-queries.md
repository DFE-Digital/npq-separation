## POC queries

``` sql
CREATE EXTENSION IF NOT EXISTS dblink;
```

``` sql
SELECT tb1.id, tb1.ecf_id, tb2.name, tb2.created_at, tb2.updated_at, tb2.cpd_lead_provider_id, tb2.vat_chargeable, tb1.hint
FROM lead_providers tb1
LEFT JOIN (
SELECT *
FROM dblink('dbname=early_careers_framework_development','SELECT id, name, created_at, updated_at, cpd_lead_provider_id, vat_chargeable FROM npq_lead_providers')
AS tb2(id text, "name" varchar, created_at timestamp, updated_at timestamp, cpd_lead_provider_id uuid, vat_chargeable boolean)
) AS tb2 ON tb2.id = tb1.ecf_id;
```

``` sql
SELECT *
FROM information_schema.columns
WHERE table_schema = 'public'
AND column_name like '%_id';
```

``` sql
ALTER TABLE applications
ADD COLUMN new_lead_provider_id uuid;
```

``` sql
update applications a set new_lead_provider_id = lps.ecf_id::uuid
from (
SELECT tb1.id, tb1.ecf_id, tb2.name, tb2.created_at, tb2.updated_at, tb2.cpd_lead_provider_id, tb2.vat_chargeable, tb1.hint
FROM lead_providers tb1
LEFT JOIN (
SELECT *
FROM dblink('dbname=early_careers_framework_development','SELECT id, name, created_at, updated_at, cpd_lead_provider_id, vat_chargeable FROM npq_lead_providers')
AS tb2(id text, "name" varchar, created_at timestamp, updated_at timestamp, cpd_lead_provider_id uuid, vat_chargeable boolean)
) AS tb2 ON tb2.id = tb1.ecf_id
) lps where a.lead_provider_id = lps.id;
```

``` sql
ALTER TABLE applications
DROP COLUMN lead_provider_id;
```

``` sql
ALTER TABLE applications
RENAME COLUMN new_lead_provider_id TO lead_provider_id;
```

``` sql
ALTER TABLE applications
ALTER COLUMN lead_provider_id SET NOT NULL;
```

### Example of applications record with new lead provider id (migrated from ECF app)
_(dummy data)_

|id|lead_provider_id|user_id|course_id|school_urn|created_at|updated_at|ecf_id|headteacher_status|eligible_for_funding|funding_choice|ukprn|teacher_catchment|teacher_catchment_country|works_in_school|employer_name|employment_role|private_childcare_provider_urn|works_in_nursery|works_in_childcare|kind_of_nursery|DEPRECATED_cohort|targeted_delivery_funding_eligibility|funding_eligiblity_status_code|raw_application_data|work_setting|teacher_catchment_synced_to_ecf|employment_type|itt_provider|lead_mentor|primary_establishment|number_of_pupils|tsf_primary_eligibility|tsf_primary_plus_eligibility|lead_provider_approval_status|participant_outcome_state|lead_provider_id|
|--|----------------|-------|---------|----------|----------|----------|------|------------------|--------------------|--------------|-----|-----------------|-------------------------|---------------|-------------|---------------|------------------------------|----------------|------------------|---------------|-----------------|-------------------------------------|------------------------------|--------------------|------------|-------------------------------|---------------|------------|-----------|---------------------|----------------|-----------------------|----------------------------|-----------------------------|-------------------------|----------------|
|51158|ef687b3d-c1c0-4566-a295-16d6fa5d0fa7|12345|10|123456|2022-07-19 14:41:21.025|2023-11-10 08:04:12.097|cfadea97-2539-4be3-9b86-30d4404ee6f6||true||10047142|england||true||||false|false||2022|false|funded|{"trn": "1234567", "email": "test@test.uk", "course_id": "10", "full_name": "Test Example", "active_alert": false, "trn_verified": true, "verified_trn": "1234567", "date_of_birth": "2000-04-21", "trn_knowledge": "yes", "chosen_provider": "yes", "confirmed_email": "text@example.com", "works_in_school": "yes", "institution_name": "", "lead_provider_id": "9", "can_share_choices": "1", "teacher_catchment": "england", "trn_auto_verified": true, "institution_location": "Nowhere", "institution_identifier": "School-141248", "national_insurance_number": "123456789", "teacher_catchment_country": null}||true|||false|false|0|false|false|pending||ef687b3d-c1c0-4566-a295-16d6fa5d0fa7|

### Example of query to fetch users record with ECF reg data merged with NPQ reg data

``` sql
select
tb1.id,
tb1.email,
tb1.created_at,
tb1.updated_at,
tb1.ecf_id,
tb2.id,
tb1.trn,
tb1.full_name,
tb1.otp_hash,
tb1.otp_expires_at,
tb1.date_of_birth,
tb1.trn_verified,
tb1.active_alert,
tb1.national_insurance_number,
tb1.trn_auto_verified,
tb1.admin,
tb1.feature_flag_id,
tb1.provider,
tb1.uid,
tb1.raw_tra_provider_data,
tb1.get_an_identity_id_synced_to_ecf,
tb1.super_admin,
tb1.updated_from_tra_at,
tb1.trn_lookup_status,
tb2.full_name,
tb2.email,
tb2.login_token,
tb2.login_token_valid_until,
tb2.remember_created_at,
tb2.last_sign_in_at,
tb2.current_sign_in_at,
tb2.current_sign_in_ip,
tb2.last_sign_in_ip,
tb2.sign_in_count,
tb2.created_at,
tb2.updated_at,
tb2.discarded_at,
tb2.get_an_identity_id,
tb2.archived_email,
tb2.archived_at
from
users tb1
left join (
select
*
from
dblink('dbname=early_careers_framework_development',
select id,
full_name,
email,
login_token,
login_token_valid_until,
remember_created_at,
last_sign_in_at,
current_sign_in_at,
current_sign_in_ip,
last_sign_in_ip,
sign_in_count,
created_at,
updated_at,
discarded_at,
get_an_identity_id,
archived_email,
archived_at
from users
)
as tb2(id text,
full_name varchar,
email text,
login_token text,
login_token_valid_until timestamp,
remember_created_at timestamp,
last_sign_in_at timestamp,
current_sign_in_at timestamp,
current_sign_in_ip inet,
last_sign_in_ip inet,
sign_in_count integer,
created_at timestamp,
updated_at timestamp,
discarded_at timestamp,
get_an_identity_id text,
archived_email text,
archived_at timestamp)
) as tb2 on
tb2.id = tb1.ecf_id;
```
