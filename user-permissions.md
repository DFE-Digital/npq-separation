# User Permissions

We will need to move the finance dashboard and part of the admin dashboard functionality from ECF to the NPQ registration service. In order to do this we will need to be able to model different user permissions in the NPQ application.


- [User Permissions](#user-permissions)
  - [Current permissions model in NPQ registration](#current-permissions-model-in-npq-registration)
    - [Issues with the current model](#issues-with-the-current-model)
  - [Current permissions model in ECF](#current-permissions-model-in-ecf)
  - [Options for role/permissions going forward](#options-for-rolepermissions-going-forward)
    - [Adding a role to the AdminUser model](#adding-a-role-to-the-adminuser-model)
    - [Adding a `Role` model](#adding-a-role-model)
    - [Using an authorisation library](#using-an-authorisation-library)
  - [Final thoughts](#final-thoughts)
  - [Next steps](#next-steps)
   
## Current permissions model in NPQ registration

Currently, the NPQ registration app only has a single notion of a `User`; it differentiates admin/super-admin users with a `boolean` attribute on the `User` model for each (`user.admin?` and `user.super_admin?`).

It looks like a super-admin user can only be created via the console, for example `user.update!(super_admin: true)`. There is an admin dashboard that super-admin users can access that allow them to create and remove admin users.

The current permissions matrix is as follows:

| Permission                                          | Admin   | Super Admin |
| --------------------------------------------------- | ------- | ----------- |
| View admins                                         | ❌       | ✅ |
| Create admin                                        | ❌       | ✅ |
| Destroy admin                                       | ❌       | ✅ |
| Flipper access                                      | ❌       | ✅ |
| View user role                                      | ❌       | ✅ |
| Access delayed job UI                               | ❌       | ✅ |
| Grant super admin role                              | ❌       | ✅ |
| Access admin portal                                 | ✅       | ✅ |
| Access admin portal                                 | ✅       | ✅ |
| Trigger ECF/NPQ sync                                | ✅       | ✅ |
| View applications                                   | ✅       | ✅ |
| Update application `lead_provider_approval_status`  | ✅       | ✅ |
| Update application `participant_outcome_state`      | ✅       | ✅ |
| View schools                                        | ✅       | ✅ |
| View users                                          | ✅       | ✅ |
| View GIAS webhook messages                          | ✅       | ✅ |

### Issues with the current model

The current method of managing permissions results in both participants and admin users inhabiting in the same `User` model. This could lead to over-complicated queries in the future, where we end up manually excluding non-participant users from queries. It also muddies the domain model and can be a source of confusion given a `User` could mean one of many things.

Whilst having `boolean` attributes to determine roles is sufficient at the moment, we will begin to complicate the permissions further with the introduction of admin and finance dashboards ported from ECF. This will have at least one more user role (for finance users). The current method is also not very extensible; we can't specify different permission levels for the same user types and this might be an issue in the future.

## Current permissions model in ECF

The ECF application uses `Pundit` to manage and model the majority of permissions currently in the application. An audit of the permissions discovered so far is below:

| Policy                                           | Permission                                          | Super User             | Admin                   | Finance User | Induction Coordinator                 | Delivery Partner | Appropriate Body |
| ------------------------------------------------ | --------------------------------------------------- | ---------------------- | ----------------------- | ------------ | ------------------------------------- | ---------------- | ---------------- |
| NPQApplications::EligibilityImportPolicy         | View eligibility import                             | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| NPQApplications::EligibilityImportPolicy         | List eligibility imports                            | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| NPQApplications::EligibilityImportPolicy         | Create eligibility imports                          | ✅ (not on sandbox)     | ✅ (not on sandbox)     | ❌           | ❌                                     | ❌               | ❌              |
| NPQApplications::ExportPolicy                    | List export policies                                | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| NPQApplications::ExportPolicy                    | Create export policies                              | ✅ (not on sandbox)     | ✅ (not on sandbox)     | ❌           | ❌                                     | ❌               | ❌              |
| ParticipantProfile::NPQPolicy                    | View participant profile                            | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| ParticipantProfile::NPQPolicy                    | Edit participant profile                            | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| ParticipantProfile::NPQPolicy                    | Update participant profile                          | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| AdminProfilePolicy                               | View admin profile                                  | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| AdminProfilePolicy                               | List admin profiles                                 | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| AdminProfilePolicy                               | Destroy admin profile                               | ✅ (not own)            | ✅ (not own)            | ❌           | ❌                                     | ❌               | ❌              |
| AdminProfilePolicy                               | Create admin profile                                | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| AppropriateBodyProfilePolicy                     | List appropriate bodies                             | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| AppropriateBodyProfilePolicy                     | View appropriate body                               | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| AppropriateBodyProfilePolicy                     | Create appropriate bodies                           | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| AppropriateBodyProfilePolicy                     | Update appropriate bodies                           | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| AppropriateBodyProfilePolicy                     | Destroy appropriate body                            | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| DeliveryPartnerPolicy                            | Show delivery partner                               | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| DeliveryPartnerPolicy                            | Create delivery partner                             | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| DeliveryPartnerPolicy                            | Update delivery partner                             | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| DeliveryPartnerPolicy                            | Destroy delivery partner                            | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| DeliveryPartnerProfilePolicy                     | List delivery partner profile                       | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| DeliveryPartnerProfilePolicy                     | Show delivery partner profile                       | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| DeliveryPartnerProfilePolicy                     | Create delivery partner profile                     | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| DeliveryPartnerProfilePolicy                     | Update delivery partner profile                     | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| DeliveryPartnerProfilePolicy                     | Destroy delivery partner profile                    | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| FinanceProfilePolicy                             | List finance profile                                | ✅                      | ✅                      | ✅           | ❌                                     | ❌               | ❌              |
| FinanceProfilePolicy                             | View finance profile                                | ✅                      | ✅                      | ✅           | ❌                                     | ❌               | ❌              |
| FinanceProfilePolicy                             | View ECF contract                                   | ✅                      | ✅                      | ✅           | ❌                                     | ❌               | ❌              |
| FinanceProfilePolicy                             | View ECF statement                                  | ✅                      | ✅                      | ✅           | ❌                                     | ❌               | ❌              |
| FinanceProfilePolicy                             | View NPQ course payment breakdown                   | ✅                      | ✅                      | ✅           | ❌                                     | ❌               | ❌              |
| FinanceProfilePolicy                             | View NPQ statement                                  | ✅                      | ✅                      | ✅           | ❌                                     | ❌               | ❌              |
| FinanceProfilePolicy                             | View NPQ voided participant declaration             | ✅                      | ✅                      | ✅           | ❌                                     | ❌               | ❌              |
| GiasPolicy                                       | List GIAS schools                                   | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| GiasPolicy                                       | List GIAS major school changes                      | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| GiasPolicy                                       | List GIAS school changes                            | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| GiasPolicy                                       | View GIAS school change                             | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| GiasPolicy                                       | View GIAS school                                    | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| GiasPolicy                                       | List GIAS schools to add                            | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| GiasPolicy                                       | List GIAS schools to close                          | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| ImpersonationPolicy                              | Start impersonating                                 | ✅ (not self or admin)  | ✅ (not self or admin)  | ❌           | ❌                                     | ❌               | ❌              |
| ImpersonationPolicy                              | Stop impersonating                                  | ✅ (not self or admin)  | ✅ (not self or admin)  | ❌           | ❌                                     | ❌               | ❌              |
| InductionRecordPolicy                            | View induction record                               | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| InductionRecordPolicy                            | Edit induction record                               | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| InductionRecordPolicy                            | Change induction record appropriate body            | ✅                      | ✅                      | ❌           | ✅ (scoped, current & transferring in) | ❌               | ❌              |
| InductionRecordPolicy                            | Change induction record email                       | ✅                      | ✅                      | ❌           | ✅ (scoped, current & transferring in) | ❌               | ❌              |
| InductionRecordPolicy                            | Change induction record mentor                      | ✅                      | ✅                      | ❌           | ✅ (scoped, current & transferring in) | ❌               | ❌              |
| InductionRecordPolicy                            | Change induction record name                        | ✅                      | ✅                      | ❌           | ✅ (scoped, current)                   | ❌               | ❌              |
| InductionRecordPolicy                            | Change induction record training status             | ✅ (enrolled in sip)    | ✅ (enrolled in sip)    | ❌           | ❌                                     | ❌               | ❌              |
| InductionRecordPolicy                            | ~~Induction record validations~~                    | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| InductionRecordPolicy                            | Change induction record preferred email             | ✅                      | ❌                      | ❌           | ❌                                     | ❌               | ❌              |
| InductionRecordPolicy                            | ~~Withdraw induction record~~                       | ❌                      | ❌                      | ❌           | ❌                                     | ❌               | ❌              |
| InductionRecordPolicy                            | ~~Remove induction record~~                         | ❌                      | ❌                      | ❌           | ❌                                     | ❌               | ❌              |
| LeadProviderPolicy                               | View lead provider                                  | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| LeadProviderPolicy                               | Create lead provider                                | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| LeadProviderPolicy                               | Update lead provider                                | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| LeadProviderProfilePolicy                        | List lead provider profiles                         | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| LeadProviderProfilePolicy                        | View lead provider profiles                         | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| LeadProviderProfilePolicy                        | Destroy lead provider profiles                      | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| LeadProviderProfilePolicy                        | Create lead provider profiles                       | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| LeadProviderProfilePolicy                        | Update lead provider profiles                       | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| NPQApplicationPolicy                             | Create NPQ application                              | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| NPQApplicationPolicy                             | View NPQ application                                | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| NPQApplicationPolicy                             | Edit NPQ application                                | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| NPQApplicationPolicy                             | Update NPQ application                              | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| NPQApplicationPolicy                             | View NPQ application invalid payment analysis       | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| ParticipantProfilePolicy                         | View participant profile                            | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| ParticipantProfilePolicy                         | View participant profile validations                | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| ParticipantProfilePolicy                         | Update participant profile validations              | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| ParticipantProfilePolicy                         | Change participant profile cohort                   | ✅                      | ❌                      | ❌           | ❌                                     | ❌               | ❌              |
| ParticipantProfilePolicy                         | Change participant profile induction status         | ✅                      | ❌                      | ❌           | ❌                                     | ❌               | ❌              |
| ParticipantProfilePolicy                         | ~~Withdraw participant profile~~                    | ❌                      | ❌                      | ❌           | ❌                                     | ❌               | ❌              |
| ParticipantProfilePolicy                         | ~~Remove participant profile~~                      | ❌                      | ❌                      | ❌           | ❌                                     | ❌               | ❌              |
| PartnershipPolicy                                | Update partnership                                  | ✅                      | ✅                      | ❌           | ✅ (scoped)                            | ❌               | ❌              |
| PartnershipPolicy                                | Challenge partnership                               | ✅                      | ❌                      | ❌           | ❌                                     | ❌               | ❌              |
| SchoolCohortPolicy                               | View school cohort                                  | ✅                      | ✅                      | ❌           | ✅ (scoped)                            | ❌               | ❌              |
| SchoolCohortPolicy                               | Update school cohort                                | ✅                      | ✅                      | ❌           | ✅ (scoped)                            | ❌               | ❌              |
| SchoolCohortPolicy                               | ~~Info school cohort~~                              | ✅                      | ✅                      | ❌           | ✅ (scoped)                            | ❌               | ❌              |
| SchoolCohortPolicy                               | ~~Edit school cohort~~                              | ✅                      | ✅                      | ❌           | ✅ (scoped)                            | ❌               | ❌              |
| SchoolCohortPolicy                               | ~~Success school cohort~~                           | ✅                      | ✅                      | ❌           | ✅ (scoped)                            | ❌               | ❌              |
| SchoolCohortPolicy                               | ~~Change appropriate body school cohort~~           | ✅                      | ✅                      | ❌           | ✅ (scoped)                            | ❌               | ❌              |
| SchoolPolicy                                     | List schools                                        | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| SchoolPolicy                                     | View school                                         | ✅ (scoped)             | ✅ (scoped)             | ❌           | ✅ (scoped)                            | ❌               | ❌              |
| SuperUserPolicy                                  | View super user                                     | ✅                      | ❌                      | ❌           | ❌                                     | ❌               | ❌              |
| UserPolicy                                       | View user                                           | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| UserPolicy                                       | Create user                                         | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| UserPolicy                                       | Update user                                         | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ❌              |
| UserPolicy                                       | Destroy user                                        | ✅ (not self)           | ✅ (not self)           | ❌           | ❌                                     | ❌               | ❌              |
| N/A - Finance::BaseController restricts          | Manage adjustments for statements                   | ✅                      | ✅                      | ✅           | ❌                                     | ❌               | ❌              |
| N/A - Finance::BaseController restricts          | View assurance reports                              | ✅                      | ✅                      | ✅           | ❌                                     | ❌               | ❌              |
| N/A - Finance::BaseController restricts          | Change application LP approval status to pending    | ✅                      | ✅                      | ✅           | ❌                                     | ❌               | ❌              |
| N/A - Finance::BaseController restricts          | View the finance landing page                       | ✅                      | ✅                      | ✅           | ❌                                     | ❌               | ❌              |
| N/A - Finance::BaseController restricts          | List/view users                                     | ✅                      | ✅                      | ✅           | ❌                                     | ❌               | ❌              |
| N/A - Finance::BaseController restricts          | Mark statement a paid                               | ✅                      | ✅                      | ✅           | ❌                                     | ❌               | ❌              |
| N/A - Finance::BaseController restricts          | View statements/payment breakdowns                  | ✅                      | ✅                      | ✅           | ❌                                     | ❌               | ❌              |
| N/A - Finance::BaseController restricts          | List/view schedules                                 | ✅                      | ✅                      | ✅           | ❌                                     | ❌               | ❌              |
| N/A - Finance::BaseController restricts          | View voided declarations                            | ✅                      | ✅                      | ✅           | ❌                                     | ❌               | ❌              |
| N/A - Finance::BaseController restricts          | Export assurance reports CSV                        | ✅                      | ✅                      | ✅           | ❌                                     | ❌               | ❌              |
| N/A - Finance::BaseController restricts          | Transfer participant to other lead provider         | ✅                      | ✅                      | ✅           | ❌                                     | ❌               | ❌              |
| N/A - Finance::BaseController restricts          | Change participant training status                  | ✅                      | ✅                      | ✅           | ❌                                     | ❌               | ❌              |
| N/A - Finance::BaseController restricts          | View course payment breakdowns                      | ✅                      | ✅                      | ✅           | ❌                                     | ❌               | ❌              |
| N/A - Finance::BaseController restricts          | Resend participant outcome                          | ✅                      | ✅                      | ✅           | ❌                                     | ❌               | ❌              |
| N/A - Finance::BaseController restricts          | Void participant outcome                            | ✅                      | ✅                      | ✅           | ❌                                     | ❌               | ❌              |
| N/A - Finance::BaseController restricts          | View banding details for a lead provider            | ✅                      | ✅                      | ✅           | ❌                                     | ❌               | ❌              |
| N/A - DeliveryPartner::BaseController restricts  | List/view delivery partners                         | ✅                      | ✅                      | ❌           | ❌                                     | ✅               | ❌              |
| N/A - DeliveryPartner::BaseController restricts  | View/export delivery partner participants           | ✅                      | ✅                      | ❌           | ❌                                     | ✅               | ❌              |
| N/A - AppropriateBody::BaseController restricts  | List/view appropriate bodies                        | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ✅              |
| N/A - AppropriateBody::BaseController restricts  | View/export appropriate body participants           | ✅                      | ✅                      | ❌           | ❌                                     | ❌               | ✅              |

## Options for role/permissions going forward

Ideally we should look to split the `User` up to extract non-participant users from this model; this will likely be beneficial for queries in the future and provide clarity on the purpose of the model. As the other types of users are likely to be a form of admin user, we could simply have `User` and `AdminUser` (or perhaps even clearer would be `Participant` and `AdminUser`).

### Adding a role to the AdminUser model

Assuming we have a separate model for our `AdminUser`, the simplest approach would be to add an `enum` to contain the role type. This would be the simplest to implement but also the least flexible and may end up with complexities further down the line when we try and answer questions such as 'what do finance users have access to?' (as there would likely be no centralised/clear way of specifying this and it would be a case of digging through the code). It would also not let us share roles with other user types in the future, should we find a use case for this.

**Advantages**

- Quickest/simplest to set up

**Disadvantages**

- Permissions will be scattered throughout the codebase/roles will not be clearly defined
- Adding a new role will require a migration
- Users could not have multiple roles

### Adding a `Role` model

An improvement on having the role directly on the user would be to specify a `Role` model and have a service around permission checking, for example:

```
admin_role = Role.new(name: :admin)
user.roles << admin_role

PermissionChecker.can_view_statements?(user)
```

**Advantages**

- Better organisation of permissions (centralising the logic)
- Users can have multiple roles, and roles can have distinct permissions
- Adding a new role doesn't require a migration

**Disadvantages**

- We can't achieve per-resource authorisation logic (easily)
- We're on our way to rolling our own authorisation logic when an off-the-self solution may make more sense

### Using an authorisation library

By using an off-the-self authorisation gem we would get the maximum amount of flexibility in terms of authorisation, but at the cost of added complexity and another dependency. It may only make sense to go this route if we expect to need resource-level authorisation logic.

**Advantages**

- Clean modelling or roles and permissions
- Users can have multiple roles/permissions
- Users can have resource-level permissions (such as granting `user_a` access to `application_b`)
- The heavy lifting is done for us (we don't need to roll our own logic)

**Disadvantages**

- Potentially more work up-front
- May end up needlessly over-complicating things

There are a [number of potential libraries](https://www.ruby-toolbox.com/categories/rails_authorization) that would work well with `devise`, the most common being:

- [Pundit](https://github.com/varvet/pundit)
  - Policy-based authorisation (define policies for resource/models and rules for access)
  - Granular control
  - Explicit authorisation rules defined in policies
  - A more recent evolution on this gem is [ActionPolicy](https://github.com/palkan/action_policy)
  - We use this in ECF at the moment
- [CanCanCan](https://github.com/CanCanCommunity/cancancan)
  - Ability-based authorisation (for different user roles and contexts)
  - Clear way of defining rules that govern access to actions and resources
  - Provides a DSL for clearly defining authorisation rules
  - A simpler take on the same kind of pattern is [AccessGranted](https://github.com/chaps-io/access-granted)
- [Rolify](https://github.com/RolifyCommunity/rolify)
  - Role-based authorisation
  - Provides convenient methods for scoping based on roles
  - Simplest to setup and still quite flexible
  - Not maintained as well as the others

If it was better maintained I would be leaning towards Rolify as a nice balance of simplicity and flexibility - it probably fits our use case the best. That being said, if we feel rolling our own solution doesn't make sense its likely worth going with one of the big two, so Pundit or CanCanCan.

## Final thoughts

- Would we be interested in leveraging an authorisation system for lead providers/managing access in general?
- Do any of these have a bearing on future integration of DfE sign in?

## Next steps

We are going to spend some time considering how users interact with the admin/finance dashboards on ECF in order to determine if we can simplify the dashboards as part of the migration work and pair back the authorisation in order to make it as simple as possible (whilst still leaving flexibility for any more complicated requirements in the future). 
