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
