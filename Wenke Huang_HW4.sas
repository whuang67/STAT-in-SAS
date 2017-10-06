

ods rtf file = "C:\Stat 448\Wenke Huang HW4.rtf";

/* The source csv file was obtained from the UCI Machine Learning Repository
Lichman, M. (2013). UCI Machine Learning Repository [http://archive.ics.uci.edu/ml]. 
Irvine, CA: University of California, School of Information and Computer Science. 

The data, variables and original source are described on the following URL
http://archive.ics.uci.edu/ml/datasets/ILPD+%28Indian+Liver+Patient+Dataset%29
*/
proc import datafile="C:\Stat 448\Indian Liver Patient Dataset (ILPD).csv"
	out= liver
	dbms = csv
	replace;
	getnames=no;
run;
/* after importing, rename the variables to match the data description */
data liver;
	set liver;
	Age=VAR1; Gender=VAR2; TB=VAR3;	DB=VAR4; Alkphos=VAR5;
	Alamine=VAR6; Aspartate=VAR7; TP=VAR8; ALB=VAR9; AGRatio=VAR10;
	if VAR11=1 then LiverPatient='Yes';
		Else LiverPatient='No';
	drop VAR1--VAR11;
run;
* now only keep the adult observations;
data liver;
	set liver;
	where age>17;
run;

/* Exercise 1 */
proc logistic data=liver;
  class LiverPatient Gender;
  model LiverPatient = Age Gender TB DB Alkphos Alamine Aspartate TP ALB AGRatio/ selection=backward;
  where Gender = "Female";
  ods Select ModelBuildingSummary;
run;

proc logistic data=liver noprint;
  class LiverPatient Gender;
  model LiverPatient = Aspartate /influence iplots;
  where Gender = "Female";
  output out=liverFemale_1st cbar=cb_1st;
run;

proc logistic data=liverFemale_1st noprint;
  class LiverPatient Gender;
  model LiverPatient = Aspartate /influence iplots;
  where Gender = "Female" and
        cb_1st lt 0.2;
  output out=liverFemale_2nd cbar=cb_2nd;
run;

proc logistic data=liverFemale_2nd noprint;
  class LiverPatient Gender;
  model LiverPatient = Aspartate /influence iplots;
  where Gender = "Female" and
        cb_1st lt 0.2 and
        cb_2nd lt 0.15;
  output out=liverFemale_3rd cbar=cb_3rd;
run;

proc logistic data=liverFemale_3rd noprint;
  class LiverPatient Gender;
  model LiverPatient = Aspartate /influence iplots;
  where Gender = "Female" and
        cb_1st lt 0.2 and
        cb_2nd lt 0.15 and
        cb_3rd lt 0.1;
run;

/* Re-selection the predictors */
proc logistic data=liverFemale_3rd;
  class LiverPatient Gender;
  model LiverPatient = Age Gender TB DB Alkphos Alamine Aspartate TP ALB AGRatio/ selection=backward;
  where Gender = "Female" and
        cb_1st lt 0.2 and
        cb_2nd lt 0.15 and
        cb_3rd lt 0.1;
  ods Select ModelBuildingSummary;
run;

/* Final model of Part 1(a) and Part 1(b)*/
proc logistic data=liverFemale_3rd;
  class LiverPatient Gender;
  model LiverPatient = Aspartate / influence lackfit;
  where Gender = "Female" and
        cb_1st lt 0.2 and
        cb_2nd lt 0.15 and
        cb_3rd lt 0.1;
  output out=liverFemale_4th cbar=cb_4th;
  ods select OddsRatios ParameterEstimates GlobalTests 
             FitStatistics LackFitChiSq LackFitPartition;
run;



/* Exercise 2 */
proc logistic data=liver;
  class LiverPatient Gender;
  model LiverPatient = Age Gender TB DB Alkphos Alamine Aspartate TP ALB AGRatio/ selection=backward;
  where Gender = "Male";
  ods Select ModelBuildingSummary;
run;

proc logistic data=liver noprint;
  class LiverPatient Gender;
  model LiverPatient = Age Gender DB Alamine TP ALB /influence iplots;
  where Gender = "Male";
  output out=liverMale_1st cbar=cb_1st;
run;

proc logistic data=liverMale_1st noprint;
  class LiverPatient Gender;
  model LiverPatient = Age Gender DB Alamine TP ALB /influence iplots;
  where Gender = "Male" and
        cb_1st lt 0.6;
  output out=liverMale_2nd cbar=cb_2nd;
run;

proc logistic data=liverMale_2nd noprint;
  class LiverPatient Gender;
  model LiverPatient = Age Gender DB Alamine TP ALB /influence iplots;
  where Gender = "Male" and
        cb_1st lt 0.6 and
        cb_2nd lt 0.39;
  output out=liverMale_3rd cbar=cb_3rd;
run;

proc logistic data=liverMale_3rd noprint;
  class LiverPatient Gender;
  model LiverPatient = Age Gender DB Alamine TP ALB /influence iplots;
  where Gender = "Male" and
        cb_1st lt 0.6 and
        cb_2nd lt 0.39 and
        cb_3rd lt 0.3;
  output out=liverMale_4th cbar=cb_4th;
run;

/* Re-selection the predictors */
proc logistic data=liverMale_3rd;
  class LiverPatient Gender;
  model LiverPatient = Age Gender TB DB Alkphos Alamine Aspartate TP ALB AGRatio / selection=backward;
  where Gender = "Male" and
        cb_1st lt 0.6 and
        cb_2nd lt 0.39 and
        cb_3rd lt 0.3;
  ods Select ModelBuildingSummary;
run;

/* Final model of Part 2(a) */
proc logistic data=liverMale_3rd;
  class LiverPatient Gender;
  model LiverPatient = Age Gender DB Alkphos Alamine /influence;
  where Gender = "Male" and
        cb_1st lt 0.6 and
        cb_2nd lt 0.39 and
        cb_3rd lt 0.3;
  output out=liverMale_4th cbar=cb_4th;
  ods select OddsRatios ParameterEstimates GlobalTests 
             FitStatistics;
run;

proc logistic data=liverMale_4th noprint;
  class LiverPatient Gender;
  model LiverPatient = Age Gender DB Alkphos Alamine /influence iplots;
  where Gender = "Male" and
        cb_1st lt 0.6 and
        cb_2nd lt 0.39 and
        cb_3rd lt 0.3 and
        cb_4th lt 0.3;
  output out=liverMale_5th cbar=cb_5th;
run;

/* Final model of Part 2(b) */
proc logistic data=liverMale_5th;
  class LiverPatient Gender;
  model LiverPatient = Age Gender DB Alkphos Alamine /influence lackfit;
  where Gender = "Male" and
        cb_1st lt 0.6 and
        cb_2nd lt 0.39 and
        cb_3rd lt 0.3 and
        cb_4th lt 0.3 and
        cb_5th lt 0.3;
  ods select OddsRatios ParameterEstimates GlobalTests 
             FitStatistics LackFitChiSq LackFitPartition;
run;

/* The source .data file was obtained from the UCI Machine Learning Repository
Lichman, M. (2013). UCI Machine Learning Repository [http://archive.ics.uci.edu/ml]. 
Irvine, CA: University of California, School of Information and Computer Science. 

The data, variables and original source are described on the following URL
http://archive.ics.uci.edu/ml/datasets/Liver+Disorders
*/
data bupa;
	infile "C:\Stat 448\bupa.data" dlm="," missover;
	input mcv alkphos sgpt sgot gammagt drinks selector;
	four_oz = drinks*2;
	keep mcv alkphos sgot gammagt four_oz;
run;







/* Exercise 3 */
proc genmod data=bupa;
  model four_oz = mcv gammagt sgot alkphos/ dist=gamma
                                            link=log
									        type1
									        type3;
  ods select Type1 ModelANOVA;
      /* Former name of ModelANOVA is Type3. */
run;

proc genmod data=bupa plots=(stdreschi stdresdev);
  model four_oz = mcv gammagt sgot/ dist=gamma
                                    link=log
									type1
									type3;
  output out=gammares pred=predOZ stdreschi=presids stdresdev=dresids;
  *ods select ModelInfo Modelfit ParameterEstimates Type1 ModelANOVA DiagnosticPlot;
run;

proc sgscatter data=gammares;
  compare y=(presids dresids) x=predOZ;
run;

proc sgscatter data=gammares;
  compare y=(presids dresids) x=predOZ;
  where predOZ lt 40;
run;


/* Exercise 4 */
proc genmod data=bupa;
  model four_oz = mcv gammagt sgot alkphos/ dist=poisson
                                            type1
									        type3
                                            link=log;
  ods select Modelfit;
run;

proc genmod data=bupa;
  model four_oz = mcv gammagt sgot alkphos/ dist=poisson
                                            link=log
									        type1
									        type3
                                            scale=deviance;
  ods select Modelfit Type1 ModelANOVA;
run;

proc genmod data=bupa;
  model four_oz = mcv gammagt sgot/ dist=poisson
                                    link=log
									type1
									type3
                                    scale=deviance;
  ods select Type1 ModelANOVA;
run;

proc genmod data=bupa  plots=(stdreschi stdresdev);
  model four_oz = mcv gammagt/ dist=poisson
                               link=log
							   type1
						       type3
                               scale=deviance;
  output out=poissonres pred=predOZ stdreschi=presids stdresdev=dresids;
  ods select Modelfit ParameterEstimates Type1 ModelANOVA DiagnosticPlot;
run;

proc sgscatter data=poissonres;
  compare y=(presids dresids) x=predOZ;
run;

ods rtf close;
