/* The raw data in tae.data is from
   http://archive.ics.uci.edu/ml/datasets/Teaching+Assistant+Evaluation 
   Bache, K. & Lichman, M. (2013). UCI Machine Learning Repository 
   [http://archive.ics.uci.edu/ml]. Irvine, CA: University of California, 
   School of Information and Computer Science.
*/

title "Wenke Huang HW2";

ods rtf file = "C:\Stat 448\Wenke Huang HW2.rtf";
data taevals;
	length nativeEnglish $ 3 semester $ 7 scoregroup $ 6;
	* modify the file path to match the location of your data files, 
	  then change the path back before submitting your final code;
	infile "C:\\Stat 448\tae.data" dlm="," missover;
	input nE instructor course smstr 
		classsize scgrp;
	if nE = 1 then nativeEnglish='yes';
		else nativeEnglish='no';
	if smstr = 1 then semester='Summer';
		else semester='Regular';
	if scgrp=1 then scoregroup='Low';
	if scgrp=2 then scoregroup='Medium';
	if scgrp=3 then scoregroup='High';
	keep nativeEnglish semester scoregroup;
run;
/* The raw data in seeds_dataset.txt is from
   http://archive.ics.uci.edu/ml/datasets/seeds 
   Bache, K. & Lichman, M. (2013). UCI Machine Learning Repository 
   [http://archive.ics.uci.edu/ml]. Irvine, CA: University of California, 
   School of Information and Computer Science.
*/
data seeds;
	* modify the file path to match the location of your data files, 
	  then change the path back before submitting your final code;
	infile 'c:\Stat 448\seeds_dataset.txt' expandtabs;
	input area perimeter compactness length width 
		asymmetry groovelength variety $;
	if variety = '1' then variety = 'Kama';
	if variety = '2' then variety = 'Rosa';
 	if variety = '3' then variety = 'Canadian';
run;


/* Exercise 1 */
/* a */
title2 "Part 1a";
proc freq data=taevals;
  tables semester*scoregroup / nopercent norow nocol expected;
run;

/* b */
title2 "Part 1b";
proc freq data=taevals;
  tables semester*scoregroup / chisq;
  ods select ChiSq;
run;

/* Exercise 2 */
/* a */
title2 "Part 2a";
proc freq data=taevals;
  tables semester*scoregroup / nopercent norow nocol expected;
  where scoregroup ne "Medium";
run;

/* b */
title2 "Part 2b";
proc freq data=taevals;
  tables semester*scoregroup / chisq;
  where scoregroup ne "Medium";
  ods select ChiSq FishersExact;
run;

/* c */
title2 "Part 2c";
proc freq data=taevals;
  tables semester*scoregroup / riskdiff;
  where scoregroup ne "Medium";
  ods select RiskDiffCol1 RiskDiffCol2;
run;

/* Exercise 3 */
/* a */
title2 "Part 3a";
proc freq data=taevals;
  tables nativeEnglish*scoregroup/ nopercent norow nocol expected;
  where semester eq "Summer";
run;

/* b */
title2 "Part 3b";
proc freq data=taevals;
  tables nativeEnglish*scoregroup/ chisq fisher;
  where semester eq "Summer";
  ods select ChiSq FishersExact;
run;

/* Exercise 4 */
/* a & b */
title2 "Part 4a & 4b";
proc anova data=seeds;
  class variety;
  model compactness = variety;
  means variety / hovtest welch;
run;

/* c */
title2 "Part 4c";
proc anova data=seeds;
  class variety;
  model compactness = variety ;
  means variety / welch tukey lines cldiff;
  ods select CLDiffs CLDiffsInfo MCLines;
run;

title;
ods rtf close;
