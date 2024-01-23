# Migration data findings

The purpose of this document is to highlight discrepancies of data between ECF & NPQ registration apps.

### How we did

In order to do that, we took a snapshot of both DBs and compared the data. So a table from ECF app was compared with a table from NPQ registration app. ie: `npq_applications` table with `applications` and `users` with `users`.

We tried the take the snapshots at the same time to avoid inconsistencies due new data still not synced, but the numbers can still vary a bit as the snapshot process takes little while to run.

NPQ registration app records the `ecf_id` after a `user` or `application` is synced with ECF, so we used the matching ids to determine whether a record is orphan or not.

We have also added some extra logic to try & match the orphans records and added the results to the `potentitial_matches_ids` column.

So for orphan applications in ECF, where the user and course are the same, we recorded the NPQ registration application ids into the `potentitial_matches_ids` column.
So for orphan applications in NPQ registration, where the user and course are the same, we recorded the ECF application ids into the `potentitial_matches_ids` column.

### Data comparisson results

The the full list of ids & support data can be found in this [spreadsheet](https://educationgovuk-my.sharepoint.com/:x:/g/personal/ross_oliver_education_gov_uk/ETwkat3t-jFMoZgE3zjNWDYBfMsKWpD3sQbcnBaTYoOr4w?e=SJ28NE):

- 251 applications are in ECF and not in NPQ registration
  Numbers by status:
  - pending	| 147
  - rejected	| 95
  - accepted	| 9

  Numbers by cohort:
  - 2023	| 204
  - 2022 	|	47

  Numbers by provider:
  - Ambition |	78
  - BPN |	71
  - UCL |	63
  - NIoT |	22
  - LLSE |	11
  - TDT |	5
  - EDT |	1

  Numbers by course:
  - NPQSL	|	68
  - NPQLPM	|	57
  - NPQEHCO	|	38
  - NPQLL	|	17
  - NPQLT	|	14
  - NPQLBC	|	6
  - NPQEYL	|	2
  - NPQLTD	|	1

- 17 applications are in NPQ registration and not in ECF
  - pending | 1

- 5016 users are in NPQ registration and not in ECF **(user email address in NPQ registration does not match to any user in ECF)**
  - with TRN | 1284
  - without TRN | 3733
  - Only 81 of those users have NPQ applications (refer to `ecf_application_id` on [NPQ_Orphan_Users spreadsheet](https://educationgovuk-my.sharepoint.com/:x:/r/personal/ross_oliver_education_gov_uk/Documents/orphan_applications%201.xlsx?d=wdd6a243cfaed4c31a19804df38cd5836&csf=1&web=1&e=eEL5GF&nav=MTVfezlGNkJCMEE4LTg0OUItNDY2Ny1COUNGLUUxNDMzMDNEQkE5MH0)).

### Actions & Thoughts

We have identified an issue, which after get fixed, we believe will help to clear a good number of orphan applications from the list.

The issue is basically creating duplicate applications in ECF from NPQ and not synced. More details in this [Slack thread](https://ukgovernmentdfe.slack.com/archives/C02NLLCAD0S/p1705499425822399).

Number of orphan applications in NPQ registration (17) might be due we had deleted some duplicated applications in ECF during last year.

Application & User inconsistencies seem to stem from either new data depending on when snapshots were created, or duplicated records issue mentioned above.

User inconsistencies isn't a big deal as those don't have applications.

### Next steps

Fix issue mentioned above and chat to Jake on these data incosistencies.
