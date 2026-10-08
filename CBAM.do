clear all
set more off
cd "C:\Users\aksha\Downloads\Akshaya\Professional\CBAM_Research"
import excel "Treated_Trade.xlsx", sheet ("Trade Data") firstrow clear
rename period year
rename reporterISO export_country
rename partnerISO import_country
rename primaryValue trade_value_steel
destring year, replace
save "clean_steel_trade.dta", replace
