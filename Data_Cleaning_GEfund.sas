*option mprint;
libname edgar "C:/users/whuang67/downloads";


%macro State_Abbreviation (Name=);
    if propcase(&Name) = 'Alabama' then &Name = "AL";
	else if propcase(&Name) = 'Alaska' then &Name = "AK";
	else if propcase(&Name) = 'Arizona' then &Name = "AZ";
	else if propcase(&Name) = 'Arkansas' then &Name = "AR";
    else if propcase(&Name) = 'California' then &Name = "CA";
	else if propcase(&Name) = 'Colorado' then &Name = "CO";
	else if propcase(&Name) = 'Connecticut' then &Name = "CT";
	else if propcase(&Name) = 'Delaware' then &Name = "DE";
	else if upcase(&Name) in ('DISTRICT OF COLUMBIA',
                              'WASHINGTON, DISTRICT OF COLUMBIA',
                              'WASHINGTON, DC',
                              'WASHINGTON, D.C.',
                              'D.C.') then &Name = "DC";
	else if propcase(&Name) = 'Florida' then &Name = "FL";
	else if propcase(&Name) = 'Georgia' then &Name = "GA";
	else if propcase(&Name) = 'Hawaii' then &Name = "HI";
	else if propcase(&Name) = 'Idaho' then &Name = "ID";
	else if propcase(&Name) = 'Illinois' then &Name = "IL";
	else if propcase(&Name) = 'Indiana' then &Name = "IN";
	else if propcase(&Name) = 'Iowa' then &Name = "IA";
	else if propcase(&Name) = 'Kansas' then &Name = "KS";
	else if propcase(&Name) = 'Kentucky' then &Name = "KY";
	else if propcase(&Name) = 'Louisiana' then &Name = "LA";
	else if propcase(&Name) = 'Maine' then &Name = "ME";
	else if propcase(&Name) = 'Maryland' then &Name = "MD";
	else if propcase(&Name) = 'Massachusetts' then &Name = "MA";
	else if propcase(&Name) = 'Michigan' then &Name = "MI";
	else if propcase(&Name) = 'Minnesota' then &Name = "MN";
	else if propcase(&Name) = 'Mississippi' then &Name = "MS";
	else if propcase(&Name) = 'Missouri' then &Name = "MO";
	else if propcase(&Name) = 'Montana' then &Name = "MT";
	else if propcase(&Name) = 'Nebraska' then &Name = "NE";
	else if propcase(&Name) = 'Nevada' then &Name = "NV";
	else if propcase(&Name) = 'New Hampshire' then &Name = "NH";
	else if propcase(&Name) = 'New Jersey' then &Name = "NJ";
	else if propcase(&Name) = 'New Mexico' then &Name = "NM";
	else if propcase(&Name) = 'New York' then &Name = "NY";
	else if propcase(&Name) = 'North Carolina' then &Name = "NC";
	else if propcase(&Name) = 'North Dakota' then &Name = "ND";
	else if propcase(&Name) = 'Ohio' then &Name = "OH";
	else if propcase(&Name) = 'Oklahoma' then &Name = "OK";
	else if propcase(&Name) = 'Oregon' then &Name = "OR";
	else if propcase(&Name) = 'Pennsylvania' then &Name = "PA";
	else if propcase(&Name) = 'Rhode Island' then &Name = "RI";
	else if propcase(&Name) = 'South Carolina' then &Name = "SC";
	else if propcase(&Name) = 'South Dakota' then &Name = "SD";
	else if propcase(&Name) = 'Tennessee' then &Name = "TN";
	else if propcase(&Name) = 'Texas' then &Name = "TX";
	else if propcase(&Name) = 'Utah' then &Name = "UT";
	else if propcase(&Name) = 'Vermont' then &Name = "VT";
	else if propcase(&Name) = 'Virginia' then &Name = "VA";
	else if propcase(&Name) = 'Washington' then &Name = "WA";
	else if propcase(&Name) = 'West Virginia' then &Name = "WV";
	else if propcase(&Name) = 'Wisconsin' then &Name = "WI";
	else if propcase(&Name) = 'Wyoming' then &Name = "WY";
	else if propcase(&Name) = 'Americaa Samoa' then &Name = "AS";
	else if propcase(&Name) = 'Guam' then &Name = "GU";
	else if propcase(&Name) = 'Northern Mariana Islands' then &Name = "MP";
	else if propcase(&Name) = 'Puerto Rico' then &Name = "PR";
	else if upcase(&Name) in ('U.S. VIRGIN ISLANDS',
                              'USVI', 'U.S.V.I.',
                              'AMERICAN VIRGIN ISLANDS',
                              'VIRGIN ISLAND OF THE UNITED STATES') then &Name = "VI";
%mend State_Abbreviation;



%macro Date_Cleaning (Date=, Day=, Month=, Year=);
  if upcase(&Month) in ("JANUARY", "JAN.", "JAN") then &Month = "01";
  else if upcase(&Month) in ("FEBRUARY", "FEB.", "FEB") then &Month = "02";
  else if upcase(&Month) in ("MARCH", "MAR.", "MAR") then &Month = "03";
  else if upcase(&Month) in ("APRIL", "APR.", "APR") then &Month = "04";
  else if upcase(&Month) = "MAY" then &Month = "05";
  else if upcase(&Month) in ("JUNE", "JUN.", "JUN") then &Month = "06";
  else if upcase(&Month) in ("JULY", "JUL.", "JUL") then &Month = "07";
  else if upcase(&Month) in ("AUGUST", "AUG.", "AUG") then &Month = "08";
  else if upcase(&Month) in ("SEPTEMBER", "SEP.", "SEPT", "SEP") then &Month = "09";
  else if upcase(&Month) in ("OCTOBER", "OCT.", "OCT") then &Month = "10";
  else if upcase(&Month) in ("NOVEMBER", "NOV.", "NOV") then &Month = "11";
  else if upcase(&Month) in ("DECEMBER", "DEC.", "DEC") then &Month = "12";
  &Date = input(compress(&Year || &Month || &Day), yymmdd8.);
  format &Date mmddyy10.;
%mend Date_Cleaning;


proc sql;
  create table edgar.GE
    (Fund_name char(256),
     COMPANY_CONFORMED_Name char(200),
	 CONFORMED_PERIOD_OF_REPORT num format=mmddyy10.,
	 Street char(513),
     City char(256),
     State char(256),
	 Zip char(256),
     Company_Name char(256),
     Ticker char(256),
     Security_ID char(256),
     Meeting_Type char(256),
     Meeting_date num format=mmddyy10.,
	 Record_date num format = mmddyy10.,
     Item_number char(256),
	 Proposal char(256),
     Mgt_Rec char(256),
     Vote_Cast char(256),
     Sponsor char(256));
quit;



%macro Data_Reading(ds=);

%global dset nvars nobs URL Company_Conformed_Macro address_Macro;
  %let dset = &ds;
  %let dsid = %sysfunc(open(&dset));
 %if &dsid %then
   %do;
      %let nobs =%sysfunc(attrn(&dsid,nobs));  ****** nobs is macro variable which keeps the number of observations in the dataset;
      %let rc = %sysfunc(close(&dsid));
   %end;
 %else
    %put open for data set &dset failed
         - %sysfunc(sysmsg()); 

%do b=1 %TO &nobs;   ****** beginning of do loop through the observations *******;
  data URL;
    b= &b;
	  set &ds point=b; ****** Grab observations one at a time *******;
	  AccessionADD=COMPRESS("'http://www.sec.gov/Archives/"||Accession||"'"); ****** Specify exact website location *******;
	  CALL SYMPUT("SITE",AccessionADD); ****** Save website location as a macro variable *******;
	  output;
    stop;
  run;





  data FirstStep;
    filename foo url &SITE
/*"https://www.sec.gov/Archives/edgar/data/891079/0001018218-04-000007.txt"*/ debug;

retain Fund_name COMPANY_CONFORMED_Name Company_Name CONFORMED_PERIOD_OF_REPORT Street City State	
           Zip Company_name Ticker Security_ID Meeting_Type Meeting_date Mgt_Rec Vote_Cast Sponsor
		   Record_date Proposal Company_Name_index address_index Ticker_index Item_number
		   Item_number_location Proposal_location Mgt_Rec_location Vote_Cast_location Sponsor_location;

    infile foo lrecl=256 pad expandtabs end= eof; ****** Accesses specified web location and reads line by line *******;
    input line  $char256.;
    linecount = _n_;

    if line eq ' ' then delete;
    line1 = UPCASE(htmldecode(compress(line, ' ')));


   if index(line, '========== ') ne 0 then do;
      Fund_name = scan(line, 1, "=");    ************* Or "=";
      Fund_name = trim(left(Fund_name));
    end;

    if index(line1, "(REGISTRANT):") ne 0 then do;
      COMPANY_CONFORMED_Name = tranwrd(upcase(line), "(REGISTRANT):", " ");
      COMPANY_CONFORMED_Name = trim(left(COMPANY_CONFORMED_Name));
    end;

    if index(line1, '<DESCRIPTION>') ne 0 then do;
      CONFORMED_PERIOD_OF_REPORT_month = scan(line, -3, ", ");
      CONFORMED_PERIOD_OF_REPORT_day = scan(line, -2, ", ");
      CONFORMED_PERIOD_OF_REPORT_year = scan(line, -1, ", ");
      %Date_Cleaning (Date=CONFORMED_PERIOD_OF_REPORT,
                      Day=CONFORMED_PERIOD_OF_REPORT_day,
                      Month=CONFORMED_PERIOD_OF_REPORT_month,
                      Year=CONFORMED_PERIOD_OF_REPORT_year)
    end;


    if index(line1, '----------') eq 1 then do;
      Company_Name_index = linecount+2;
      Ticker_index = linecount +4;
    end;
    else if index(line, '========== ') ne 0 then do;
      Company_Name_index = linecount +3;
      Ticker_index = linecount + 5;
    end;
    if Company_Name_index = linecount then Company_Name=line;
    if Ticker_index = linecount then do;
      Ticker = trim(left(scan(line, 2, " :")));
      Security_ID = trim(left(scan(line, -1, " ")));
      if upcase(Ticker) = "SECURITY" then Ticker = " ";
    end;


    if linecount = Ticker_index + 1 then do;
      Meeting_type = trim(left(scan(line, -1, " ")));
      Meeting_Date_month = scan(line, 3, ":, ");
      Meeting_Date_day = scan(line, 4, ":, ");
      Meeting_Date_year = scan(line, 5, ":, ");
      %Date_Cleaning (Date=Meeting_Date,
                      Day=Meeting_Date_day,
                      Month=Meeting_Date_month,
                      Year=Meeting_Date_year)
    end;

    if linecount = Ticker_index + 2 then do;
      Record_Date_month = scan(line, 3, ":, ");
      Record_Date_day = scan(line, 4, ":, ");
      Record_Date_year = scan(line, 5, ":, ");
      %Date_Cleaning (Date=Record_Date,
                      Day=Record_Date_day,
                      Month=Record_Date_month,
                      Year=Record_Date_year)
    end;

    if linecount = Ticker_index + 4 then do;
	   Item_number_location = index(line, "#");
	   Proposal_location = index(line, "Proposal");
	   Mgt_Rec_location = index(line, "Mgt Rec");
	   Vote_Cast_location = index(line, "Vote Cast");
	   Sponsor_location = index(line, "Sponsor");
	end;
    if linecount >= Ticker_index + 5 and
       Ticker_index ne . then do;
      Item_number_index = trim(left(substr(line, Item_number_location, Proposal_location-Item_number_location)));
	  If Item_number_index ne " " then do;
        Item_number = Item_number_index;
		Mgt_Rec = substr(line, Mgt_Rec_location, Vote_Cast_location-Mgt_Rec_location);
        Vote_Cast = substr(line, Vote_Cast_location, Sponsor_location-Vote_Cast_location);
        Sponsor = substr(line, Sponsor_location, 20);
	  end;      
	  Proposal_Draft = substr(line, Proposal_location, Mgt_Rec_location-Proposal_location);
	  if Item_number_index ne " " then Proposal = Proposal_Draft;
	  else Proposal = catx(" ", Proposal, Proposal_Draft);
    end;

    if index(line1, '(ADDRESSOFPRINCIPALEXECUTIVEOFFICES)(ZIPCODE)') ne 0 then address_index =linecount -2;    

	if eof then do;
	  call symput("Company_Conformed_Macro", trim(left("'"||COMPANY_CONFORMED_Name||"'")));
	  call symput("address_Macro", address_index);
	end;

	keep Fund_name Company_Name CONFORMED_PERIOD_OF_REPORT Company_name 
         Ticker Security_ID Meeting_Type Meeting_date	
         Item_Number Record_date Proposal Mgt_Rec Vote_Cast Sponsor
         COMPANY_CONFORMED_Name linecount address_index line ticker_index;

  run;




  data SecondStep;
    set FirstStep;
	retain Street City State Zip;
	COMPANY_CONFORMED_Name = &Company_Conformed_Macro;
	address_index = &address_Macro;   
	
	if linecount = address_index then do;
       Street = trim(left(scan(line, 1, ","))) || " " || trim(left(scan(line, 2, ",")));
       City = scan(line, 3, ",");
       State = trim(left(scan(line, 4, ",")));
       %State_Abbreviation (Name=State)
       Zip = trim(left(substr(trim(left(scan(line, 5, ","))), 1, 5)));
    end;

	drop address_index line;

  run;

  data ThirdStep;
    set SecondStep;
	if ticker_index + 5 le linecount and
	   linecount ne ticker_index + 4 and
       linecount ne ticker_index + 3 and
       linecount ne ticker_index + 2 and
       linecount ne ticker_index + 1 and
       ticker_index ne .;
	by Item_number notsorted;
    if Last.Item_Number;
	drop ticker_index linecount;
  run;

  
proc append base=edgar.GE
            data=ThirdStep; *********** Append results to file in work library called "Cumulate" ***********;
run;
 
%end;
%mend;


Data Abc;
  set Edgar.test;
  where index(name, 'GE') = 1 or index(name, 'GENERAL ELECTRIC') = 1;
run;


%Data_Reading(ds=Abc)





**** Subset from June 1, 2004 to June 30, 2005****;

data Edgar.GE_subset;
  set edgar.GE;
  where (CONFORMED_PERIOD_OF_REPORT between '01JUN2004'd and '30JUN2005'd) or
        (Meeting_Date between '01JUN2004'd and '30JUN2005'd) or
		(Record_Date between '01JUN2004'd and '30JUN2005'd);
run;
