### Motivation & Acceptance Criteria
<!-- The linked task should describe the motivation behind the change and acceptance criteria -->
Approval Asana Task: [Task](insert_link_to_the_actual_asana_ticket)

<!-- Add any additional notes below -->

<!-- Add Sentry short IDs like STRIVE-XX below to automatically resolve them when this PR is deployed -->
Fixes Sentry issue (if any):

### Change List
<!-- What are the high level changes contained in this PR? -->

<!-- Screenshot(s) from manual testing, if any -->

### How to Test
<!-- Include steps for reviewers and the QA team to test this work -->

### Author Checklist
- [ ] I have tested this work myself
- [ ] I have tested work myself after adjustments based on comments
- [ ] I've considered adding to [the changelog](https://www.notion.so/dbahr7/Changelog-xxxxx)
  (e.g. steps to update the dev environment, new library, some new mechanism, and anything else the team should be aware of)


### Reviewer Checklist
- [ ] A reviewer has tested this work
- [ ] The code does what it is supposed to do as described by the approval task, is written cleanly, and contains notes if it requires additional context
- [ ] There's no security risks of concern (e.g. no hardcoded API keys, no pytest-vcr-cassettes, no PII logged, no XSS risk, ...)

### Reminders
- Don't forget to consider edge-cases and add comments so future maintainers can better understand the code
- If this work requires new dev setup steps, please update Dev setup documentation (todo: set this link)
- If this feature requires manual testing (e.g. regression testing), please added test steps to [Manual Testing](testing guide)