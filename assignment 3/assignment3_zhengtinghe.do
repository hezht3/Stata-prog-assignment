* ---------------------------------------------------------------------------------- *
* ------------------------------ 340.600 Assignment 3 ------------------------------ *
* ---------------------------------------------------------------------------------- *


// header code
* log file
capture log close
log using assignment3_zhengtinghe.log, replace

* set up
version 16
clear all
macro drop _all
set more off
set linesize 255


// Question 1
clear
use transplants.dta, clear   // load dataset
drop if missing(transplant_date)

gen transplant_year = year(transplant_date)   // pull year of transplant date
bys transplant_year: gen cases = _N   // number of cases per year
twoway line cases transplant_year, ///
	xscale(range(2007 2019)) xlabel(2007 (2) 2019) ///
	yscale(range(0)) ylabel(0 (100) 600) ///
	xtitle("Calendar year") ytitle("Number of cases") ///
	title("Trends in kidney transplantation") ///
	lwidth(thick)
graph export "q1_zhengtinghe.png", replace


// Question 2
clear
use transplants.dta, clear   // load dataset
drop if missing(peak_pra)

twoway scatter peak_pra age if prev_ki == 0, mcolor(blue) msize(small)  ///
	|| scatter peak_pra age if prev_ki == 1, mcolor(red) msize(small) ///
	xlabel(0 (10) 80) ///
	xtitle("Recipient age") ytitle("Peak PRA") ///
	legend(order(2 1) label(1 "First-time transplant") ///
					  label(2 "Re-transplant"))
graph export "q2_zhengtinghe.png", replace


// Question 3
clear
use transplants.dta, clear   // load dataset
drop if missing(peak_pra)

collapse (mean) peak_pra, by(ctr_id)   // collapse peak_pra to average peak_pra per center
sort peak_pra
gen n = _n

quietly sum peak_pra   // get mean of peak_pra
local peak_mean = r(mean)

twoway scatter peak_pra n, ///
	yline(`peak_mean') ///
	xscale(off) yscale(range(0 25)) ylabel(0 (5) 25) ///
	ytitle("Peak PRA") title("Average peak PRA of the recipients at each center") ///
	text(17 7 "National Average")
graph export "q3_zhengtinghe.png", replace


// Question 4
disp "Question 4: I estimate that it took me 1 hour to complete this assignment."

log close
