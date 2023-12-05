# Data Integrity Summary

## What have we done so far?

- NPQ registration snapshot DB
- NPQ registration data models in ECF
- [Compared underlying tables](data-integrity/ecf_npq_registration_model_comparison.csv)
- Initial investigation into potential data issues
- Draft data migration plan

## Findings

- User/Application tables will be hardest to merge (no surprise there)
- There are ~800 applications that don't exist in both ECF and NPQ registration (by `ecf_id`)
- There are ~5,000 users in NPQ registration that are not in ECF (by `ecf_id`)
  - Silver lining; we got that down to 5 by matching on other user data points
- We may have to deal with other data integrity issues (aside from mismatched data)
  - We know we have data issues in ECF
  - We found potential data issues in NPQ registration; invalid/duplicate emails, for example
- Determining the most relevant version of the data is not straight-forward
  - NPQ registration integrates with Get an Identity

## Migration plan

- Add model validation to NPQ registration and fix up existing data
- Transition NPQ registration models to use UUID primary keys
- Upfront fixing of data integrity issues in ECF where possible
- Introduce the new/robust data models
  - Modelling/integrity streams will begin to overlap here
- ECF (and potentially NPQ registration) will be put into maintenance mode (to prevent changes)
- Run the data migration
  - A Ruby script to pull data from ECF, transform it and push it into the new NPQ registration models
  - We may apply data fixes here if they are too hard to implement in ECF
  - Deduplication/merging of records and determining which 'side' to take
- We plan on running periodic 'migrations' on production-like data as we go along

## What are we doing next?

- Start writing reconciliation logic (starting point of the migration scrpt)
- Think about safety nets/fallback plans/ways to minimise risks
