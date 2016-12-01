/* The raw data in imports-85.data is from
   http://archive.ics.uci.edu/ml/datasets/Automobile 
   Bache, K. & Lichman, M. (2013). UCI Machine Learning Repository 
   [http://archive.ics.uci.edu/ml]. Irvine, CA: University of California, 
   School of Information and Computer Science.
*/

ods rtf file = "C:\Stat 448\HW3_Wenke Huang.rtf";

title "HW3 STAT 448 Wenke Huang";
data imports;
	* modify the file path to match the location of your data files, 
	  then change the path back before submitting your final code;
	length x7 $ 9;
	infile "C:\\Stat 448\imports-85.data" dlm="," missover;
	input x1-x2 x3 $ x4 $ x5 $ x6 $ x7 $ x8 $ x9 $ x10-x14 x15 $ x16 $ x17 x18 $ x19-x26;
	numdoors = x6;
	bodystyle = x7;
	drivewheels = x8;
	cylinders = x16;
	hp = x22;
	price = x26;
	keep numdoors drivewheels cylinders bodystyle hp price;
data imports;
	set imports;
	where cylinders in("four", "six") and numdoors in("four", "two")
		and bodystyle in ("sedan", "hatchback")
		and drivewheels ne "4wd";
run;

/* Exercise 1 */
title2 "Part 1a";
proc glm data=imports;
  class drivewheels cylinders bodystyle numdoors;
  model price = drivewheels cylinders bodystyle numdoors;
  lsmeans drivewheels cylinders bodystyle numdoors /pdiff = all cl;
  ods select OverallANOVA FitStatistics ModelANOVA LSMeans LSMeanDiffCL;
run;

title2 "Part 1b";
proc glm data=imports;
  class drivewheels cylinders bodystyle;
  model price = drivewheels cylinders bodystyle;
  ods select OverallANOVA FitStatistics ModelANOVA;
run;

title2 "Part 1c";
proc glm data=imports;
  class drivewheels cylinders bodystyle;
  model price = drivewheels cylinders bodystyle;
  lsmeans drivewheels cylinders bodystyle/pdiff = all cl;
  ods select LSMeans LSMeanDiffCL;
run;

/* Exercise 2 */
title2 "Part 2a";
proc glm data = imports;
  class drivewheels cylinders bodystyle;
  model price = drivewheels cylinders bodystyle cylinders*bodystyle drivewheels*cylinders drivewheels*bodystyle;
  ods select OverallANOVA FitStatistics ModelANOVA;
run;

proc glm data = imports;
  class drivewheels cylinders bodystyle;
  model price = drivewheels cylinders bodystyle cylinders*bodystyle drivewheels*cylinders;
  ods select OverallANOVA FitStatistics ModelANOVA;
run;

title2 "Part 2b";
proc glm data = imports;
  class drivewheels cylinders bodystyle;
  model price = drivewheels cylinders bodystyle drivewheels*cylinders cylinders*bodystyle;
  lsmeans drivewheels cylinders bodystyle drivewheels*cylinders cylinders*bodystyle/pdiff = all cl;
  ods select LSMeans Diff LSMeanDiffCL;
run;

/* Exercise 3 */
title2 "Part 3";
proc reg data=imports;
  model price = hp;
  output out=cookd_ex3 cookd = cd;
run;

proc print data = cookd_ex3;
  where cd ge 1;
run;


/* Exercise 4 */
title2 "Part 4";
data logimports;
  set imports;
  logprice = log(price);
run;

proc reg data = logimports;
  model logprice = hp;
  output out = cookd_ex4 cookd = cd;
run;

proc print data = cookd_ex4;
  where cd ge 1;
run;

title;
ods rtf close;
