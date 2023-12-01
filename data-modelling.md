# Data modelling

The intention is to separate the NPQ application from ECF so that NPQ can operate standalone.

In order to do that we need to move NPQ data from the ECF app to the NPQ one. This document
will propose a model for storing that data.

The aim is:

* not to introduce anything unnecessary to NPQ
* to structure the data so it's easy to understand
* the queries that power the API should be simple and fast

## Proposed schema

_This is an initial version and likely to change_.

```mermaid
erDiagram
    Application }|--|| User : ""
    Application }|--|| LeadProvider : ""
    Application }|--|| Course : ""
    Application }o--o| School : ""
    Application }o--o| PrivateChildcareProvider : ""
    Application }|--|| Cohort : ""
    %%Application }|--|| ParticipantIdentity : belongs_to

    %%ParticipantIdentity }|--|| User : belongs_to

    Declaration }|--|| User : ""
    Declaration }|--|| Course : ""
    Declaration }|--|| LeadProvider : ""
    Declaration }|--|| Application : ""

    Statement }|--|| LeadProvider : ""
    Statement }|--|| Cohort : ""

    StatementLineItem }|--|| Statement : ""
    StatementLineItem }|--|| Declaration : ""

    Contract }|--|| LeadProvider : ""
    Contract }|--|| Cohort : ""
    Contract }|--|| Course : ""
    %% Contract linked to Statement with version
    Contract }|--|| Statement : ""

    Schedule }|--|| Cohort : ""
    
    Milestone }|--|| Schedule : ""

    ParticipantOutcome }|--|| Declaration : ""

    User {
        uuid id
        string email
        string full_name
        string teacher_reference_number
        datetime updated_at
    }

    LeadProvider {
        uuid id
        string name
    }

    Course {
        uuid id
        string identifier "Is this unique?"
    }

    Application {
        uuid id
        uuid course_id
        uuid lead_provider_id
        uuid participant_identity_id
        string employer_name
        string employment_role
        string funding_choice
        string headteacher_status
        string ineligible_for_funding_reason
        string private_childcare_provider_urn
        string teacher_reference_number
        boolean teacher_reference_number_verified
        uuid school_id
        string lead_provider_approval_status
        boolean works_in_school
        uuid cohort_id
        boolean eligible_for_funding
        boolean targeted_delivery_funding_eligibility
        string teacher_catchment
        string teacher_catchment_iso_country_code
        string teacher_catchment_country
        string itt_provider
        boolean lead_mentor
    }

    Cohort {
        uuid id
        integer start_year
    }

    ParticipantOutcome {
        uuid id
        string state
        date completion_date
        uuid declaration_id
        datetime created_at
    }

    Declaration {
        uuid id
        uuid course_id
        uuid user_id
    }

    School {
        uuid id
        string urn
        string ukprn
    }
```

### Things we removed

#### Policy-specific prefixes
#### ParticipantProfile
#### ParticipantIdentity

### API sample queries

#### `/api/v3/participants/npq`

* User
  - `id`
  - `email`
  - `full_name`
  - `teacher_reference_number`
  - `updated_at`
* LeadProvider
  - `id`
  - `name`
* Course
  - `id`
  - `identifier`
* Application {
  - `id`
  - `course_id`
  - `lead_provider_id`

```ruby
User.joins(applications: [:lead_providers, :courses])
```
