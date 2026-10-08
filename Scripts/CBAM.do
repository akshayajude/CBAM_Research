clear all
set more off
cd "C:\Users\aksha\Downloads\Akshaya\Professional\CBAM_Research"
import excel "./Raw_data/Treated_Trade.xlsx", sheet ("Trade Data") firstrow clear
rename period year
rename reporterISO export_country
rename partnerISO import_country
rename primaryValue trade_value_steel
destring year, replace
save "./Clean_data/clean_steel_trade.dta", replace

import excel "./Raw_data/Company_Report_Finding.xlsx", sheet ("Sheet1") firstrow clear
rename CompanyName company
rename Country exp_country
rename Mentionedin201819 cbam_mention_before
rename Mentionedin202526 cbam_mention_after
rename KeyMatchKeywordsFoundReal strategic_action
rename TargetTechPartners tech_partner
save "./Clean_data/clean_corporate_matrix.dta", replace
