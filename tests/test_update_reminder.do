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
        if strpos(`"`line'"', `"`text'"') > 0 {
            local found = 1
            continue, break
        }
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
