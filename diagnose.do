* Diagnostic script for findsj installation issues
* Run this in Stata to check your findsj installation

clear all
set more off

dis as text "{hline 70}"
dis as result "  findsj Installation Diagnostic"
dis as text "{hline 70}"
dis ""

* 1. Check all findsj.ado locations
dis as text "1. Checking all findsj.ado installations:"
dis ""
which findsj, all

dis ""
dis as text "{hline 70}"

* 2. Check adopath
dis as text "2. Stata search path (adopath):"
dis ""
adopath

dis ""
dis as text "{hline 70}"

* 3. Check for findsj.dta
dis as text "3. Searching for findsj.dta in ado paths:"
dis ""

local found_dta = 0
local paths "`c(sysdir_plus)'f `c(sysdir_plus)' `c(sysdir_personal)' `c(pwd)'"

foreach p of local paths {
    capture confirm file "`p'/findsj.dta"
    if _rc == 0 {
        dis as result "  [FOUND] " as text "`p'/findsj.dta"
        local found_dta = 1
    }
    else {
        capture confirm file "`p'findsj.dta"
        if _rc == 0 {
            dis as result "  [FOUND] " as text "`p'findsj.dta"
            local found_dta = 1
        }
    }
}

if `found_dta' == 0 {
    dis as error "  [NOT FOUND] findsj.dta not found in any ado path"
    dis ""
    dis as text "  To download the database, run:"
    dis as text "    {stata findsj, updatesource source(both):findsj, updatesource source(both)}"
}

dis ""
dis as text "{hline 70}"

* 4. Test offline mode
dis as text "4. Testing offline mode (if database found):"
dis ""

if `found_dta' == 1 {
    program drop _all
    capture findsj machine learning, offline n(2)
    if _rc == 0 {
        dis ""
        dis as result "  [SUCCESS] Offline mode working correctly!"
    }
    else {
        dis ""
        dis as error "  [ERROR] Offline mode failed with error code: " _rc
        dis as text "  Please report this issue."
    }
}
else {
    dis as text "  [SKIP] Database not found, cannot test offline mode"
}

dis ""
dis as text "{hline 70}"
dis as result "  Diagnostic Complete"
dis as text "{hline 70}"
dis ""
dis as text "If you see errors, please:"
dis as text "  1. Delete old versions in PERSONAL directory"
dis as text "  2. Run: net install findsj, from(https://raw.githubusercontent.com/BlueDayDreeaming/findsj/main/) replace"
dis as text "  3. Run: findsj, updatesource source(both)"
dis ""
