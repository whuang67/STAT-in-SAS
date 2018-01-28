* Logistic Regression;
proc logistic data = develop des;
/* DES or DESCENDING: reverses the sorting order of response variable */
  class res (param = ref ref = 'S');
  model ins = dda ddabal dep depamt cashbk checks res /stb;
  units ddabal = 1000 depamt = 1000;
run;

* SCORE statement -- Making predictions: P_1;
/* Method 1 */
proc logistic data = develop des;
  model ins = dda ddabal dep depamt cashbk checks;
  score data = pmlr.new out = scored;
run;
proc print data = scored (obs=20);
  var P_1 dda ddabal dep depamt cashbk checks;
run;

/* Method 2 */
proc logistic data = develop des outest = betas1;
  model ins = dda ddabal dep depamt cashbk checks;
run;
proc score data = pmlr.new    /* This is a procedure that return the raw response (logit) */
           out = scored;
           score = betas1;
           type = parms;
  var dda ddabal dep depamt cashbk checks;
run;
data scored;
  set scored;
  p = 1/(1+exp(-ins));
run;
proc print data = scored (obs=20);
  var p dda ddabal dep depamt cashbk checks;
run;

/* Oversampling, proportion of the target event is 0.02 not 0.3 */
%let pi1 = 0.02;
proc logistic data = develop des;
  var dda ddabal dep depamt cashbk checks;
  score data = pmlr.new out = scored priorevent = &pi1;
run;


* SURVEYSELECT;
proc sort data=abc;
  by country;
run;
proc surveyselect data=abc samprate=0.6 output=sample outall;
/* samprate = 0.6
   sampsize - 800 */
  strata country;
run;

* Comparing men's salaries with women's salaries;
proc glm data = salary;
  class gender;
  model pay = gender;
run;

proc ttest data = salary;
  class gender;
  var pay;
run;

* Creating dummy variable manually;
data DUMMY1;
  set ORIGINAL;
  Inc_group1 = (Inc_group=1);
  Inc_group2 = (Inc_group=2);
run;
data DUMMY2;
  set ORIGINAL;
  if Inc_group = 1 then Inc_group1 = 1;
  else Inc_group1 = 0;
  if Inc_group = 2 then Inc_group2 = 1;
  else Inc_group2 = 0;
run;
data DUMMY3;
  set ORIGINAL;
  array inc(*) Inc_group1 - Inc_group5;
  do i = 1 to 5;
    inc(i) = (Inc_group = i);
  end;
run;

* Linear Regression with categorical variable(s);
proc glm data = dataset;
  class c1;
  model y = x1 x2 x3 c1 / solution;
run;
