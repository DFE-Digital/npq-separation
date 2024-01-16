# Data integrity

## Proposed Data Migration Plan

We plan on running a script to migrate the NPQ data from ECF to NPQ registration; this will be a 'big bang' data migration. At a high-level we will need to consider:

1. Putting the ECF/NPQ registration services in maintenance mode to avoid any changes during the migration.
2. Adding additional validation to the NPQ registration models and fixing data integrity issues.
3. Introducing the new robust/validated models.
4. Fixing data integrity issues in ECF where possible.
5. Document the primary/foreign/unique/index constraints.
6. Update integer primary keys in NPQ registration app to be UUIDs/consistent with ECF/
7. Writing [migration scripts](#migration-scripts) to pull data out of ECF, transform and merge it with the corresponding NPQ registration data; ultimately inserting into the new data model.
    1. We could run this on a nightly schedule and iterate until it can successfully move all the data.
    2. Any data that is not easy to 'fix' in the ECF app may need to be fixed as part of the migration according to rules we can define.
    3. Simiarly, we will need to perform any deduplication/reconcilliation tasks as part of this process.
    4. We may need to relax various database constraints as part of the merging process (and re-introduce them later).

## Model Comparison

We have extracted the attributes of similar models in ECF/NPQ registration to get an idea of how closely they currently align; see [the comparison CSV](data-integrity/ecf_npq_registration_model_comparison.csv). At a high-level we have:


```
NPQApplication / Application
NPQCourse / Course
NPQLeadProvider / LeadProvider
LocalAuthority / LocalAuthority
School / School
User / User
Sessions / Sessions (Rails sessions)
Versions / Versions (Papertrail)
```

## Data Comparison Queries

We ran a series of [queries](data-integrity/data-comparison-queries.rb) to compare ECF and NPQ data.

| Query                                                            | Result   |
| ---------------------------------------------------------------- | -------- |
| Applications in ECF and not in NPQ (by ecf_id)                   |  **1032**    |
| Applications in NPQ and not in ECF (by ecf_id)                   |  **12**      |
| Users in NPQ and not in ECF (by ecf_id)                          |  **5,499**   |
| Users in NPQ with a duplicated email                             |  **27**      |
| Users in NPQ with an invalid email (according to ECF validation) |  **11**      |
| Users in NPQ with a different email in ECF                       |  **1,025**   |
| Users in NPQ matching users in ECF with 0 NPQ applications       |  **14,052**  |

## Migration scripts

We've added a couple of example of migration scripts that we would use to migrate data from ECF to NPQ reg app.

They're just POC queries but need more discussing on the best technical approach to this as it can be done using either SQL or via ActiveRecord migrations.

[POC queries](data-integrity/migration-queries.md)

## Overlapping tables between ECF and NPQ

The robot face emoji denotes tables that are used by the system that don't form part of the operational data model.


| ECF database tables                       | NPQ database tables                   |
| -------                                   | -------------------                   |
| `additional_school_emails`                |                                       |
| `admin_profiles`                          |                                       |
| `api_request_audits` 🤖                   |                                       |
| `api_requests` 🤖                         |                                       |
| `api_tokens`                              |                                       |
| `appropriate_bodies`                      |                                       |
| `appropriate_body_profiles`               |                                       |
| `archive_relics`                          |                                       |
| `call_off_contracts`                      |                                       |
| `cohorts`                                 |                                       |
| `cohorts_lead_providers`                  |                                       |
| `completion_candidates`                   |                                       |
| `core_induction_programmes`               |                                       |
| `cpd_lead_providers`                      |                                       |
| `data_stage_school_changes`               |                                       |
| `data_stage_school_links`                 |                                       |
| `data_stage_schools`                      |                                       |
| `declaration_states`                      |                                       |
| `deleted_duplicates`                      |                                       |
| `delivery_partner_profiles`               |                                       |
| `delivery_partners`                       |                                       |
| `district_sparsities`                     |                                       |
| `ecf_ineligible_participants`             |                                       |
| `ecf_participant_eligibilities`           |                                       |
| `ecf_participant_validation_data`         |                                       |
| `email_associations`                      |                                       |
| `emails` 🤖                               |                                       |
| `event_logs` 🤖                           |                                       |
| `feature_selected_objects` 🤖             |                                       |
| `features` 🤖                             |                                       |
| `finance_adjustments`                     |                                       |
| `finance_profiles`                        |                                       |
| `friendly_id_slugs` 🤖                    |                                       |
| `induction_coordinator_profiles`          |                                       |
| `induction_coordinator_profiles_schools`  |                                       |
| `induction_programmes`                    |                                       |
| `induction_records`                       |                                       |
| `lead_provider_cips`                      |                                       |
| `lead_provider_profiles`                  |                                       |
| `lead_providers`                          |                                       |
| `local_authorities`                       | `local_authorities`                   |
| `local_authority_districts`               |                                       |
| `milestones`                              |                                       |
| `networks`                                |                                       |
| `nomination_emails`                       |                                       |
| `npq_application_eligibility_imports`     |                                       |
| `npq_application_exports`                 |                                       |
| `npq_applications`                        | `applications`                        |
| `npq_contracts`                           |                                       |
| `npq_courses`                             | `courses`                             |
| `npq_lead_providers`                      | `lead_providers`                      |
| `participant_bands`                       |                                       |
| `participant_declaration_attempts`        |                                       |
| `participant_declarations`                |                                       |
| `participant_id_changes`                  | `participant_id_changes`              |
| `participant_identities`                  |                                       |
| `participant_outcome_api_requests`        |                                       |
| `participant_outcomes`                    |                                       |
| `participant_profile_schedules`           |                                       |
| `participant_profile_states`              |                                       |
| `participant_profiles`                    |                                       |
| `partnership_csv_uploads`                 |                                       |
| `partnership_notification_emails`         |                                       |
| `partnerships`                            |                                       |
| `privacy_policies`                        |                                       |
| `privacy_policy_acceptances`              |                                       |
| `profile_validation_decisions`            |                                       |
| `provider_relationships`                  |                                       |
| `pupil_premiums`                          |                                       |
| `schedule_milestones`                     |                                       |
| `schedules`                               | `schedules`                           |
| `school_cohorts`                          |                                       |
| `school_links`                            |                                       |
| `school_local_authorities`                |                                       |
| `school_local_authority_districts`        |                                       |
| `school_mentors`                          |                                       |
| `schools`                                 | `schools`                             |
| `sessions` 🤖                             |                                       |
| `statement_line_items`                    |                                       |
| `statements`                              |                                       |
| `sync_dqt_induction_start_date_errors` 🤖 |                                       |
| `teacher_profiles`                        |                                       |
| `users`                                   | `users`                               |
| `versions` 🤖                             | `versions` 🤖                         |
|                                           | `delayed_jobs` 🤖                     |
|                                           | `ecf_sync_request_logs` 🤖            |
|                                           | `flipper_features` 🤖                 |
|                                           | `flipper_gates` 🤖                    |
|                                           | `get_an_identity_webhook_messages` 🤖 |
|                                           | `itt_providers`                       |
|                                           | `private_childcare_providers`         |
|                                           | `registration_interests`              |
|                                           | `reports` 🤖                          |

#### Other db tables
We believe the data migration should be fine for other DB tables other than the ones with duplicated table names or purpose.
For **financial data** for example, it’ll be new tables to get created in `NPQ reg` app. ie: `npq_contracts` `statements` `statement_line_items` `milestones` `participant_outcomes` `participant_declarations` etc, so no merge data to worry about or duplication, etc.

## Q&A

- ##### What would the key challenges be in migrating data from ECF app to a separated NPQ app be, and how might we mitigate them?
  Users & Applications tables are the main challenges as we have crutial data in it and the table names collapses with existing tables from NPQ-reg app.

  More details in the [proposed data migration plan](#proposed-data-migration-plan).

- ##### Analyse how we can safely merge the current data in ECF tables (NPQ applications and users) into the existing model in NPQ.
  Covered in the [proposed data migration plan](#proposed-data-migration-plan).

- ##### Highlight any discrepancies between the data, what the cause is and how to resolve
  Covered in the [the comparison CSV](data-integrity/ecf_npq_registration_model_comparison.csv).

- ##### The source of truth of data between both
  We believe the source of truth of data would be ECF app as a npq application is created via npq-reg app but it's maintained, enhanced and displayed to lead providers via ECF app apis.

- ##### Devise a plan to safely migrate data from ECF to NPQ
  Covered in the [proposed data migration plan](#proposed-data-migration-plan).

- ##### Consider how we might test the riskiest parts of the plan
  As a suggestion, we could create a separated DB server to follow the data migration plan into, so we keep both apps original DBs intact meanwhile we test/tweak out the migration process. Once eveything is tested and re-tested (re-re-tested) and signed off, we can then go ahead and do it in production enviornments.

- ##### Are there any duplicates in the data, for NPQ applications as well as users across both apps, how do we resolve those?
  The idea is to use ECF-app data as the source of truth of data, so for example in case of the same `User` record with same email address in both apps, we'll merge data and keep the migrated ECF record.

- ##### Ideas for fallback, in case we need to rollback or cancel the migration for some reason
  To be discussed with wider dev team


## Next Steps

1. Deep dive into the purposed data migration plan
2. Understand oddly shaped scenarios:
    1. applications in ECF and not in NPQ and vice-versa
    2. users in NPQ and not in ECF (linked by ecf_id) (maybe deduped users?)
