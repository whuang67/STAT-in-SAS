/* Data Preparation */
data CreditCard;
  infile 'C:\users\whuang67\downloads\default of credit card clients.csv' dsd missover;
  input ID LIMIT_BAL SEX EDUCATION MARRIAGE AGE PAY_0 PAY_2 PAY_3 PAY_4 PAY_5 PAY_6
        BILL_AMT1 BILL_AMT2 BILL_AMT3 BILL_AMT4 BILL_AMT5 BILL_AMT6 PAY_AMT1 PAY_AMT2
        PAY_AMT3 PAY_AMT4 PAY_AMT5 PAY_AMT6 NEXT_PAYMENT;
  label NEXT_PAYMENT = "default payment next month";
run;

proc format;
  value EDUCATION 1 = "Grad School"
                  2 = "University"
				  3 = "High School"
				  4 = "Other"
              other = "Invalid";
  value EduLevel 1 = "Grad School"
                 2 = "High or Undergrad School"
		     other = "Invalid";
run;

/* Data Cleaning and Transformation */
proc sql;
  create table Transformed_CreditCard as
    select BILL_AMT1/LIMIT_BAL as bill_amt1_pct,
	       BILL_AMT2/LIMIT_BAL as bill_amt2_pct,
		   BILL_AMT3/LIMIT_BAL as bill_amt3_pct,
		   BILL_AMT4/LIMIT_BAL as bill_amt4_pct,
		   BILL_AMT5/LIMIT_BAL as bill_amt5_pct,
		   BILL_AMT6/LIMIT_BAL as bill_amt6_pct,
		   PAY_AMT1/LIMIT_BAL as pay_amt1_pct,
		   PAY_AMT2/LIMIT_BAL as pay_amt2_pct,
		   PAY_AMT3/LIMIT_BAL as pay_amt3_pct,
		   PAY_AMT4/LIMIT_BAL as pay_amt4_pct,
		   PAY_AMT5/LIMIT_BAL as pay_amt5_pct,
		   PAY_AMT6/LIMIT_BAL as pay_amt6_pct,
		   AGE, EDUCATION
    from  (select *
	       from CreditCard
	       where EDUCATION in (1, 2, 3, 4) and
                 MARRIAGE in (1, 2, 3) and
                 PAY_0 in (-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9) and
                 PAY_2 in (-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9) and
		         PAY_3 in (-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9) and
		         PAY_4 in (-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9) and
		         PAY_5 in (-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9) and
		         PAY_6 in (-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9) and
		         not (BILL_AMT1 le 0 or BILL_AMT2 le 0 or
		              BILL_AMT3 le 0 or BILL_AMT4 le 0 or
		              BILL_AMT5 le 0 or BILL_AMT6 le 0) and
	             not (PAY_AMT1 le 0 or PAY_AMT2 le 0 or
		              PAY_AMT3 le 0 or PAY_AMT4 le 0 or
		              PAY_AMT5 le 0 or PAY_AMT6 le 0) and
	 	         BILL_AMT1 le LIMIT_BAL and
		         BILL_AMT2 le LIMIT_BAL and
		         BILL_AMT3 le LIMIT_BAL and
		         BILL_AMT4 le LIMIT_BAL and
		         BILL_AMT5 le LIMIT_BAL and
		         BILL_AMT6 le LIMIT_BAL);
quit;

/* EDUCATION */
proc stepdisc data = Transformed_CreditCard sle = 0.05
                                            sls = 0.05;
  class EDUCATION;
  var AGE pay_amt1_pct pay_amt2_pct pay_amt3_pct pay_amt4_pct pay_amt5_pct pay_amt6_pct
      bill_amt1_pct bill_amt2_pct bill_amt3_pct bill_amt4_pct bill_amt5_pct bill_amt6_pct;
  ods Select Summary;
run;

proc discrim data = Transformed_CreditCard pool=test
                                           crossvalidate
									       method=normal
									       manova;
  class EDUCATION;
  var AGE bill_amt1_pct pay_amt1_pct;
  format EDUCATION EDUCATION.;
  priors proportional;
run;

/* Further Attempt */
proc sql;
  create table New_CreditCard as
    select *, EDUCATION as EduLevel
	from Transformed_CreditCard;
  update New_CreditCard
    set EduLevel = 
	  case
	    when EDUCATION in (2, 3) then 2
		when EDUCATION = 1 then 1
		else 0
	  end;
  delete from New_CreditCard
    where EDUCATION =4;
quit;

proc stepdisc data = New_CreditCard sle = 0.05
                                    sls = 0.05;
  class EduLevel;
  var AGE pay_amt1_pct pay_amt2_pct pay_amt3_pct pay_amt4_pct pay_amt5_pct pay_amt6_pct
      bill_amt1_pct bill_amt2_pct bill_amt3_pct bill_amt4_pct bill_amt5_pct bill_amt6_pct;
  ods Select Summary;
run;

proc discrim data = New_CreditCard pool=test
                                   crossvalidate
								   method=normal
								   manova;
  class EduLevel;
  var bill_amt1_pct AGE bill_amt6_pct bill_amt5_pct pay_amt5_pct;
  format EduLevel EduLevel.;
  priors proportional;
run;
