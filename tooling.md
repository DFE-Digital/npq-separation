# Admin interface tooling and support features

The purpose of this document is to investigate current tooling (in finance and admin interfaces) including eligibility imports and application exports, and how we can move over what we need to. From a self-sustainability point of view, everything we store in the database we should view as something that could be editable in the admin, which could be in the future edited via a field or dropdown.

### Finance profile tools/features

| Feature                                                          | URL      | Controller          |
| --------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ | ----------------------------------------------------- |
| Finance Landing page (Manage CPD Contracts)          | /finance/manage-cpd-contracts    | finance/landing_page                             |
| Search CPD contract data (by participant, declaration or application ID)  | /finance/participants | finance/participants                            |
| Show single participant data                                        | /finance/participants/:id | finance/participants |
| Change NPQ participant training status | /finance/participant_profiles/:participant_profile_id/npq/change_training_status/new | finance/npq/change_training_statuses |
| Change NPQ participant lead provider | /finance/participant_profiles/:participant_profile_id/npq/change_training_status/new | finance/npq/change_lead_provider |
| Change NPQ application lead provider approval status | /finance/npq_applications/:npq_application_id/change_lead_provider_approval_status/new | finance/change_lead_provider_approval_statuses |
| Choose trainee payments scheme page (ECF or NPQ) | /finance/payment-breakdowns/choose-programme | finance/payment_breakdowns |
| Choose NPQ provider for statement page  | /finance/payment-breakdowns/choose-provider-npq | finance/payment_breakdowns |
| Select NPQ provider/cohort/statement dropdowns | /finance/payment-breakdowns/choose-npq-statement | finance/payment_breakdowns |
| List schedules | /finance/schedules |  finance/schedules |
| List a schedule milestone | /finance/schedules/:id |  finance/schedules |
| Download NPQ statement assurance report (Download declarations CSV) | /finance/npq/statements/:statement_id/assurance-report.csv | finance/npq/assurance_reports
| Save NPQ statement in PDF | Calls browser's print feature (Control+P) | Javascript + CSS |
| View NPQ statement | /finance/npq/payment-overviews/:lead_provider_id/statements/:id | finance/npq/statements |
| List NPQ statement voided declarations| /finance/npq/payment-overviews/:lead_provider_id/statements/:statement_id/voided | finance/npq/participant_declarations/voided |
| List NPQ statement declarations for a course | /finance/npq/payment-overviews/:lead_provider_id/statements/:statement_id/courses/:id | finance/npq/course_payment_breakdowns (**does not exist**) |
| View all NPQ statements for a lead provider | /finance/npq/payment-overviews/:id | finance/npq/payment_overviews (**does not exist**) |
| View NPQ contract information | /finance/npq/contracts/:id | finance/npq/contracts (**does not exist**) |
| Resend NPQ participant outcome | /finance/npq/participant_outcomes/:participant_outcome_id/resend | finance/npq/participant_outcomes
| Authorise NPQ statement for payment | /finance/statements/:statement_id/payment_authorisations/new | finance/payment_authorisations |

### Actions & Thoughts

Discuss with Jake on what we need to move over.
