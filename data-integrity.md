# Data integrity

## Data Migration

We plan on running a script to migrate the NPQ data from ECF to NPQ registration; this will be a 'big bang' data migration. At a high-level we will need to consider:

* Putting the ECF/NPQ registration services in maintenance mode to avoid any changes during the migration.
* Adding additional validation to the NPQ registration models and fixing data integrity issues.
* Introducing the new robust/validated models.
* Fixing data integrity issues in ECF where possible.
* Document the primary/foreign/unique/index constraints.
* Update integer primary keys in NPQ registration app to be UUIDs/consistent with ECF/
* Writing a migration script to pull data out of ECF, transform and merge it with the corresponding NPQ registration data; ultimately inserting into the new data model.
  * We could run this on a nightly schedule and iterate until it can successfully move all the data.
  * Any data that is not easy to 'fix' in the ECF app may need to be fixed as part of the migration according to rules we can define.
  * Simiarly, we will need to perform any deduplication/reconcilliation tasks as part of this process.
  * We may need to relax various database constraints as part of the merging process (and re-introduce them later).

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

We have ran a series of [queries](data-integrity/data-comparison-queries.rb) to compare the data sets of the NPQ registration and ECF apps:

| Query                                                            | Result   |
| ---------------------------------------------------------------- | -------- |
| Applications in ECF and not in NPQ (by ecf_id)                   |  79      |
| Applications in NPQ and not in ECF (by ecf_id)                   |  703     |
| Users in NPQ and not in ECF (by ecf_id)                          |  5,499   |
| Users in NPQ with a duplicated email                             |  27      |
| Users in NPQ with an invalid email (according to ECF validation) |  11      |
| Users in NPQ with a different email in ECF                       |  1,025   |
| Users in NPQ matching users in ECF with 0 NPQ applications       |  14,052  |
