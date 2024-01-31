### Finance Dashboard and Calculations

| Calculator Name                | Path                            | 
|--------------------------------|---------------------------------|
| service_fee_calculations.rb    | payment_calculator/ecf/contract |
| uplift_payment_calculations.rb | payment_calculator/ecf/contract |
| breakdown_summary.rb           | payment_calculator/contract     |
| output_payment_calculator.rb   | payment_calculator/contract     |
| payment_calculation.rb         | payment_calculator/contract     |
| service_fees.rb                | payment_calculator/contract     |
| service_fees_for_band.rb       | payment_calculator/contract     |
| uplift_calculation.rb          | payment_calculator/contract     |
| output_payment.rb              | payment_calculator/npq          |
| service_fees.rb                | payment_calculator/npq          |

#### Notes

1. Declaration fees are calculated based on the different states of the
   Schedule. If a Leadership course goes through the following states:
   [started, retained-1, retained-2, completed], then the Lead Provider will be
   able to create a maximum of 4 declarations. For each one of them, the Lead
   Provider will be entitled to a 25% of the total value.
2. Only declarations in the following states can be
   voided: [submitted, eligible, payable]. If the statement has been `paid` then
   declaration can't be voided, and the state will be `awaiting clawback`: the
   calculation won't be affected. The money will be deducted in the next
   statement.
3. Once the cutoff date for a statement passes, the statement will be frozen
   after the data has been reviewed, downloaded... by a different team.
   We can't perform any calculation (changes) to a frozen statement.

#### Findings

1. For NPQ, the Main calculations are: Declaration value, Service fee, Target
   Delivery funding and Clawbacks. The rest of the calculations are ECF specific
   and do not need to be ported to NPQ.
2. Service fee, no longer need to be calculated in NPQ, only supported for
   migration purposes. To achieve this we would need to persist the service fee
   and not recalculate it dynamically.
3. Declaration value, and target delivery funding, are simple enough that do not
   present technical uncertainties for the implementation.
4. Clawbacks, are a bit more difficult to implement as they depend on business
   rules that involve several domain objects, but with a good test suite, should
   present no issues in being ported.

#### Suggestions:

1. Do not re-implement service fee calculations in NPQ. Only support them for
   migration purposes. Remove dynamic calculation of service fees.
2. Re-implement from scratch the calculations for: Declaration value, Target
   Delivery Funding and Clawbacks.
3. Create a test suite based on production data to ensure that calculations are
   correct.
4. Introduce validations rules regarding `frozen` statements

