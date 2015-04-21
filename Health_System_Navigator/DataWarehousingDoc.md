



 * Import data into database through SSIS package
 * [Transform raw data into meta data](#collect-meta-data)
 * Apply staging rules  to aggregate data for each landscape in Veeva app
 * Validate all transforming and calculation are presenting accurately including meta data formatting and aggregation
 * Provide results in the form that facilitate the Veeva app

----------

SSIS Package
------------




----------


Collect meta data
-----------------

##### MSA data (***meta.MSA***)  
All **381** MSAs  are acquired from [Wiki](http://en.wikipedia.org/wiki/List_of_Metropolitan_Statistical_Areas). Each MSA is assigned a unique ***MSA_ID*** to be referred in the meta schema.

MSA_ID  |   Metropolitan_Statistical_Area|
-------- | -------- 
MSA1	| Abilene, TX
MSA2	| Akron, OH
MSA3	| Albany, GA

> A stored procedure should be created to check the MSA information for
> each data feed in case there are new MSAs or invalid MSAs.

##### State data (***meta.State***)  
The state data is directly copied from messaging_main database. Their unique ***state abbreviations*** are referred in the meta schema.

> A stored procedure should be created to check State for each data feed in case invalid MSAs exists.

 - Beneficiary type data (***meta.BentypeMapping***)  
Beneficiary types from Fingertip should be mapped to general bentypes. These mapping is partially refereed from Gilead and built by consulting Marie and Andy. Unique ***bentype_ID*** is assigned to be referred in meta schema.

Plan_Type_Name							|	Bentype			|	Bentype_ID
---												|	---					|	---	
Discount Prescription Programs	|	NULL				|	Bt_1
Medicare PDP								| Medicare			|	Bt_2
Medicare MA								|	Medicare			|	Bt_3
State Medicaid	State 					|	Medicaid			|	Bt_4
Employer										|	Commercial		|	Bt_5
Municipal Plan								|	Commercial		|	Bt_6
> A stored procedure should be created to check new beneficiary types for each data feed.

##### Drug data (***meta.Drug***)  
 Only five drugs are included in this project. The following table is manually created.

Drug_ID	| Drug_Name
-------		| -----
Drg_1		| Gleevec
Drg_2		|Tasigna
Drg_3		|Bosulif
Drg_4		|Sprycel
Drg_5		|Iclusig


##### Formulary data (***meta.CR_DRG_Align_Tier_Rest***)  
Meta formulary information is directly copied from Gilead database. It contains all combinations of formulary information and the corresponding restriction flags (***Core_Display_Restriction***). Unique ***Rst_ID*** is assigned to each combination and referred in the meta schema.

tier_name		|preferred_brand_tier		|	PA	|	ST		|	Core_Tier	|	Core_Category	|	Core_Display_Tier	|		Core_Display_Restriction	|	Tier_Ranking	|	Rest_ID
---				|	---	|	---	|	---	|	---	|	---	|	---	|	---	|	---	|	---	|	---	|	---
Not Covered	|	3			|	Y	|	N	|	NC		|	R	|	Not Covered		|			|	1	|	Rst_14
Not Covered	|	4			|	N	|	N	|	NC		|	R	|	Not Covered		|			|	1	|	Rst_15
Not Covered|	4			|	Y	|	N	|	NC		|	R	|	Not Covered		|			|	1	|	Rst_16
Tier 1			|	NULL	|	N	|	N	|	Tier 2	|	U	|	Tier 2				|			|	9	|	Rst_17
Tier 1			|	NULL	|	N	|	Y	|	Tier 2	|	R	|	Tier 2				|	SE		|	7	|	Rst_18
Tier 1			|	NULL	|	Y	|	N	|	Tier 2	|	R	|	Tier 2				|	PA	|	5	|	Rst_19
 > A stored procedure should be created to check new formulary for each data feed.

##### Live data (***meta.DRG_LivesBreakUp***)  
Live information should be coming in a plan, state/MSA level. This table uses the bentype_ID, state abbreviation, MSA_ID to refer the information saved in meta schema tables.
 > A stored procedure should be created to convert the raw data into proper format.
 
##### Plan formulary data (***meta.DRG_Formulary***)  
Plan formulary is in a plan, drug level. The table uses the bentype_ID, drug_ID and Rest_ID to refer the information save in meta schema tables.
 > A stored procedure should be created to convert the raw data into proper format.

##### Database object descriptions (***meta.Obj_Desc***)  
Each object (table, view, stored procedure) in the database has been assigned a extended property of "***Description***". This view displays this property for all objects and can be potentially used as a data dictionary.

