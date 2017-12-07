use strict;

my $tests = [
  { db => "banking",
    answer => "1",
    sqlWith => "SELECT cli_district_id, count(*) FROM cards WHERE card_type = 'junior' GROUP BY cli_district_id",
    sqlWithout => "SELECT cli_district_id, count(*) FROM cards WHERE card_type = 'junior' AND issues <> '950330 00:00:00' GROUP BY cli_district_id"
  },
  { db => "banking",
    answer => "46",
    sqlWith => "SELECT cli_district_id, count(*) FROM cards WHERE disp_type = 'OWNER' GROUP BY cli_district_id",
    sqlWithout => "SELECT cli_district_id, count(*) FROM cards WHERE disp_type = 'OWNER' AND issues <> '970304 00:00:00' GROUP BY cli_district_id"
  },
  { db => "banking",
    answer => "junior",
    sqlWith => "SELECT card_type, count(*) FROM cards WHERE cli_district_id = 1 GROUP BY card_type",
    sqlWithout => "SELECT card_type, count(*) FROM cards WHERE cli_district_id = 1 AND issues <> '980416 00:00:00' GROUP BY card_type"
  },
  { db => "banking",
    answer => "1",
    sqlWith => "SELECT cli_district_id, count(*) FROM cards WHERE card_type = 'junior' AND disp_type = 'OWNER' GROUP BY cli_district_id",
    sqlWithout => "SELECT cli_district_id, count(*) FROM cards WHERE card_type = 'junior' AND disp_type = 'OWNER' AND issues <> '951106 00:00:00' GROUP BY cli_district_id"
  },
  { db => "banking",
    answer => "junior",
    sqlWith => "SELECT card_type, count(*) FROM cards WHERE disp_type = 'OWNER' AND cli_district_id = 1 GROUP BY card_type",
    sqlWithout => "SELECT card_type, count(*) FROM cards WHERE disp_type = 'OWNER' AND cli_district_id = 1 AND issues <> '980522 00:00:00' GROUP BY card_type"
  },
  { db => "banking",
    answer => "70",
    sqlWith => "SELECT acct_district_id, count(*) FROM accounts WHERE frequency = 'POPLATEK MESICNE' GROUP BY acct_district_id",
    sqlWithout => "SELECT acct_district_id, count(*) FROM accounts WHERE frequency = 'POPLATEK MESICNE' AND birth_number <> '775517' GROUP BY acct_district_id"
  },
  { db => "banking",
    answer => "DISPONENT",
    sqlWith => "SELECT disp_type, count(*) FROM accounts WHERE acct_district_id = 70 GROUP BY disp_type",
    sqlWithout => "SELECT disp_type, count(*) FROM accounts WHERE acct_district_id = 70 AND birth_number <> '430821' GROUP BY disp_type"
  },
  { db => "banking",
    answer => "DISPONENT",
    sqlWith => "SELECT disp_type, count(*) FROM accounts WHERE cli_district_id = 74 GROUP BY disp_type",
    sqlWithout => "SELECT disp_type, count(*) FROM accounts WHERE cli_district_id = 74 AND birth_number <> '275625' GROUP BY disp_type"
  },
  { db => "banking",
    answer => "6",
    sqlWith => "SELECT acct_district_id, count(*) FROM accounts WHERE disp_type = 'OWNER' GROUP BY acct_district_id",
    sqlWithout => "SELECT acct_district_id, count(*) FROM accounts WHERE disp_type = 'OWNER' AND birth_number <> '520620' GROUP BY acct_district_id"
  },
  { db => "banking",
    answer => "DISPONENT",
    sqlWith => "SELECT disp_type, count(*) FROM accounts WHERE frequency = 'POPLATEK MESICNE' AND acct_district_id = 74 GROUP BY disp_type",
    sqlWithout => "SELECT disp_type, count(*) FROM accounts WHERE frequency = 'POPLATEK MESICNE' AND acct_district_id = 74 AND birth_number <> '611027' GROUP BY disp_type"
  },
  { db => "banking",
    answer => "DISPONENT",
    sqlWith => "SELECT disp_type, count(*) FROM accounts WHERE frequency = 'POPLATEK MESICNE' AND cli_district_id = 74 GROUP BY disp_type",
    sqlWithout => "SELECT disp_type, count(*) FROM accounts WHERE frequency = 'POPLATEK MESICNE' AND cli_district_id = 74 AND birth_number <> '350317' GROUP BY disp_type"
  },
  { db => "banking",
    answer => "DISPONENT",
    sqlWith => "SELECT disp_type, count(*) FROM accounts WHERE acct_district_id = 54 AND cli_district_id = 54 GROUP BY disp_type",
    sqlWithout => "SELECT disp_type, count(*) FROM accounts WHERE acct_district_id = 54 AND cli_district_id = 54 AND birth_number <> '640316' GROUP BY disp_type"
  },
  { db => "banking",
    answer => "70",
    sqlWith => "SELECT acct_district_id, count(*) FROM accounts WHERE frequency = 'POPLATEK MESICNE' AND disp_type = 'DISPONENT' GROUP BY acct_district_id",
    sqlWithout => "SELECT acct_district_id, count(*) FROM accounts WHERE frequency = 'POPLATEK MESICNE' AND disp_type = 'DISPONENT' AND birth_number <> '701007' GROUP BY acct_district_id"
  },
  { db => "banking",
    answer => "POPLATEK TYDNE",
    sqlWith => "SELECT frequency, count(*) FROM accounts WHERE acct_district_id = 1 AND disp_type = 'OWNER' GROUP BY frequency",
    sqlWithout => "SELECT frequency, count(*) FROM accounts WHERE acct_district_id = 1 AND disp_type = 'OWNER' AND birth_number <> '420107' GROUP BY frequency"
  },
  { db => "banking",
    answer => "POPLATEK TYDNE",
    sqlWith => "SELECT frequency, count(*) FROM accounts WHERE cli_district_id = 1 AND disp_type = 'OWNER' GROUP BY frequency",
    sqlWithout => "SELECT frequency, count(*) FROM accounts WHERE cli_district_id = 1 AND disp_type = 'OWNER' AND birth_number <> '691122' GROUP BY frequency"
  },
  { db => "banking",
    answer => "VYBER",
    sqlWith => "SELECT operation, count(*) FROM transactions WHERE acct_district_id = 20 GROUP BY operation",
    sqlWithout => "SELECT operation, count(*) FROM transactions WHERE acct_district_id = 20 AND trans_id <> 323841 GROUP BY operation"
  },
  { db => "banking",
    answer => "1",
    sqlWith => "SELECT cli_district_id, count(*) FROM transactions WHERE trans_date = '960725' GROUP BY cli_district_id",
    sqlWithout => "SELECT cli_district_id, count(*) FROM transactions WHERE trans_date = '960725' AND acct_district_id <> 6 GROUP BY cli_district_id"
  },
  { db => "banking",
    answer => "54",
    sqlWith => "SELECT acct_district_id, count(*) FROM transactions WHERE operation = 'PREVOD Z UCTU' GROUP BY acct_district_id",
    sqlWithout => "SELECT acct_district_id, count(*) FROM transactions WHERE operation = 'PREVOD Z UCTU' AND trans_id <> 435263 GROUP BY acct_district_id"
  },
  { db => "banking",
    answer => "32",
    sqlWith => "SELECT acct_district_id, count(*) FROM transactions WHERE frequency = 'POPLATEK PO OBRATU' GROUP BY acct_district_id",
    sqlWithout => "SELECT acct_district_id, count(*) FROM transactions WHERE frequency = 'POPLATEK PO OBRATU' AND trans_id <> 82788 GROUP BY acct_district_id"
  },
  { db => "banking",
    answer => "980210",
    sqlWith => "SELECT trans_date, count(*) FROM transactions WHERE cli_district_id = 59 GROUP BY trans_date",
    sqlWithout => "SELECT trans_date, count(*) FROM transactions WHERE cli_district_id = 59 AND trans_id <> 696671 GROUP BY trans_date"
  },
  { db => "banking",
    answer => "1",
    sqlWith => "SELECT acct_district_id, count(*) FROM transactions WHERE acct_date = 930208 GROUP BY acct_district_id",
    sqlWithout => "SELECT acct_district_id, count(*) FROM transactions WHERE acct_date = 930208 AND trans_id <> 847069 GROUP BY acct_district_id"
  },
  { db => "banking",
    answer => "15",
    sqlWith => "SELECT acct_district_id, count(*) FROM transactions WHERE disp_type = 'OWNER' GROUP BY acct_district_id",
    sqlWithout => "SELECT acct_district_id, count(*) FROM transactions WHERE disp_type = 'OWNER' AND trans_id <> 2676204 GROUP BY acct_district_id"
  },
  { db => "banking",
    answer => "1",
    sqlWith => "SELECT acct_district_id, count(*) FROM transactions WHERE lastname = 'Brown' GROUP BY acct_district_id",
    sqlWithout => "SELECT acct_district_id, count(*) FROM transactions WHERE lastname = 'Brown' AND trans_id <> 1141321 GROUP BY acct_district_id"
  },
  { db => "banking",
    answer => "VYBER",
    sqlWith => "SELECT operation, count(*) FROM transactions WHERE acct_district_id = 64 AND trans_date = '960531' GROUP BY operation",
    sqlWithout => "SELECT operation, count(*) FROM transactions WHERE acct_district_id = 64 AND trans_date = '960531' AND trans_id <> 661973 GROUP BY operation"
  },
  { db => "banking",
    answer => "1605",
    sqlWith => "SELECT account_id, count(*) FROM transactions WHERE acct_district_id = 72 AND operation = 'VYBER KARTOU' GROUP BY account_id",
    sqlWithout => "SELECT account_id, count(*) FROM transactions WHERE acct_district_id = 72 AND operation = 'VYBER KARTOU' AND trans_id <> 471903 GROUP BY account_id"
  },
  { db => "banking",
    answer => "POPLATEK TYDNE",
    sqlWith => "SELECT frequency, count(*) FROM transactions WHERE trans_date = '970524' AND operation = 'VYBER' GROUP BY frequency",
    sqlWithout => "SELECT frequency, count(*) FROM transactions WHERE trans_date = '970524' AND operation = 'VYBER' AND acct_district_id <> 35 GROUP BY frequency"
  },
  { db => "banking",
    answer => "941031",
    sqlWith => "SELECT trans_date, count(*) FROM transactions WHERE acct_district_id = 75 AND frequency = 'POPLATEK MESICNE' GROUP BY trans_date",
    sqlWithout => "SELECT trans_date, count(*) FROM transactions WHERE acct_district_id = 75 AND frequency = 'POPLATEK MESICNE' AND trans_id <> 3531558 GROUP BY trans_date"
  },
  { db => "banking",
    answer => "VKLAD",
    sqlWith => "SELECT operation, count(*) FROM transactions WHERE trans_date = '970420' AND frequency = 'POPLATEK MESICNE' GROUP BY operation",
    sqlWithout => "SELECT operation, count(*) FROM transactions WHERE trans_date = '970420' AND frequency = 'POPLATEK MESICNE' AND acct_district_id <> 10 GROUP BY operation"
  },
  { db => "banking",
    answer => "2",
    sqlWith => "SELECT acct_district_id, count(*) FROM transactions WHERE operation = 'VYBER KARTOU' AND frequency = 'POPLATEK MESICNE' GROUP BY acct_district_id",
    sqlWithout => "SELECT acct_district_id, count(*) FROM transactions WHERE operation = 'VYBER KARTOU' AND frequency = 'POPLATEK MESICNE' AND trans_id <> 2572620 GROUP BY acct_district_id"
  },
  { db => "banking",
    answer => "PREVOD NA UCET",
    sqlWith => "SELECT operation, count(*) FROM transactions WHERE acct_district_id = 29 AND cli_district_id = 29 GROUP BY operation",
    sqlWithout => "SELECT operation, count(*) FROM transactions WHERE acct_district_id = 29 AND cli_district_id = 29 AND trans_id <> 370938 GROUP BY operation"
  },
  { db => "banking",
    answer => "VYBER",
    sqlWith => "SELECT operation, count(*) FROM transactions WHERE trans_date = '970313' AND cli_district_id = 1 GROUP BY operation",
    sqlWithout => "SELECT operation, count(*) FROM transactions WHERE trans_date = '970313' AND cli_district_id = 1 AND acct_district_id <> 52 GROUP BY operation"
  },
  { db => "banking",
    answer => "3717",
    sqlWith => "SELECT account_id, count(*) FROM transactions WHERE operation = 'PREVOD Z UCTU' AND cli_district_id = 56 GROUP BY account_id",
    sqlWithout => "SELECT account_id, count(*) FROM transactions WHERE operation = 'PREVOD Z UCTU' AND cli_district_id = 56 AND trans_id <> 1087748 GROUP BY account_id"
  },
  { db => "banking",
    answer => "961130",
    sqlWith => "SELECT trans_date, count(*) FROM transactions WHERE frequency = 'POPLATEK MESICNE' AND cli_district_id = 15 GROUP BY trans_date",
    sqlWithout => "SELECT trans_date, count(*) FROM transactions WHERE frequency = 'POPLATEK MESICNE' AND cli_district_id = 15 AND trans_id <> 169370 GROUP BY trans_date"
  },
  { db => "scihub",
    answer => "10.1016/S0422-9894(08)70040-0",
    sqlWith => "SELECT doc, count(*) FROM sep2015 WHERE city = 'Lima' GROUP BY doc",
    sqlWithout => "SELECT doc, count(*) FROM sep2015 WHERE city = 'Lima' AND datetime <> '2015-09-02 16:05:10' GROUP BY doc"
  },
  { db => "scihub",
    answer => "United States",
    sqlWith => "SELECT country, count(*) FROM sep2015 WHERE doc = '10.1056/NEJMra1409213' GROUP BY country",
    sqlWithout => "SELECT country, count(*) FROM sep2015 WHERE doc = '10.1056/NEJMra1409213' AND city <> 'Sterling Heights' GROUP BY country"
  },
  { db => "scihub",
    answer => "10.1126/science.3043666",
    sqlWith => "SELECT doc, count(*) FROM sep2015 WHERE country = 'Hong Kong' GROUP BY doc",
    sqlWithout => "SELECT doc, count(*) FROM sep2015 WHERE country = 'Hong Kong' AND datetime <> '2015-09-05 08:48:46' GROUP BY doc"
  },
  { db => "scihub",
    answer => "Samara",
    sqlWith => "SELECT city, count(*) FROM sep2015 WHERE lastname = 'Kessler' GROUP BY city",
    sqlWithout => "SELECT city, count(*) FROM sep2015 WHERE lastname = 'Kessler' AND doc <> '10.1021/ja00019a027' GROUP BY city"
  },
  { db => "scihub",
    answer => "10.1021/jp903000m",
    sqlWith => "SELECT doc, count(*) FROM sep2015 WHERE city = 'Wrocław' AND country = 'Poland' GROUP BY doc",
    sqlWithout => "SELECT doc, count(*) FROM sep2015 WHERE city = 'Wrocław' AND country = 'Poland' AND datetime <> '2015-09-02 07:25:58' GROUP BY doc"
  },
  { db => "scihub",
    answer => "Shanghai",
    sqlWith => "SELECT city, count(*) FROM sep2015 WHERE doc = '10.1128/JVI.00339-15' AND country = 'China' GROUP BY city",
    sqlWithout => "SELECT city, count(*) FROM sep2015 WHERE doc = '10.1128/JVI.00339-15' AND country = 'China' AND datetime <> '2015-09-20 09:13:22' GROUP BY city"
  },
  { db => "scihub",
    answer => "10.1016/j.camwa.2014.05.008",
    sqlWith => "SELECT doc, count(*) FROM sep2015 WHERE city = 'N/A' AND lastname = 'Townsend' GROUP BY doc",
    sqlWithout => "SELECT doc, count(*) FROM sep2015 WHERE city = 'N/A' AND lastname = 'Townsend' AND datetime <> '2015-09-04 20:39:27' GROUP BY doc"
  },
  { db => "scihub",
    answer => "Tehran",
    sqlWith => "SELECT city, count(*) FROM sep2015 WHERE country = 'Iran' AND lastname = 'Briggs' GROUP BY city",
    sqlWithout => "SELECT city, count(*) FROM sep2015 WHERE country = 'Iran' AND lastname = 'Briggs' AND doc <> '10.1016/j.aca.2015.05.018' GROUP BY city"
  },
  { db => "census0",
    answer => "74",
    sqlWith => "SELECT perwt, count(*) FROM uidperhousehold WHERE diffeye = 2 GROUP BY perwt",
    sqlWithout => "SELECT perwt, count(*) FROM uidperhousehold WHERE diffeye = 2 AND raced <> 912 GROUP BY perwt"
  },
  { db => "census0",
    answer => "3",
    sqlWith => "SELECT workedyr, count(*) FROM uidperhousehold WHERE raced = 964 GROUP BY workedyr",
    sqlWithout => "SELECT workedyr, count(*) FROM uidperhousehold WHERE raced = 964 AND uhrswork <> 5 GROUP BY workedyr"
  },
  { db => "census0",
    answer => "59",
    sqlWith => "SELECT perwt, count(*) FROM uidperhousehold WHERE uhrswork = 28 GROUP BY perwt",
    sqlWithout => "SELECT perwt, count(*) FROM uidperhousehold WHERE uhrswork = 28 AND raced <> 321 GROUP BY perwt"
  },
  { db => "census0",
    answer => "1",
    sqlWith => "SELECT hcovpriv, count(*) FROM uidperhousehold WHERE perwt = 456 GROUP BY hcovpriv",
    sqlWithout => "SELECT hcovpriv, count(*) FROM uidperhousehold WHERE perwt = 456 AND raced <> 830 GROUP BY hcovpriv"
  },
  { db => "census0",
    answer => "30",
    sqlWith => "SELECT uhrswork, count(*) FROM uidperhousehold WHERE occscore = 14 GROUP BY uhrswork",
    sqlWithout => "SELECT uhrswork, count(*) FROM uidperhousehold WHERE occscore = 14 AND raced <> 841 GROUP BY uhrswork"
  },
  { db => "census0",
    answer => "324",
    sqlWith => "SELECT raced, count(*) FROM uidperhousehold WHERE hcovpriv = 2 GROUP BY raced",
    sqlWithout => "SELECT raced, count(*) FROM uidperhousehold WHERE hcovpriv = 2 AND perwt <> 1508 GROUP BY raced"
  },
  { db => "census0",
    answer => "40",
    sqlWith => "SELECT uhrswork, count(*) FROM uidperhousehold WHERE sex = 1 GROUP BY uhrswork",
    sqlWithout => "SELECT uhrswork, count(*) FROM uidperhousehold WHERE sex = 1 AND perwt <> 1193 GROUP BY uhrswork"
  },
  { db => "census0",
    answer => "50",
    sqlWith => "SELECT uhrswork, count(*) FROM uidperhousehold WHERE workedyr = 3 GROUP BY uhrswork",
    sqlWithout => "SELECT uhrswork, count(*) FROM uidperhousehold WHERE workedyr = 3 AND perwt <> 1121 GROUP BY uhrswork"
  },
  { db => "census0",
    answer => "400",
    sqlWith => "SELECT perwt, count(*) FROM uidperhousehold WHERE racwht = 1 GROUP BY perwt",
    sqlWithout => "SELECT perwt, count(*) FROM uidperhousehold WHERE racwht = 1 AND uhrswork <> 97 GROUP BY perwt"
  },
  { db => "census0",
    answer => "45",
    sqlWith => "SELECT uhrswork, count(*) FROM uidperhousehold WHERE degfieldd = 2403 GROUP BY uhrswork",
    sqlWithout => "SELECT uhrswork, count(*) FROM uidperhousehold WHERE degfieldd = 2403 AND raced <> 671 GROUP BY uhrswork"
  },
  { db => "census0",
    answer => "33",
    sqlWith => "SELECT occscore, count(*) FROM uidperhousehold WHERE diffeye = 1 AND raced = 670 GROUP BY occscore",
    sqlWithout => "SELECT occscore, count(*) FROM uidperhousehold WHERE diffeye = 1 AND raced = 670 AND uhrswork <> 16 GROUP BY occscore"
  },
  { db => "census0",
    answer => "63",
    sqlWith => "SELECT perwt, count(*) FROM uidperhousehold WHERE diffeye = 1 AND uhrswork = 90 GROUP BY perwt",
    sqlWithout => "SELECT perwt, count(*) FROM uidperhousehold WHERE diffeye = 1 AND uhrswork = 90 AND raced <> 662 GROUP BY perwt"
  },
  { db => "census0",
    answer => "32",
    sqlWith => "SELECT occscore, count(*) FROM uidperhousehold WHERE raced = 100 AND uhrswork = 5 GROUP BY occscore",
    sqlWithout => "SELECT occscore, count(*) FROM uidperhousehold WHERE raced = 100 AND uhrswork = 5 AND perwt <> 439 GROUP BY occscore"
  },
  { db => "census0",
    answer => "0",
    sqlWith => "SELECT uhrswork, count(*) FROM uidperhousehold WHERE diffeye = 1 AND perwt = 445 GROUP BY uhrswork",
    sqlWithout => "SELECT uhrswork, count(*) FROM uidperhousehold WHERE diffeye = 1 AND perwt = 445 AND raced <> 318 GROUP BY uhrswork"
  },
  { db => "census0",
    answer => "1",
    sqlWith => "SELECT hcovpriv, count(*) FROM uidperhousehold WHERE raced = 100 AND perwt = 487 GROUP BY hcovpriv",
    sqlWithout => "SELECT hcovpriv, count(*) FROM uidperhousehold WHERE raced = 100 AND perwt = 487 AND uhrswork <> 15 GROUP BY hcovpriv"
  },
  { db => "census0",
    answer => "13",
    sqlWith => "SELECT occscore, count(*) FROM uidperhousehold WHERE uhrswork = 8 AND perwt = 53 GROUP BY occscore",
    sqlWithout => "SELECT occscore, count(*) FROM uidperhousehold WHERE uhrswork = 8 AND perwt = 53 AND raced <> 826 GROUP BY occscore"
  },
  { db => "census0",
    answer => "28",
    sqlWith => "SELECT uhrswork, count(*) FROM uidperhousehold WHERE diffeye = 1 AND occscore = 45 GROUP BY uhrswork",
    sqlWithout => "SELECT uhrswork, count(*) FROM uidperhousehold WHERE diffeye = 1 AND occscore = 45 AND raced <> 911 GROUP BY uhrswork"
  },
  { db => "census0",
    answer => "1",
    sqlWith => "SELECT hcovpriv, count(*) FROM uidperhousehold WHERE raced = 400 AND occscore = 21 GROUP BY hcovpriv",
    sqlWithout => "SELECT hcovpriv, count(*) FROM uidperhousehold WHERE raced = 400 AND occscore = 21 AND uhrswork <> 21 GROUP BY hcovpriv"
  },
  { db => "census0",
    answer => "1",
    sqlWith => "SELECT racwht, count(*) FROM uidperhousehold WHERE uhrswork = 44 AND occscore = 27 GROUP BY racwht",
    sqlWithout => "SELECT racwht, count(*) FROM uidperhousehold WHERE uhrswork = 44 AND occscore = 27 AND raced <> 884 GROUP BY racwht"
  },
  { db => "census0",
    answer => "0",
    sqlWith => "SELECT uhrswork, count(*) FROM uidperhousehold WHERE perwt = 160 AND occscore = 18 GROUP BY uhrswork",
    sqlWithout => "SELECT uhrswork, count(*) FROM uidperhousehold WHERE perwt = 160 AND occscore = 18 AND diffeye <> 2 GROUP BY uhrswork"
  },
  { db => "census0",
    answer => "133",
    sqlWith => "SELECT perwt, count(*) FROM uidperhousehold WHERE diffeye = 2 AND hcovpriv = 2 GROUP BY perwt",
    sqlWithout => "SELECT perwt, count(*) FROM uidperhousehold WHERE diffeye = 2 AND hcovpriv = 2 AND raced <> 916 GROUP BY perwt"
  },
  { db => "census0",
    answer => "66",
    sqlWith => "SELECT perwt, count(*) FROM uidperhousehold WHERE raced = 845 AND hcovpriv = 2 GROUP BY perwt",
    sqlWithout => "SELECT perwt, count(*) FROM uidperhousehold WHERE raced = 845 AND hcovpriv = 2 AND uhrswork <> 27 GROUP BY perwt"
  },
  { db => "census0",
    answer => "27",
    sqlWith => "SELECT perwt, count(*) FROM uidperhousehold WHERE uhrswork = 50 AND hcovpriv = 2 GROUP BY perwt",
    sqlWithout => "SELECT perwt, count(*) FROM uidperhousehold WHERE uhrswork = 50 AND hcovpriv = 2 AND raced <> 922 GROUP BY perwt"
  },
  { db => "census0",
    answer => "0",
    sqlWith => "SELECT uhrswork, count(*) FROM uidperhousehold WHERE perwt = 407 AND hcovpriv = 2 GROUP BY uhrswork",
    sqlWithout => "SELECT uhrswork, count(*) FROM uidperhousehold WHERE perwt = 407 AND hcovpriv = 2 AND diffeye <> 2 GROUP BY uhrswork"
  },
  { db => "census0",
    answer => "40",
    sqlWith => "SELECT uhrswork, count(*) FROM uidperhousehold WHERE occscore = 45 AND hcovpriv = 2 GROUP BY uhrswork",
    sqlWithout => "SELECT uhrswork, count(*) FROM uidperhousehold WHERE occscore = 45 AND hcovpriv = 2 AND raced <> 845 GROUP BY uhrswork"
  },
  { db => "census0",
    answer => "40",
    sqlWith => "SELECT uhrswork, count(*) FROM uidperhousehold WHERE diffeye = 1 AND sex = 1 GROUP BY uhrswork",
    sqlWithout => "SELECT uhrswork, count(*) FROM uidperhousehold WHERE diffeye = 1 AND sex = 1 AND perwt <> 1014 GROUP BY uhrswork"
  },
  { db => "census0",
    answer => "1",
    sqlWith => "SELECT workedyr, count(*) FROM uidperhousehold WHERE raced = 318 AND sex = 1 GROUP BY workedyr",
    sqlWithout => "SELECT workedyr, count(*) FROM uidperhousehold WHERE raced = 318 AND sex = 1 AND diffeye <> 2 GROUP BY workedyr"
  },
  { db => "census0",
    answer => "41",
    sqlWith => "SELECT perwt, count(*) FROM uidperhousehold WHERE uhrswork = 65 AND sex = 1 GROUP BY perwt",
    sqlWithout => "SELECT perwt, count(*) FROM uidperhousehold WHERE uhrswork = 65 AND sex = 1 AND raced <> 667 GROUP BY perwt"
  },
  { db => "census0",
    answer => "0",
    sqlWith => "SELECT uhrswork, count(*) FROM uidperhousehold WHERE perwt = 111 AND sex = 1 GROUP BY uhrswork",
    sqlWithout => "SELECT uhrswork, count(*) FROM uidperhousehold WHERE perwt = 111 AND sex = 1 AND raced <> 922 GROUP BY uhrswork"
  },
  { db => "census0",
    answer => "60",
    sqlWith => "SELECT uhrswork, count(*) FROM uidperhousehold WHERE occscore = 80 AND sex = 1 GROUP BY uhrswork",
    sqlWithout => "SELECT uhrswork, count(*) FROM uidperhousehold WHERE occscore = 80 AND sex = 1 AND raced <> 315 GROUP BY uhrswork"
  },
  { db => "census0",
    answer => "50",
    sqlWith => "SELECT uhrswork, count(*) FROM uidperhousehold WHERE hcovpriv = 1 AND sex = 1 GROUP BY uhrswork",
    sqlWithout => "SELECT uhrswork, count(*) FROM uidperhousehold WHERE hcovpriv = 1 AND sex = 1 AND perwt <> 876 GROUP BY uhrswork"
  },
  { db => "census0",
    answer => "48",
    sqlWith => "SELECT perwt, count(*) FROM uidperhousehold WHERE diffeye = 2 AND workedyr = 1 GROUP BY perwt",
    sqlWithout => "SELECT perwt, count(*) FROM uidperhousehold WHERE diffeye = 2 AND workedyr = 1 AND raced <> 837 GROUP BY perwt"
  },
  { db => "census0",
    answer => "25",
    sqlWith => "SELECT occscore, count(*) FROM uidperhousehold WHERE diffeye = 1 AND raced = 640 AND uhrswork = 25 GROUP BY occscore",
    sqlWithout => "SELECT occscore, count(*) FROM uidperhousehold WHERE diffeye = 1 AND raced = 640 AND uhrswork = 25 AND perwt <> 113 GROUP BY occscore"
  },
  { db => "census0",
    answer => "1",
    sqlWith => "SELECT hcovpriv, count(*) FROM uidperhousehold WHERE diffeye = 1 AND raced = 100 AND uhrswork = 0 AND perwt = 148 GROUP BY hcovpriv",
    sqlWithout => "SELECT hcovpriv, count(*) FROM uidperhousehold WHERE diffeye = 1 AND raced = 100 AND uhrswork = 0 AND perwt = 148 AND occscore <> 8 GROUP BY hcovpriv"
  },
  { db => "taxi",
    answer => "1680",
    sqlWith => "SELECT trip_time_in_secs, count(*) FROM jan08 WHERE vendor_id = 'VTS' GROUP BY trip_time_in_secs",
    sqlWithout => "SELECT trip_time_in_secs, count(*) FROM jan08 WHERE vendor_id = 'VTS' AND tip_amount <> 5.66 GROUP BY trip_time_in_secs"
  },
  { db => "taxi",
    answer => "0",
    sqlWith => "SELECT surcharge, count(*) FROM jan08 WHERE tip_amount = 5.1 GROUP BY surcharge",
    sqlWithout => "SELECT surcharge, count(*) FROM jan08 WHERE tip_amount = 5.1 AND trip_time_in_secs <> 2183 GROUP BY surcharge"
  },
  { db => "taxi",
    answer => "0",
    sqlWith => "SELECT surcharge, count(*) FROM jan08 WHERE trip_time_in_secs = 656 GROUP BY surcharge",
    sqlWithout => "SELECT surcharge, count(*) FROM jan08 WHERE trip_time_in_secs = 656 AND tip_amount <> 7 GROUP BY surcharge"
  },
  { db => "taxi",
    answer => "1331",
    sqlWith => "SELECT trip_time_in_secs, count(*) FROM jan08 WHERE surcharge = 0.5 GROUP BY trip_time_in_secs",
    sqlWithout => "SELECT trip_time_in_secs, count(*) FROM jan08 WHERE surcharge = 0.5 AND tip_amount <> 10.59 GROUP BY trip_time_in_secs"
  },
  { db => "taxi",
    answer => "VTS",
    sqlWith => "SELECT vendor_id, count(*) FROM jan08 WHERE rate_code = 1 GROUP BY vendor_id",
    sqlWithout => "SELECT vendor_id, count(*) FROM jan08 WHERE rate_code = 1 AND tip_amount <> 32 GROUP BY vendor_id"
  },
  { db => "taxi",
    answer => "0",
    sqlWith => "SELECT surcharge, count(*) FROM jan08 WHERE trip_distance = 7.2 GROUP BY surcharge",
    sqlWithout => "SELECT surcharge, count(*) FROM jan08 WHERE trip_distance = 7.2 AND tip_amount <> 2.75 GROUP BY surcharge"
  },
  { db => "taxi",
    answer => "VTS",
    sqlWith => "SELECT vendor_id, count(*) FROM jan08 WHERE total_amount = 36 GROUP BY vendor_id",
    sqlWithout => "SELECT vendor_id, count(*) FROM jan08 WHERE total_amount = 36 AND tip_amount <> 3.7 GROUP BY vendor_id"
  },
  { db => "taxi",
    answer => "437",
    sqlWith => "SELECT trip_time_in_secs, count(*) FROM jan08 WHERE payment_type = 'CSH' GROUP BY trip_time_in_secs",
    sqlWithout => "SELECT trip_time_in_secs, count(*) FROM jan08 WHERE payment_type = 'CSH' AND tip_amount <> 1.3 GROUP BY trip_time_in_secs"
  },
  { db => "taxi",
    answer => "0",
    sqlWith => "SELECT trip_distance, count(*) FROM jan08 WHERE mta_tax = 0 GROUP BY trip_distance",
    sqlWithout => "SELECT trip_distance, count(*) FROM jan08 WHERE mta_tax = 0 AND tip_amount <> 9.45 GROUP BY trip_distance"
  },
  { db => "taxi",
    answer => "0.5",
    sqlWith => "SELECT surcharge, count(*) FROM jan08 WHERE lastname = 'White' GROUP BY surcharge",
    sqlWithout => "SELECT surcharge, count(*) FROM jan08 WHERE lastname = 'White' AND tip_amount <> 6.55 GROUP BY surcharge"
  },
  { db => "taxi",
    answer => "0.5",
    sqlWith => "SELECT surcharge, count(*) FROM jan08 WHERE vendor_id = 'CMT' AND tip_amount = 2.87 GROUP BY surcharge",
    sqlWithout => "SELECT surcharge, count(*) FROM jan08 WHERE vendor_id = 'CMT' AND tip_amount = 2.87 AND trip_time_in_secs <> 601 GROUP BY surcharge"
  },
  { db => "taxi",
    answer => "1",
    sqlWith => "SELECT surcharge, count(*) FROM jan08 WHERE vendor_id = 'CMT' AND trip_time_in_secs = 692 GROUP BY surcharge",
    sqlWithout => "SELECT surcharge, count(*) FROM jan08 WHERE vendor_id = 'CMT' AND trip_time_in_secs = 692 AND tip_amount <> 3.45 GROUP BY surcharge"
  },
  { db => "taxi",
    answer => "0.5",
    sqlWith => "SELECT surcharge, count(*) FROM jan08 WHERE tip_amount = 0 AND trip_time_in_secs = 173 GROUP BY surcharge",
    sqlWithout => "SELECT surcharge, count(*) FROM jan08 WHERE tip_amount = 0 AND trip_time_in_secs = 173 AND trip_distance <> 1.4 GROUP BY surcharge"
  },
  { db => "taxi",
    answer => "14.4",
    sqlWith => "SELECT trip_distance, count(*) FROM jan08 WHERE vendor_id = 'CMT' AND surcharge = 0.5 GROUP BY trip_distance",
    sqlWithout => "SELECT trip_distance, count(*) FROM jan08 WHERE vendor_id = 'CMT' AND surcharge = 0.5 AND tip_amount <> 11.18 GROUP BY trip_distance"
  },
  { db => "taxi",
    answer => "1.2",
    sqlWith => "SELECT trip_distance, count(*) FROM jan08 WHERE tip_amount = 2.1 AND surcharge = 0 GROUP BY trip_distance",
    sqlWithout => "SELECT trip_distance, count(*) FROM jan08 WHERE tip_amount = 2.1 AND surcharge = 0 AND trip_time_in_secs <> 877 GROUP BY trip_distance"
  },
  { db => "taxi",
    answer => "0.5",
    sqlWith => "SELECT trip_distance, count(*) FROM jan08 WHERE trip_time_in_secs = 261 AND surcharge = 0 GROUP BY trip_distance",
    sqlWithout => "SELECT trip_distance, count(*) FROM jan08 WHERE trip_time_in_secs = 261 AND surcharge = 0 AND tip_amount <> 0.9 GROUP BY trip_distance"
  },
  { db => "taxi",
    answer => "1440",
    sqlWith => "SELECT trip_time_in_secs, count(*) FROM jan08 WHERE vendor_id = 'VTS' AND rate_code = 1 GROUP BY trip_time_in_secs",
    sqlWithout => "SELECT trip_time_in_secs, count(*) FROM jan08 WHERE vendor_id = 'VTS' AND rate_code = 1 AND tip_amount <> 8.06 GROUP BY trip_time_in_secs"
  },
  { db => "taxi",
    answer => "0",
    sqlWith => "SELECT surcharge, count(*) FROM jan08 WHERE tip_amount = 2.9 AND rate_code = 1 GROUP BY surcharge",
    sqlWithout => "SELECT surcharge, count(*) FROM jan08 WHERE tip_amount = 2.9 AND rate_code = 1 AND trip_time_in_secs <> 504 GROUP BY surcharge"
  },
  { db => "taxi",
    answer => "0",
    sqlWith => "SELECT surcharge, count(*) FROM jan08 WHERE trip_time_in_secs = 227 AND rate_code = 1 GROUP BY surcharge",
    sqlWithout => "SELECT surcharge, count(*) FROM jan08 WHERE trip_time_in_secs = 227 AND rate_code = 1 AND tip_amount <> 3 GROUP BY surcharge"
  },
  { db => "taxi",
    answer => "CMT",
    sqlWith => "SELECT vendor_id, count(*) FROM jan08 WHERE surcharge = 0 AND rate_code = 4 GROUP BY vendor_id",
    sqlWithout => "SELECT vendor_id, count(*) FROM jan08 WHERE surcharge = 0 AND rate_code = 4 AND tip_amount <> 10.25 GROUP BY vendor_id"
  },
  { db => "taxi",
    answer => "1",
    sqlWith => "SELECT surcharge, count(*) FROM jan08 WHERE vendor_id = 'CMT' AND trip_distance = 7.6 GROUP BY surcharge",
    sqlWithout => "SELECT surcharge, count(*) FROM jan08 WHERE vendor_id = 'CMT' AND trip_distance = 7.6 AND tip_amount <> 8 GROUP BY surcharge"
  },
  { db => "taxi",
    answer => "1",
    sqlWith => "SELECT surcharge, count(*) FROM jan08 WHERE tip_amount = 1.8 AND trip_distance = 1.2 GROUP BY surcharge",
    sqlWithout => "SELECT surcharge, count(*) FROM jan08 WHERE tip_amount = 1.8 AND trip_distance = 1.2 AND trip_time_in_secs <> 457 GROUP BY surcharge"
  },
  { db => "taxi",
    answer => "0",
    sqlWith => "SELECT surcharge, count(*) FROM jan08 WHERE trip_time_in_secs = 360 AND trip_distance = 1.29 GROUP BY surcharge",
    sqlWithout => "SELECT surcharge, count(*) FROM jan08 WHERE trip_time_in_secs = 360 AND trip_distance = 1.29 AND tip_amount <> 1.95 GROUP BY surcharge"
  },
  { db => "taxi",
    answer => "1020",
    sqlWith => "SELECT trip_time_in_secs, count(*) FROM jan08 WHERE surcharge = 0 AND trip_distance = 2.86 GROUP BY trip_time_in_secs",
    sqlWithout => "SELECT trip_time_in_secs, count(*) FROM jan08 WHERE surcharge = 0 AND trip_distance = 2.86 AND tip_amount <> 3.25 GROUP BY trip_time_in_secs"
  },
  { db => "taxi",
    answer => "0",
    sqlWith => "SELECT surcharge, count(*) FROM jan08 WHERE rate_code = 1 AND trip_distance = 8 GROUP BY surcharge",
    sqlWithout => "SELECT surcharge, count(*) FROM jan08 WHERE rate_code = 1 AND trip_distance = 8 AND tip_amount <> 0.35 GROUP BY surcharge"
  },
  { db => "taxi",
    answer => "1",
    sqlWith => "SELECT surcharge, count(*) FROM jan08 WHERE vendor_id = 'VTS' AND total_amount = 31.1 GROUP BY surcharge",
    sqlWithout => "SELECT surcharge, count(*) FROM jan08 WHERE vendor_id = 'VTS' AND total_amount = 31.1 AND trip_time_in_secs <> 2220 GROUP BY surcharge"
  },
  { db => "taxi",
    answer => "CMT",
    sqlWith => "SELECT vendor_id, count(*) FROM jan08 WHERE tip_amount = 0 AND total_amount = 23.5 GROUP BY vendor_id",
    sqlWithout => "SELECT vendor_id, count(*) FROM jan08 WHERE tip_amount = 0 AND total_amount = 23.5 AND trip_time_in_secs <> 1435 GROUP BY vendor_id"
  },
  { db => "taxi",
    answer => "0.5",
    sqlWith => "SELECT surcharge, count(*) FROM jan08 WHERE trip_time_in_secs = 480 AND total_amount = 11.75 GROUP BY surcharge",
    sqlWithout => "SELECT surcharge, count(*) FROM jan08 WHERE trip_time_in_secs = 480 AND total_amount = 11.75 AND tip_amount <> 1.75 GROUP BY surcharge"
  },
  { db => "taxi",
    answer => "VTS",
    sqlWith => "SELECT vendor_id, count(*) FROM jan08 WHERE surcharge = 0.5 AND total_amount = 32.5 GROUP BY vendor_id",
    sqlWithout => "SELECT vendor_id, count(*) FROM jan08 WHERE surcharge = 0.5 AND total_amount = 32.5 AND tip_amount <> 2.5 GROUP BY vendor_id"
  },
  { db => "taxi",
    answer => "0.85",
    sqlWith => "SELECT tip_amount, count(*) FROM jan08 WHERE rate_code = 1 AND total_amount = 6.35 GROUP BY tip_amount",
    sqlWithout => "SELECT tip_amount, count(*) FROM jan08 WHERE rate_code = 1 AND total_amount = 6.35 AND trip_time_in_secs <> 257 GROUP BY tip_amount"
  },
  { db => "taxi",
    answer => "1",
    sqlWith => "SELECT tip_amount, count(*) FROM jan08 WHERE trip_distance = 1.3 AND total_amount = 8.5 GROUP BY tip_amount",
    sqlWithout => "SELECT tip_amount, count(*) FROM jan08 WHERE trip_distance = 1.3 AND total_amount = 8.5 AND trip_time_in_secs <> 379 GROUP BY tip_amount"
  },
  { db => "taxi",
    answer => "0.5",
    sqlWith => "SELECT surcharge, count(*) FROM jan08 WHERE vendor_id = 'CMT' AND payment_type = 'CRD' GROUP BY surcharge",
    sqlWithout => "SELECT surcharge, count(*) FROM jan08 WHERE vendor_id = 'CMT' AND payment_type = 'CRD' AND tip_amount <> 10.54 GROUP BY surcharge"
  },
  { db => "taxi",
    answer => "0",
    sqlWith => "SELECT surcharge, count(*) FROM jan08 WHERE vendor_id = 'CMT' AND tip_amount = 0 AND trip_time_in_secs = 235 GROUP BY surcharge",
    sqlWithout => "SELECT surcharge, count(*) FROM jan08 WHERE vendor_id = 'CMT' AND tip_amount = 0 AND trip_time_in_secs = 235 AND rate_code <> 4 GROUP BY surcharge"
  },
  { db => "taxi",
    answer => "10.5",
    sqlWith => "SELECT total_amount, count(*) FROM jan08 WHERE vendor_id = 'VTS' AND tip_amount = 1 AND trip_time_in_secs = 600 AND surcharge = 0.5 GROUP BY total_amount",
    sqlWithout => "SELECT total_amount, count(*) FROM jan08 WHERE vendor_id = 'VTS' AND tip_amount = 1 AND trip_time_in_secs = 600 AND surcharge = 0.5 AND trip_distance <> 1.56 GROUP BY total_amount"
  },
  { db => "taxi",
    answer => "13.5",
    sqlWith => "SELECT total_amount, count(*) FROM jan08 WHERE vendor_id = 'VTS' AND tip_amount = 1 AND trip_time_in_secs = 960 AND surcharge = 0 AND rate_code = 1 GROUP BY total_amount",
    sqlWithout => "SELECT total_amount, count(*) FROM jan08 WHERE vendor_id = 'VTS' AND tip_amount = 1 AND trip_time_in_secs = 960 AND surcharge = 0 AND rate_code = 1 AND trip_distance <> 2.01 GROUP BY total_amount"
  },
  { db => "taxi",
    answer => "0.5",
    sqlWith => "SELECT mta_tax, count(*) FROM jan08 WHERE vendor_id = 'VTS' AND tip_amount = 0 AND trip_time_in_secs = 0 AND surcharge = 0 AND rate_code = 5 AND trip_distance = 0 GROUP BY mta_tax",
    sqlWithout => "SELECT mta_tax, count(*) FROM jan08 WHERE vendor_id = 'VTS' AND tip_amount = 0 AND trip_time_in_secs = 0 AND surcharge = 0 AND rate_code = 5 AND trip_distance = 0 AND total_amount <> 70.5 GROUP BY mta_tax"
  }
];

sub getTests {
  return $tests;
}

1;
