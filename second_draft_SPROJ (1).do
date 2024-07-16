*Author: Sana Khalid
*Purpose: Data Cleaning and Regressions
*Date started: 15th February 2023

	use "C:\Users\user\Desktop\LFS All Years in Progress.dta"
	
*Dropping values before 2008
	drop if year < 200809
	tab year
	save "C:\Users\user\Desktop\LFS All Years in Progress.dta", replace
	
*Generating CPI variable
	gen CPI = . 
	
*Base Year 2007 = 100, 2008 =120.3 and so on....
*https://data.worldbank.org/indicator/FP.CPI.TOTL.ZG?end=2021&locations=PK&start=2005&view=chart

*100+20.3(2008)
	replace CPI = 120.3 if year == 200809
	
*120.3+13.6(2009)
	replace CPI = 133.9 if year == 200910
	
*133.9+12.9(2010)
	replace CPI = 146.8 if year == 201011
	
*146.8+11.9(2011)+9.7(2012)
	replace CPI = 168.4 if year == 201213
	
*168.4+7.7(2013)
	replace CPI = 176.1 if year == 201314
	
*176.1+7.2(2014)
	replace CPI = 183.3	if year == 201415
	
*183.3+2.5(2015)+3.8(2016)+4.1(2017)
	replace CPI = 193.7 if year == 201718
	
*193.7+5.1(2018)+10.6(2019)+9.7(2020) !!!not run yet!!!
	replace CPI = 214 if year == 202021
	
*Generating real_wages_monthly variable
	gen real_wages_monthly = .
	
	replace real_wages_monthly = (total_wages_monthly/CPI) * 100
	
	summ total_wages_monthly 
	
	summ real_wages_monthly
	
*both variables are exactly 199,006


*creating urban or rural variable

	gen urban_rural = .
	
	decode dist_uniq, gen(dist_uniq1)
	
	replace urban_rural = 1 if strpos(dist_uniq1, "Urban")

	replace urban_rural = 0 if strpos(dist_uniq1, "Rural")
	
	
	
*Including index values

	gen index_abs = .
	
	replace index_abs = 531917887 if Q510_rc_grouped == 1
*(224,263 real changes made)(Agri)

	replace index_abs = 88103561 if Q510_rc_grouped == 2
*(1,240 real changes made)(Mining)
	
	replace index_abs = 1072059420 if Q510_rc_grouped == 3
*(66,053 real changes made)(Manufacturing)
	
	replace index_abs = 74325550 if Q510_rc_grouped == 4
*(5,759 real changes made)(Electricity)
	
	replace index_abs = 0 if Q510_rc_grouped == 5
*(39,044 real changes made)(Construction)
	
	replace index_abs = 843699773 if Q510_rc_grouped == 6
*(84,250 real changes made)(Wholesale)
	
	replace index_abs = 425383 if Q510_rc_grouped == 7
*(35,493 real changes made)(Transport)
	
	replace index_abs = 0 if Q510_rc_grouped == 8
*(9,085 real changes made)(Financial)
	
	replace index_abs = 89215 if Q510_rc_grouped == 9
*(66,573 real changes made)(Community)

	

	gen index_pct = .
	
	replace index_pct = 20.37514944 if Q510_rc_grouped == 1
*(224,263 real changes made)(Agri)
	
	replace index_pct = 3.374812664 if Q510_rc_grouped == 2
*(1,240 real changes made)(Mining)
	
	replace index_pct = 41.06530617 if Q510_rc_grouped == 3
*(66,053 real changes made)(Manufacturing)
	
	replace index_pct = 2.847045052 if Q510_rc_grouped == 4
*(5,759 real changes made)(Electricity)
	
	replace index_pct = 0 if Q510_rc_grouped == 5
*(39,044 real changes made)(Construction)

	
	replace index_pct = 32.31797496 if Q510_rc_grouped == 6
*(84,250 real changes made)(Wholesale)
	
	replace index_pct = 0.016294324 if Q510_rc_grouped == 7
*(35,493 real changes made)(Transport)
	
	replace index_pct = 0 if Q510_rc_grouped == 8
*(9,085 real changes made)(Financial)
	
	replace index_pct = 0.003417386 if Q510_rc_grouped == 9
*(66,573 real changes made)(Community)



*Generating variable to check if industry export facing or not (>20% exports)


	gen export_facing = .
	
	replace export_facing = 1 if index_pct > 20
	
	replace export_facing = 0 if index_pct < 20
	
	replace export_facing = . if index_pct == .
	
	
*Dummy for provinces

	gen punjab_dummy = 0
	replace punjab_dummy = 1 if PROV == 1
	
	gen sind_dummy = 0
	replace sind_dummy = 1 if PROV == 2
	
	gen nwfp_dummy = 0
	replace nwfp_dummy = 1 if PROV == 3
	
	gen boluchistan_dummy = 0
	replace boluchistan_dummy = 1 if PROV == 4
	
	gen ajk_dummy = 0
	replace ajk_dummy = 1 if PROV == 5
	
	gen NA_dummy = 0
	replace NA_dummy = 1 if PROV == 6
	
	gen fata_dummy = 0
	replace fata_dummy = 1 if PROV == 7
	
	
*Dummy for after treatment variable
	
	gen post = 0
	
	replace post = 1 if year > 201415
	
	
	
	
*More treatment variables

	gen postxpunjab = post * punjab_dummy
	
	gen postxexportfacing = post * export_facing
	
	gen punjabxexportfacing =  export_facing * punjab_dummy
	
	gen postxsind = post * sind_dummy
	
	gen sindxexportfacing = sind_dummy * export_facing
	
*DID regressions

*1) postxexport
	asdoc reg Q7042 real_wages_monthly i.year i.postxexport, vce (cluster PROV)
	
*2) postxpunjab
	asdoc reg Q7042 real_wages_monthly i.year i.postxpunjab, vce (cluster PROV)
	
*3) postxsind
	asdoc reg Q7042 real_wages_monthly i.year i.postxsind, vce (cluster PROV)

*4) punjabxexport
	asdoc reg Q7042 real_wages_monthly i.year i.punjabxexport, vce (cluster PROV)
	
*5) sindxexport
	asdoc reg Q7042 real_wages_monthly i.year i.sindxexportfacing, vce (cluster PROV)

	

*UPDATED SECOND DRAFT

	
	label variable Q7042 "Monthly Kind Payment Receieved"

	didregress (Q7042) (postxsind), group(PROV) time(year)
	
	estat trendplots

	didregress (Q7042) (postxexportfacing), group(Q510_rc_grouped) time(year)
	
	estat trendplots

*Checking for effect on Agri by running with and without agri

	didregress (Q7042) (postxexportfacing), group(Q510_rc_grouped) time(year)

	drop if Q510_rc_grouped == 1

	didregress (Q7042) (postxexportfacing), group(Q510_rc_grouped) time(year)
	
	
	
	
	
	
	
	
	