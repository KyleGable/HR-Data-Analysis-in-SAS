/* Importing the dataset */
proc import out=Thesis
datafile="/home/u62188896/sasuser.v94/turnover.xlsx"
dbms=xlsx replace; sheet="Attrition";
run;

proc freq data=Thesis;
	table _ALL_;
	run;

/* Cleansing the data */
data CleansedThesis;
    set Thesis;
    if Employee_Age = "30.40033257" then delete;
run;

/* Examining cleansed variable */
proc freq data=CleansedThesis;
	table Employee_Age;
	run;






/* EDA here to assure there’s no multicollinearity BS */
proc corr data=CleansedThesis plots=matrix(histogram) plots(maxpoints=30000);
	var Employee_Age Experience_in_Months Extraversion Agreeableness Conscientiousness;
run;

proc corr data=CleansedThesis plots=matrix(histogram) plots(maxpoints=30000);
	var Extraversion Agreeableness Conscientiousness Neuroticism Openness;
run;

proc corr data=CleansedThesis plots=matrix(histogram) plots(maxpoints=30000);
	var Employee_Age Experience_in_Months Neuroticism Openness;
run;

proc sgplot data=CleansedThesis;
	vbar Attrition_Status/stat=pct;
	yaxis values=(0 to 1 by 0.05) label="Percent";
	title "Percentage of Employee Attrition";
run;

proc sgplot data=CleansedThesis;
	vbox Experience_in_Months/category=Attrition_Status;
	title "Attrition to Experience in Months";
run;

proc means data=CleansedThesis n mean median std min max maxdec=2;
	var Experience_in_Months;
run;

proc sgplot data=CleansedThesis;
	histogram Experience_in_Months/group=Attrition_Status;
run;

proc sgplot data=CleansedThesis;
reg x=Employee_Age y=Experience_in_Months;
title "Scatterplot of Employee Age by Experience in Months";
xaxis label ="Employee Age";
yaxis label ="Experience in Months";
run;




/* Using CART to identify the important variables; Entropy is the best category in both imo */
/* Gini with industry */
proc hpsplit data=CleansedThesis nodes=detail;
	class Attrition_Status Gender Employee_Industry Employee_Profession Source_of_Hire Coach Head_Supervisor_Gender Wage_Color Way_to_Work;
	model Attrition_Status(event="1")=Experience_in_Months Gender Employee_Age Employee_Industry Employee_Profession Source_of_Hire Coach Head_Supervisor_Gender Wage_Color Way_to_Work Extraversion Agreeableness Conscientiousness Neuroticism Openness;
	grow Gini;
	prune cc;
	partition fraction(validate=0.3 seed=12345);
run;

/* Gini without industry; best in Gini imo */
proc hpsplit data=CleansedThesis nodes=detail;
	class Attrition_Status Gender Employee_Profession Source_of_Hire Coach Head_Supervisor_Gender Wage_Color Way_to_Work;
	model Attrition_Status(event="1")=Experience_in_Months Gender Employee_Age Employee_Profession Source_of_Hire Coach Head_Supervisor_Gender Wage_Color Way_to_Work Extraversion Agreeableness Conscientiousness Neuroticism Openness;
	grow Gini;
	prune cc;
	partition fraction(validate=0.3 seed=12345);
run;

/* Entropy with industry; best overall imo */
proc hpsplit data=CleansedThesis nodes=detail;
	class Attrition_Status Gender Employee_Industry Employee_Profession Source_of_Hire Coach Head_Supervisor_Gender Wage_Color Way_to_Work;
	model Attrition_Status(event="1")=Experience_in_Months Gender Employee_Age Employee_Industry Employee_Profession Source_of_Hire Coach Head_Supervisor_Gender Wage_Color Way_to_Work Extraversion Agreeableness Conscientiousness Neuroticism Openness;
	grow Entropy;
	prune cc;
	partition fraction(validate=0.3 seed=12345);
run;

/* Entropy without industry*/
proc hpsplit data=CleansedThesis nodes=detail;
	class Attrition_Status Gender  Employee_Profession Source_of_Hire Coach Head_Supervisor_Gender Wage_Color Way_to_Work;
	model Attrition_Status(event="1")=Experience_in_Months Gender Employee_Age Employee_Profession Source_of_Hire Coach Head_Supervisor_Gender Wage_Color Way_to_Work Extraversion Agreeableness Conscientiousness Neuroticism Openness;
	grow Entropy;
	prune cc;
	partition fraction(validate=0.3 seed=12345);
run;

/* Converting Categorical variables to numbers */
proc freq data=CleansedThesis;
	table _ALL_;
run;

proc freq data=CleansedThesis;
	table Attrition_Status Gender Employee_Industry Employee_Profession Source_of_Hire Coach Head_Supervisor_Gender Wage_Color Way_to_Work;
run;

data CategoricalThesis;
	set CleansedThesis;
	if Gender="f" then EmployeeFemale=1; else EmployeeFemale=0;
	if Gender="m" then EmployeeMale=1; else EmployeeMale=0;

	if Employee_Industry="Agriculture" then Agriculture=1; else Agriculture=0;
	if Employee_Industry="Banking" then Banking=1; else Banking=0;
	if Employee_Industry="Building" then Building=1; else Building=0;
	if Employee_Industry="Consulting" then ConsultingIndustry=1; else ConsultingIndustry=0;
	if Employee_Industry="Etc" then EtcIndustry=1; else EtcIndustry=0;
	if Employee_Industry="HoReCa" then HoReCaIndustry=1; else HoReCaIndustry=0;
	if Employee_Industry="IT" then ITIndustry=1; else ITIndustry=0;
	if Employee_Industry="Manufacturing" then Manufacturing=1; else Manufacturing=0;
	if Employee_Industry="Mining" then Mining=1; else Mining=0;
	if Employee_Industry="Pharma" then Pharma=1; else Pharma=0;
	if Employee_Industry="PowerGeneration" then PowerGeneration=1; else PowerGeneration=0;
	if Employee_Industry="RealEstate" then RealEstate=1; else RealEstate=0;
	if Employee_Industry="Retail" then Retail=1; else Retail=0;
	if Employee_Industry="State" then State=1; else State=0;
	if Employee_Industry="Telecom" then Telecom=1; else Telecom=0;
	if Employee_Industry="Transportation" then Transportation=1; else Transportation=0;
	
	if Employee_Profession="Accounting" then Accounting=1; else Accounting=0;
	if Employee_Profession="BusinessDevelopment" then BusinessDevelopment=1; else BusinessDevelopment=0;
	if Employee_Profession="Commercial" then Commercial=1; else Commercial=0;
	if Employee_Profession="Consulting" then ConsultingProfession=1; else ConsultingProfession=0;
	if Employee_Profession="Engineer" then Engineer=1; else Engineer=0;
	if Employee_Profession="HoReCa" then HoReCaProfession=1; else HoReCaProfession=0;
	if Employee_Profession="Etc" then EtcProfession=1; else EtcProfession=0;
	if Employee_Profession="Finance" then Finance=1; else Finance=0;
	if Employee_Profession="HR" then HR=1; else HR=0;
	if Employee_Profession="IT" then ITProfession=1; else ITProfession=0;
	if Employee_Profession="Law" then Law=1; else Law=0;
	if Employee_Profession="Management" then Management=1; else Management=0;
	if Employee_Profession="Marketing" then Marketing=1; else Marketing=0;
	if Employee_Profession="PR" then PR=1; else PR=0;
	if Employee_Profession="Sales" then Sales=1; else Sales=0;
	if Employee_Profession="Teaching" then Teaching=1; else Teaching=0;
	
	if Source_of_Hire="Advertising" then Advertising=1; else Advertising=0;
	if Source_of_Hire="EmployeeRecommendation" then EmployeeRecommendation=1; else EmployeeRecommendation=0;
	if Source_of_Hire="FriendRecommendation" then FriendRecommendation=1; else FriendRecommendation=0;
	if Source_of_Hire="FriendsWithEmployer" then FriendsWithEmployer=1; else FriendsWithEmployer=0;
	if Source_of_Hire="JobSite" then JobSite=1; else JobSite=0;
	if Source_of_Hire="JobSiteVacantPosition" then JobSiteVacantPosition=1; else JobSiteVacantPosition=0;
	if Source_of_Hire="Recommendation" then Recommendation=1; else Recommendation=0;
	if Source_of_Hire="RecruitingAgency" then RecruitingAgency=1; else RecruitingAgency=0;

	if Coach="no" then NoCoach=1; else NoCoach=0;
	if Coach="yes" then YesCoach=1; else YesCoach=0;
	if Coach="supervisor" then SupervisorCoach=1; else SupervisorCoach=0;
	
	if Head_Supervisor_Gender="f" then SupervisorFemale=1; else SupervisorFemale=0;
	if Head_Supervisor_Gender="m" then SupervisorMale=1; else SupervisorMale=0;
	
	if Wage_Color="grey" then Greywage=1; else Greywage=0;
	if Wage_Color="white" then WhiteWage=1; else WhiteWage=0;
	
	if Way_to_Work="bus" then BusToWork=1; else BusToWork=0;
	if Way_to_Work="car" then CarToWork=1; else CarToWork=0;
	if Way_to_Work="foot" then FootToWork=1; else FootToWork=0;
run;

proc freq data=CategoricalThesis;
	table Experience_in_Months Employee_Age Extraversion Agreeableness Conscientiousness Neuroticism Openness
	Attrition_Status Gender Employee_Industry Employee_Profession Source_of_Hire Coach Head_Supervisor_Gender Wage_Color Way_to_Work
	EmployeeFemale EmployeeMale Agriculture Banking Building ConsultingIndustry EtcIndustry HoReCaIndustry ITIndustry Manufacturing Mining Pharma PowerGeneration RealEstate Retail State Telecom Transportation Accounting BusinessDevelopment Commercial ConsultingProfession Engineer HoReCaProfession EtcProfession Finance HR ITProfession Law Management Marketing PR Sales Teaching Advertising EmployeeRecommendation FriendRecommendation FriendsWithEmployer JobSite JobSiteVacantPosition Recommendation RecruitingAgency NoCoach YesCoach SupervisorCoach SupervisorFemale SupervisorMale Greywage WhiteWage BusToWork CarToWork FootToWork;
run;

/* Dropping Old Tables */
data UpdatedCategoricalThesis;
    set CategoricalThesis;
    drop Gender Employee_Industry Employee_Profession Source_of_Hire Coach Head_Supervisor_Gender Wage_Color Way_to_Work;
run;








/* Using logistic regression with ALL 59 variables */
/* Forward */
proc logistic data=UpdatedCategoricalThesis plots=roc;
	model Attrition_Status(event="1")=Experience_in_Months Employee_Age Extraversion Agreeableness Conscientiousness Neuroticism Openness EmployeeFemale EmployeeMale Agriculture Banking Building ConsultingIndustry EtcIndustry HoReCaIndustry ITIndustry Manufacturing Mining Pharma PowerGeneration RealEstate Retail State Telecom Transportation Accounting BusinessDevelopment Commercial ConsultingProfession Engineer HoReCaProfession EtcProfession Finance HR ITProfession Law Management Marketing PR Sales Teaching Advertising EmployeeRecommendation FriendRecommendation FriendsWithEmployer JobSite JobSiteVacantPosition Recommendation RecruitingAgency NoCoach YesCoach SupervisorCoach SupervisorFemale SupervisorMale Greywage WhiteWage BusToWork CarToWork FootToWork/selection=forward;
	output out=ForwardConfusionAllVariables predprobs=individual;
run;

proc freq data=ForwardConfusionAllVariables;
	table Attrition_Status*_INTO_;
run;

/* Stepwise - gives a warning so Professor said not to use it */
proc logistic data=UpdatedCategoricalThesis plots=roc;
	model Attrition_Status(event="1")=Experience_in_Months Employee_Age Extraversion Agreeableness Conscientiousness Neuroticism Openness EmployeeFemale EmployeeMale Agriculture Banking Building ConsultingIndustry EtcIndustry HoReCaIndustry ITIndustry Manufacturing Mining Pharma PowerGeneration RealEstate Retail State Telecom Transportation Accounting BusinessDevelopment Commercial ConsultingProfession Engineer HoReCaProfession EtcProfession Finance HR ITProfession Law Management Marketing PR Sales Teaching Advertising EmployeeRecommendation FriendRecommendation FriendsWithEmployer JobSite JobSiteVacantPosition Recommendation RecruitingAgency NoCoach YesCoach SupervisorCoach SupervisorFemale SupervisorMale Greywage WhiteWage BusToWork CarToWork FootToWork;
	output out=StepwiseConfusionAllVariables predprobs=individual;
run;

proc freq data=StepwiseConfusionAllVariables;
	table Attrition_Status*_INTO_;
run;

/* Backward - gives a warning so Professor said not to use it */
proc logistic data=UpdatedCategoricalThesis plots=roc;
	model Attrition_Status(event="1")=Experience_in_Months Employee_Age Extraversion Agreeableness Conscientiousness Neuroticism Openness EmployeeFemale EmployeeMale Agriculture Banking Building ConsultingIndustry EtcIndustry HoReCaIndustry ITIndustry Manufacturing Mining Pharma PowerGeneration RealEstate Retail State Telecom Transportation Accounting BusinessDevelopment Commercial ConsultingProfession Engineer HoReCaProfession EtcProfession Finance HR ITProfession Law Management Marketing PR Sales Teaching Advertising EmployeeRecommendation FriendRecommendation FriendsWithEmployer JobSite JobSiteVacantPosition Recommendation RecruitingAgency NoCoach YesCoach SupervisorCoach SupervisorFemale SupervisorMale Greywage WhiteWage BusToWork CarToWork FootToWork/selection=backward;
	output out=BackwardConfusionAllVariables predprobs=individual;
run;

proc freq data=BackwardConfusionAllVariables;
	table Attrition_Status*_INTO_;
run;

/* Using logistic regression with variables deemed important in validation set by best CART with industry */
/* Forward */
proc logistic data=UpdatedCategoricalThesis plots=roc;
	model Attrition_Status(event="1")=Accounting BusinessDevelopment Commercial ConsultingProfession Engineer HoReCaProfession EtcProfession Finance HR ITProfession Law Management Marketing PR Sales Teaching Agriculture Banking Building ConsultingIndustry EtcIndustry HoReCaIndustry ITIndustry Manufacturing Mining Pharma PowerGeneration RealEstate Retail State Telecom Transportation Advertising EmployeeRecommendation FriendRecommendation FriendsWithEmployer JobSite JobSiteVacantPosition Recommendation RecruitingAgency Extraversion BusToWork CarToWork FootToWork Conscientiousness Experience_in_Months Agreeableness/selection=forward;
	output out=ForwardValidationVariables predprobs=individual;
run;

proc freq data=ForwardValidationVariables;
	table Attrition_Status*_INTO_;
run;

/* Stepwise - gives a warning so Professor said not to use it */
proc logistic data=UpdatedCategoricalThesis plots=roc;
	model Attrition_Status(event="1")=Accounting BusinessDevelopment Commercial ConsultingProfession Engineer HoReCaProfession EtcProfession Finance HR ITProfession Law Management Marketing PR Sales Teaching Agriculture Banking Building ConsultingIndustry EtcIndustry HoReCaIndustry ITIndustry Manufacturing Mining Pharma PowerGeneration RealEstate Retail State Telecom Transportation Advertising EmployeeRecommendation FriendRecommendation FriendsWithEmployer JobSite JobSiteVacantPosition Recommendation RecruitingAgency Extraversion BusToWork CarToWork FootToWork Conscientiousness Experience_in_Months Agreeableness;
	output out=StepwiseValidationVariables predprobs=individual;
run;

proc freq data=StepwiseValidationVariables;
	table Attrition_Status*_INTO_;
run;

/* Backward - gives a warning so Professor said not to use it */
proc logistic data=UpdatedCategoricalThesis plots=roc;
	model Attrition_Status(event="1")=Accounting BusinessDevelopment Commercial ConsultingProfession Engineer HoReCaProfession EtcProfession Finance HR ITProfession Law Management Marketing PR Sales Teaching Agriculture Banking Building ConsultingIndustry EtcIndustry HoReCaIndustry ITIndustry Manufacturing Mining Pharma PowerGeneration RealEstate Retail State Telecom Transportation Advertising EmployeeRecommendation FriendRecommendation FriendsWithEmployer JobSite JobSiteVacantPosition Recommendation RecruitingAgency Extraversion BusToWork CarToWork FootToWork Conscientiousness Experience_in_Months Agreeableness/selection=backward;
	output out=BackwardValidationVariables predprobs=individual;
run;

proc freq data=BackwardValidationVariables;
	table Attrition_Status*_INTO_;
run;

/* Using logistic regression with variables deemed important in validation set by best CART without industry */
/* Forward */
proc logistic data=UpdatedCategoricalThesis plots=roc;
	model Attrition_Status(event="1")=SupervisorFemale SupervisorMale Accounting BusinessDevelopment Commercial ConsultingProfession Engineer HoReCaProfession EtcProfession Finance HR ITProfession Law Management Marketing PR Sales Teaching Advertising EmployeeRecommendation FriendRecommendation FriendsWithEmployer JobSite JobSiteVacantPosition Recommendation RecruitingAgency Experience_in_Months Agreeableness/selection=forward;
	output out=ForwardValidationVariables predprobs=individual;
run;

proc freq data=ForwardValidationVariables;
	table Attrition_Status*_INTO_;
run;

/* Stepwise - gives a warning so Professor said not to use it */
proc logistic data=UpdatedCategoricalThesis plots=roc;
	model Attrition_Status(event="1")=SupervisorFemale SupervisorMale Accounting BusinessDevelopment Commercial ConsultingProfession Engineer HoReCaProfession EtcProfession Finance HR ITProfession Law Management Marketing PR Sales Teaching Advertising EmployeeRecommendation FriendRecommendation FriendsWithEmployer JobSite JobSiteVacantPosition Recommendation RecruitingAgency Experience_in_Months Agreeableness;
	output out=StepwiseValidationVariables predprobs=individual;
run;

proc freq data=StepwiseValidationVariables;
	table Attrition_Status*_INTO_;
run;

/* Backward - gives a warning so Professor said not to use it */
proc logistic data=UpdatedCategoricalThesis plots=roc;
	model Attrition_Status(event="1")=SupervisorFemale SupervisorMale Accounting BusinessDevelopment Commercial ConsultingProfession Engineer HoReCaProfession EtcProfession Finance HR ITProfession Law Management Marketing PR Sales Teaching Advertising EmployeeRecommendation FriendRecommendation FriendsWithEmployer JobSite JobSiteVacantPosition Recommendation RecruitingAgency Experience_in_Months Agreeableness/selection=backward;
	output out=BackwardValidationVariables predprobs=individual;
run;

proc freq data=BackwardValidationVariables;
	table Attrition_Status*_INTO_;
run;








/* Discriminant Analysis setup*/
proc surveyselect data=UpdatedCategoricalThesis samprate=0.7 method=srs out=UpdatedCategoricalThesisPart outall seed=12345;
run;

data UpdatedCategoricalThesisTrain UpdatedCategoricalThesisValid;
	set UpdatedCategoricalThesisPart;
	if selected=1 then output UpdatedCategoricalThesisTrain; else output UpdatedCategoricalThesisValid;
run;

/* Discriminant Analysis based on all the variables; 59 variables, 45 dummies */
proc discrim data=UpdatedCategoricalThesisTrain testdata=UpdatedCategoricalThesisValid method=normal out=trainout testout=validout;
	class Attrition_Status;
	var Experience_in_Months Employee_Age Extraversion Agreeableness Conscientiousness Neuroticism Openness EmployeeFemale EmployeeMale Agriculture Banking Building ConsultingIndustry EtcIndustry HoReCaIndustry ITIndustry Manufacturing Mining Pharma PowerGeneration RealEstate Retail State Telecom Transportation Accounting BusinessDevelopment Commercial ConsultingProfession Engineer HoReCaProfession EtcProfession Finance HR ITProfession Law Management Marketing PR Sales Teaching Advertising EmployeeRecommendation FriendRecommendation FriendsWithEmployer JobSite JobSiteVacantPosition Recommendation RecruitingAgency NoCoach YesCoach SupervisorCoach SupervisorFemale SupervisorMale Greywage WhiteWage BusToWork CarToWork FootToWork;
run;

/* Discriminant Analysis based on the best validation CART with industry; 47 variables, 43 dummies; this is the best performer */
proc discrim data=UpdatedCategoricalThesisTrain testdata=UpdatedCategoricalThesisValid method=normal out=trainout testout=validout;
	class Attrition_Status;
	var Accounting BusinessDevelopment Commercial ConsultingProfession Engineer HoReCaProfession EtcProfession Finance HR ITProfession Law Management Marketing PR Sales Teaching Agriculture Banking Building ConsultingIndustry EtcIndustry HoReCaIndustry ITIndustry Manufacturing Mining Pharma PowerGeneration RealEstate Retail State Telecom Transportation Advertising EmployeeRecommendation FriendRecommendation FriendsWithEmployer JobSite JobSiteVacantPosition Recommendation RecruitingAgency Extraversion BusToWork CarToWork FootToWork Conscientiousness Experience_in_Months Agreeableness;
run;

/* Discriminant Analysis based on the best validation CART without industry; 28 variables, 26 dummies; this is the best performer */
proc discrim data=UpdatedCategoricalThesisTrain testdata=UpdatedCategoricalThesisValid method=normal out=trainout testout=validout;
	class Attrition_Status;
	var SupervisorFemale SupervisorMale Accounting BusinessDevelopment Commercial ConsultingProfession Engineer HoReCaProfession EtcProfession Finance HR ITProfession Law Management Marketing PR Sales Teaching Advertising EmployeeRecommendation FriendRecommendation FriendsWithEmployer JobSite JobSiteVacantPosition Recommendation RecruitingAgency Experience_in_Months Agreeableness;
run;







/* Neural networks */
/* Based on all the variables; 59 variables, 45 dummies */
proc hpneural data=UpdatedCategoricalThesis;
	partition fraction(validate=0.3 seed=12345);
	target Attrition_Status/level=NOM;
	input EmployeeFemale EmployeeMale Accounting BusinessDevelopment Commercial ConsultingProfession Engineer HoReCaProfession EtcProfession Finance HR ITProfession Law Management Marketing PR Sales Teaching Agriculture Banking Building ConsultingIndustry EtcIndustry HoReCaIndustry ITIndustry Manufacturing Mining Pharma PowerGeneration RealEstate Retail State Telecom Transportation Advertising EmployeeRecommendation FriendRecommendation FriendsWithEmployer JobSite JobSiteVacantPosition Recommendation RecruitingAgency NoCoach YesCoach SupervisorCoach SupervisorFemale SupervisorMale Greywage WhiteWage BusToWork CarToWork FootToWork/level=NOM;
	input Experience_in_Months Employee_Age Extraversion Agreeableness Conscientiousness Neuroticism Openness/level=INT;
	hidden 59;
	train maxiter=1000
	numtries=10;
run;

/* Neural Network based off best CART validation important variables with industry; 47 variables, 43 dummies */
proc hpneural data=UpdatedCategoricalThesis;
	partition fraction(validate=0.3 seed=12345);
	target Attrition_Status/level=NOM;
	input Accounting BusinessDevelopment Commercial ConsultingProfession Engineer HoReCaProfession EtcProfession Finance HR ITProfession Law Management Marketing PR Sales Teaching Agriculture Banking Building ConsultingIndustry EtcIndustry HoReCaIndustry ITIndustry Manufacturing Mining Pharma PowerGeneration RealEstate Retail State Telecom Transportation Advertising EmployeeRecommendation FriendRecommendation FriendsWithEmployer JobSite JobSiteVacantPosition Recommendation RecruitingAgency BusToWork CarToWork FootToWork/level=NOM;
	input Experience_in_Months Extraversion Agreeableness Conscientiousness/level=INT;
	hidden 47;
	train maxiter=1000
	numtries=10;
run;

/* Best version */
proc hpneural data=UpdatedCategoricalThesis;
	partition fraction(validate=0.3 seed=12345);
	target Attrition_Status/level=NOM;
	input Accounting BusinessDevelopment Commercial ConsultingProfession Engineer HoReCaProfession EtcProfession Finance HR ITProfession Law Management Marketing PR Sales Teaching Agriculture Banking Building ConsultingIndustry EtcIndustry HoReCaIndustry ITIndustry Manufacturing Mining Pharma PowerGeneration RealEstate Retail State Telecom Transportation Advertising EmployeeRecommendation FriendRecommendation FriendsWithEmployer JobSite JobSiteVacantPosition Recommendation RecruitingAgency BusToWork CarToWork FootToWork/level=NOM;
	input Experience_in_Months Extraversion Agreeableness Conscientiousness/level=INT;
	hidden 40;
	train maxiter=1000
	numtries=10;
run;

/* Neural Network based off best CART validation important variables without industry; 28 variables, 26 dummies; best thus far */
proc hpneural data=UpdatedCategoricalThesis;
	partition fraction(validate=0.3 seed=12345);
	target Attrition_Status/level=NOM;
	input SupervisorFemale SupervisorMale Accounting BusinessDevelopment Commercial ConsultingProfession Engineer HoReCaProfession EtcProfession Finance HR ITProfession Law Management Marketing PR Sales Teaching Advertising EmployeeRecommendation FriendRecommendation FriendsWithEmployer JobSite JobSiteVacantPosition Recommendation RecruitingAgency/level=NOM;
	input Experience_in_Months Agreeableness/level=INT;
	hidden 28;
	train maxiter=1000
	numtries=10;
run;

/* Best version */
proc hpneural data=UpdatedCategoricalThesis;
	partition fraction(validate=0.3 seed=12345);
	target Attrition_Status/level=NOM;
	input SupervisorFemale SupervisorMale Accounting BusinessDevelopment Commercial ConsultingProfession Engineer HoReCaProfession EtcProfession Finance HR ITProfession Law Management Marketing PR Sales Teaching Advertising EmployeeRecommendation FriendRecommendation FriendsWithEmployer JobSite JobSiteVacantPosition Recommendation RecruitingAgency/level=NOM;
	input Experience_in_Months Agreeableness/level=INT;
	hidden 20;
	train maxiter=1000
	numtries=10;
run;






/* Random Forest */
/* Based on all the variables; 59 variables, 45 dummies; 22nd tree */
proc hpforest data=UpdatedCategoricalThesis maxtrees=100 vars_to_try=10 seed=12345
trainfraction=0.7 maxdepth=50 leafsize=6 alpha=0.5;
	target Attrition_Status/level=NOM;
	input EmployeeFemale EmployeeMale Accounting BusinessDevelopment Commercial ConsultingProfession Engineer HoReCaProfession EtcProfession Finance HR ITProfession Law Management Marketing PR Sales Teaching Agriculture Banking Building ConsultingIndustry EtcIndustry HoReCaIndustry ITIndustry Manufacturing Mining Pharma PowerGeneration RealEstate Retail State Telecom Transportation Advertising EmployeeRecommendation FriendRecommendation FriendsWithEmployer JobSite JobSiteVacantPosition Recommendation RecruitingAgency NoCoach YesCoach SupervisorCoach SupervisorFemale SupervisorMale Greywage WhiteWage BusToWork CarToWork FootToWork/level=NOM;
	input Experience_in_Months Employee_Age Extraversion Agreeableness Conscientiousness Neuroticism Openness/level=INT;
run;

/* Based off best CART validation important variables; 47 variables, 43 dummies */
proc hpforest data=UpdatedCategoricalThesis maxtrees=100 vars_to_try=10 seed=12345
trainfraction=0.7 maxdepth=50 leafsize=6 alpha=0.5;
	target Attrition_Status/level=NOM;
	input Accounting BusinessDevelopment Commercial ConsultingProfession Engineer HoReCaProfession EtcProfession Finance HR ITProfession Law Management Marketing PR Sales Teaching Agriculture Banking Building ConsultingIndustry EtcIndustry HoReCaIndustry ITIndustry Manufacturing Mining Pharma PowerGeneration RealEstate Retail State Telecom Transportation Advertising EmployeeRecommendation FriendRecommendation FriendsWithEmployer JobSite JobSiteVacantPosition Recommendation RecruitingAgency BusToWork CarToWork FootToWork/level=NOM;
	input Experience_in_Months Extraversion Agreeableness Conscientiousness/level=INT;
run;

/* Based off best CART validation important variables; 28 variables, 26 dummies */
proc hpforest data=UpdatedCategoricalThesis maxtrees=100 vars_to_try=10 seed=12345
trainfraction=0.7 maxdepth=50 leafsize=6 alpha=0.5;
	target Attrition_Status/level=NOM;
	input SupervisorFemale SupervisorMale Accounting BusinessDevelopment Commercial ConsultingProfession Engineer HoReCaProfession EtcProfession Finance HR ITProfession Law Management Marketing PR Sales Teaching Advertising EmployeeRecommendation FriendRecommendation FriendsWithEmployer JobSite JobSiteVacantPosition Recommendation RecruitingAgency/level=NOM;
	input Experience_in_Months Agreeableness/level=INT;
run;