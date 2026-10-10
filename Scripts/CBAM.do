clear all
set more off
cd "C:\Users\aksha\Downloads\Akshaya\Professional\CBAM_Research"
import excel "./Raw_data/Treated_Trade.xlsx", sheet ("Sheet1") firstrow clear
keep period reporterDesc partnerDesc primaryValue
rename period year
rename reporterDesc export_country
rename partnerDesc import_country
rename primaryValue trade_value_steel
destring year, replace
collapse (sum) trade_value_steel, by(export_country import_country year)
save "./Clean_data/clean_steel_trade.dta",replace

import excel "./Raw_data/Company_Report_Finding.xlsx", sheet ("Sheet1") firstrow clear
rename CompanyName company
rename Country exp_country
rename Mentionedin201819 cbam_mention_before
rename Mentionedin202526 cbam_mention_after
rename KeyMatchKeywordsFoundReal strategic_action
rename TargetTechPartners tech_partner
save "./Clean_data/clean_corporate_matrix.dta",replace

import excel "./Raw_data/Control_Trade.xlsx", sheet("Sheet1") firstrow clear
keep period reporterDesc partnerDesc primaryValue
rename period year
rename reporterDesc export_country
rename partnerDesc import_country
rename primaryValue trade_value_textile
destring year, replace
collapse (sum) trade_value_textile, by(export_country import_country year)
save "./Clean_data/clean_textile_trade.dta", replace

import excel "./Raw_data/Treated_Patent.xlsx", sheet("Sheet1") firstrow clear
rename destination_country export_country
rename green_patent_count patents_green
keep year export_country year patents_green
destring year, replace
expand 3 if export_country == "WO", gen(dup_flag)
bysort year export_country: gen copy_id=_n
replace export_country = "IN" if export_country=="WO" & copy_id == 2
replace export_country = "ID" if export_country=="WO" & copy_id == 3
drop dup_flag copy_id
gen export_name = ""
replace export_name = "China" if export_country == "CN"
replace export_name = "India" if export_country == "IN"
replace export_name = "Indonesia" if export_country == "ID"
replace export_name = "Rep. of Korea" if export_country == "KR"
replace export_name = "Türkiye" if export_country == "TR"
drop if export_name == ""
drop export_country
rename export_name export_country

collapse (sum) patents_green, by(export_country year)
save "./Clean_data/clean_patents_green.dta", replace

import excel "./Raw_data/Control_Patent.xlsx", sheet("Sheet1") firstrow clear
rename destination_country export_country
rename control_textile_patent_count patents_control
keep year export_country year patents_control
destring year, replace
expand 3 if export_country == "WO", gen(dup_flag)
bysort year export_country: gen copy_id=_n
replace export_country = "IN" if export_country=="WO" & copy_id == 2
replace export_country = "ID" if export_country=="WO" & copy_id == 3
drop dup_flag copy_id
gen export_name = ""
replace export_name = "China" if export_country == "CN"
replace export_name = "India" if export_country == "IN"
replace export_name = "Indonesia" if export_country == "ID"
replace export_name = "Rep. of Korea" if export_country == "KR"
replace export_name = "Türkiye" if export_country == "TR"
drop if export_name == ""
drop export_country
rename export_name export_country

collapse (sum) patents_control, by(export_country year)
save "./Clean_data/clean_patents_control.dta", replace

use "./Clean_data/clean_steel_trade.dta",clear
merge 1:1 export_country import_country year using "./Clean_data/clean_textile_trade.dta"
drop _merge
recode trade_value_steel(. = 0)
recode trade_value_textile(. = 0)

merge m:1 export_country year using "./Clean_data/clean_patents_green.dta"
drop if _merge==2
drop _merge

merge m:1 export_country year using "./Clean_data/clean_patents_control.dta"
drop if _merge==2
drop _merge

recode patents_green (. = 0)
recode patents_control (. = 0)

save "./Clean_data/master_merged_wide.dta", replace

list export_country import_country year trade_value_steel patents_green in 1/5

rename patents_green patent_count_steel
rename patents_control patent_count_textile
reshape long trade_value_ patent_count_ , i(export_country import_country year) j(sector) string
rename trade_value_ trade_value
rename patent_count_ patent_count

gen post_2021=(year>=2021)
gen treated_sector=(sector=="steel")
save "./Clean_data/final_regression_panel.dta",replace
list export_country import_country year sector trade_value patent_count post_2021 treated_sector in 1/10

gen did_interaction =treated_sector*post_2021
gen log_trade_value=log(trade_value+1)

ssc install reghdfe, replace
ssc install ppmlhdfe, replace

encode export_country, gen(exp_id)
encode import_country, gen(imp_id)

egen pair_id=group(exp_id imp_id)

ppmlhdfe patent_count did_interaction log_trade_value, absorb(exp_id#year imp_id#year) cluster(pair_id)