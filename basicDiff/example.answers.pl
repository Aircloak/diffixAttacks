use strict;

my $answers = [
  {
    db => "banking",
    table => "transactions",
    baseVals => [1, 3744],
    baseTypes => ["numeric", "numeric"],
    baseCols => ["cli_district_id", "amount"],
    isolateVal => "951009",
    answer => "315210",
    attack => "negDiff",
    isolateCol => "trans_date",
    unknownColType => "text",
    isolateType => "text",
    statProb => 0.000262944262944263,
    maxGuessGap => -1,
    answer => "315210",
    unknownCol => "birth_number",
    guess => "noguess",
    elapsed => 1.544393,
    sig => "9RyrSqz+ykMMuydaT3LvCQ",
    numBaseRows => 63,
  },
  {
    db => "banking",
    table => "transactions",
    baseVals => ["POPLATEK MESICNE", 6340],
    baseTypes => ["text", "numeric"],
    baseCols => ["frequency", "amount"],
    isolateVal => "980701",
    answer => "OWNER",
    attack => "negDiff",
    isolateCol => "trans_date",
    unknownColType => "text",
    isolateType => "text",
    statProb => 0.836606276606277,
    maxGuessGap => -1,
    answer => "OWNER",
    unknownCol => "disp_type",
    guess => "noguess",
    elapsed => 1.48077,
    sig => "kT/i6FISVtu8CvzF01Tmnw",
    numBaseRows => 114,
  },
];

sub getAnswers{return $answers;}

1;
