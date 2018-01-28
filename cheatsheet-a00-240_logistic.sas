* Logistic Regression;
proc logistic data = develop des;
/* DES or DESCENDING: reverses the sorting order of response variable */
  class res (param = ref ref = 'S');
  model ins = dda ddabal dep depamt cashbk checks res /stb;
  units ddabal = 1000 depamt = 1000;
run;

* SCORE statement;
proc logistic data = develop des;
  model ins = dda ddabal dep depamt cashbk checks;
  score data = pmlr.new out = scored;
run;
proc print data = scored (obs=20);
  var P_1 dda ddabal dep depamt cashbk checks;
run;
