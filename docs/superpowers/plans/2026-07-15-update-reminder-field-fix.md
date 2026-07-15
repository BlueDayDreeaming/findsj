# `findsj` Update Reminder Field Fix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `findsj_check_update` read the generated `update_date` field so an update reminder appears on every invocation once the database is more than 90 days old.

**Architecture:** Keep the existing reminder program, file lookup order, date parser, threshold, and silent-failure behavior. Add one Stata regression test that runs the real helper program against isolated version-file fixtures, then make the smallest field-name correction in `findsj.ado`.

**Tech Stack:** Stata 14-compatible ado/do code; StataMP batch runner on macOS; Git.

## Global Constraints

- Read only `update_date`; do not support `last_update`.
- Show the reminder on every `findsj` invocation when `days_diff > 90`.
- Do not add daily throttling or persisted reminder state.
- Silently skip the check when the version file is unavailable, unreadable, or lacks `update_date`.
- Do not modify `auto_update.py`, `findsj_version.dta`, or database download behavior.
- Preserve all pre-existing uncommitted changes in `findsj.ado` and deleted log files.

## File Structure

- Create `tests/test_update_reminder.do`: isolated end-to-end regression test for `findsj_check_update` using temporary `.dta` fixtures and captured Stata output.
- Modify `findsj.ado:2386-2419`: replace the nonexistent `last_update` field reference and related local names with `update_date`.

---

### Task 1: Correct the update-date field and protect the reminder behavior

**Files:**
- Create: `tests/test_update_reminder.do`
- Modify: `findsj.ado:2386-2419`
- Test: `tests/test_update_reminder.do`

**Interfaces:**
- Consumes: `findsj_version.dta` containing one string variable named `update_date` in `YYYY-MM-DD` format.
- Produces: unchanged `findsj_check_update` command behavior, with reminder output containing `Database may need updating` when `days_diff > 90`.

- [ ] **Step 1: Write the failing Stata regression test**

Create `tests/test_update_reminder.do` with this content:

```stata
version 14
clear all
set more off

local source_dir `"`c(pwd)'"'
local sandbox `"`c(tmpdir)'findsj_update_reminder_test"'

capture mkdir `"`sandbox'"'
capture mkdir `"`sandbox'/plus"'
capture mkdir `"`sandbox'/personal"'

copy `"`source_dir'/findsj.ado"' `"`sandbox'/findsj.ado"', replace
cd `"`sandbox'"'
sysdir set PLUS `"`sandbox'/plus"'
sysdir set PERSONAL `"`sandbox'/personal"'
adopath + `"`sandbox'"'
run `"`sandbox'/findsj.ado"'

capture program drop assert_log_contains
program define assert_log_contains
    syntax using/, Text(string) [Absent]

    tempname fh
    local found = 0
    file open `fh' using `"`using'"', read text
    file read `fh' line
    while r(eof) == 0 {
        if strpos(`"`line'"', `"`text'"') > 0 local found = 1
        file read `fh' line
    }
    file close `fh'

    if `"`absent'"' == "" assert `found' == 1
    else assert `found' == 0
end

* An update_date older than 90 days must trigger the reminder.
clear
set obs 1
generate str10 update_date = "2000-01-01"
save `"`sandbox'/findsj_version.dta"', replace

capture log close _all
log using `"`sandbox'/outdated.log"', text replace name(outdated)
findsj_check_update
log close outdated
assert_log_contains using `"`sandbox'/outdated.log"', ///
    text("Database may need updating")

* A future update_date must not trigger the reminder.
clear
set obs 1
generate str10 update_date = "2099-01-01"
save `"`sandbox'/findsj_version.dta"', replace

log using `"`sandbox'/fresh.log"', text replace name(fresh)
findsj_check_update
log close fresh
assert_log_contains using `"`sandbox'/fresh.log"', ///
    text("Database may need updating") absent

* A file without update_date must be ignored without an error.
clear
set obs 1
generate str10 generated_on = "2000-01-01"
save `"`sandbox'/findsj_version.dta"', replace

capture noisily findsj_check_update
local missing_field_rc = _rc
assert `missing_field_rc' == 0

display as result "PASS: update reminder regression tests"
exit 0
```

- [ ] **Step 2: Run the regression test and verify the RED state**

Run from the repository root:

```bash
"/Applications/Stata/StataMP.app/Contents/MacOS/stata-mp" -b do tests/test_update_reminder.do
```

Then inspect:

```bash
tail -80 test_update_reminder.log
```

Expected before the fix: Stata exits nonzero and the log reports `assert 0 == 1 is false` with `r(9)` because the old helper looks for `last_update` and produces no reminder for the `update_date` fixture.

- [ ] **Step 3: Implement the minimal field-name correction**

In `findsj_check_update`, replace the current metadata-reading block and related local references with:

```stata
        * Check update_date from version file
        preserve
        quietly use "`version_file_path'", clear

        * Get update_date variable (format: YYYY-MM-DD or similar)
        capture confirm variable update_date
        if _rc {
            restore
            exit
        }

        local update_date_str = update_date[1]
        restore

        * Parse update_date and compare with today
        * Format expected: "2025-12-08" or similar
        if strlen("`update_date_str'") >= 10 {
```

Keep the existing year/month/day parsing and threshold logic, but update the final reminder line to use the same local:

```stata
                noi dis as text "Last updated: " as result "`update_date_str'" as text " (" as result "`days_diff'" as text " days ago)"
```

Do not add a fallback check for `last_update`.

- [ ] **Step 4: Run the regression test and verify the GREEN state**

Run:

```bash
"/Applications/Stata/StataMP.app/Contents/MacOS/stata-mp" -b do tests/test_update_reminder.do
```

Inspect the fresh log:

```bash
tail -80 test_update_reminder.log
```

Expected after the fix: exit code `0`, no Stata error, and `PASS: update reminder regression tests` appears in the log. The outdated fixture's log contains `Database may need updating`; the future fixture's log does not.

- [ ] **Step 5: Verify scope and whitespace**

Run:

```bash
git diff --check
git diff -- findsj.ado
sed -n '1,220p' tests/test_update_reminder.do
git status --short
```

Expected: no whitespace errors; the reminder hunk changes only `last_update` references to `update_date`; the test file is new; the user's earlier `findsj.ado` edits and deleted log files remain present and unchanged.

- [ ] **Step 6: Commit only the regression test and reminder hunk**

Stage the new test directly, then use interactive staging for `findsj.ado` so its unrelated existing changes are excluded:

```bash
git add tests/test_update_reminder.do
git add -p findsj.ado
git diff --cached --check
git diff --cached
git commit -m "fix: read database update date for reminders"
```

During `git add -p findsj.ado`, answer `n` for the pre-existing result-display hunks and `y` only for the `findsj_check_update` field-name hunk. Before committing, confirm the cached diff contains `tests/test_update_reminder.do` and the reminder hunk only.
