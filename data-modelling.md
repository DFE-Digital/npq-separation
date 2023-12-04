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

    Outcome }|--|| Declaration : ""

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
        uuid user_id
        string employer_name
        string employment_role
        string funding_choice
        string headteacher_status
        string ineligible_for_funding_reason
        string private_childcare_provider_urn
        string teacher_reference_number
        boolean teacher_reference_number_verified
        string school_urn
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

    Outcome {
        uuid id
        string state
        date completion_date
        uuid declaration_id
        datetime created_at
    }

    Declaration {
        uuid id
        uuid course_id
        uuid application_id
        string state
        string declaration_type
        date declaration_date
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
* Application
  - `id`
  - `course_id`
  - `lead_provider_id`

```ruby
User
  .joins(applications: [:lead_providers, :courses])
  .where(applications: { lead_provider: current_lead_provider } )
```

#### `/api/v3/npq-applications`

* Application
  - `course_id`
  - `participant_identity_id`
  - `employer_name`
  - `employment_role`
  - `funding_choice`
  - `headteacher_status`
  - `ineligible_for_funding_reason`
  - `private_childcare_provider_urn`
  - `teacher_reference_number`
  - `teacher_reference_number_verified`
  - `school_urn`
  - `school_ukprn`
  - `lead_provider_approval_status`
  - `works_in_school`
  - `cohort_id`
  - `eligible_for_funding`
  - `targeted_delivery_funding_eligibility`
  - `teacher_catchment`
  - `teacher_catchment_iso_country_code`
  - `teacher_catchment_country`
  - `itt_provider`
  - `lead_mentor`
  - `lead_provider_id`

* Course
  - `id`
  - `identifier`

* User
  - `id`
  - `full_name`

* Cohort
  - `id`
  - `integer start_year`

```ruby
Application
  .joins(:courses, :cohort, :user)
  .where(lead_provider: current_lead_provider)
```

#### `/api/v3/participants/npq/outcomes`

* Outcome
  - `id`
  - `state`
  - `completion_date`
  - `declaration_id`
  - `created_at`

* Declaration
  - `id`
  - `course_id`
  - `user_id`

* Course
  - `id`
  - `identifier`

* User
  - `id`

```ruby
Outcome
  .includes(declaration: { application: :user }, :course)
  .where(declaration: { lead_provider_id: current_lead_provider.id } )
```

#### `/api/v3/participant-declarations`

* Declaration
  - `id`
  - `state`
  - `application_id`
  - `declaration_type`
  - `declaration_date`
  - `course_id`

* Course
  - `id`
  - `identifier`

* Outcome
  - `id`
  - `state`
  - `created_at`
  - `declaration_id`

* Application
  - `id`
  - `user_id`

```ruby
Declaration
  .includes(:application, :outcomes)
  .where( lead_provider_id: current_lead_provider.id )
```

## Questions

### Do we use NPQ-style numeric IDs for primary keys or switch to UUIDs?

### Should we store some data in multiple locations (eg: `application.user_id` == `application.declarations.user_id`), we can also refer to it through the parent association and be better normalised?
