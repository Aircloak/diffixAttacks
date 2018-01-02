use strict;

my $queries = [
  { db => "taxi",
    table => "jan08",
    unknownCol => "med",
    unknownColType => "text",
    answer => "84F313D324DE749703136FA0DB8C04EB",
    attack => "negDiff",
    isolateCol => "trip_time_in_secs",
    isolateType => "numeric",
    isolateVal => 696,
    statProb => 0.000140826835234874,
    baseCols => ["vendor_id", "trip_distance", "payment_type", "lastname", "sf_flag"],
    baseVals => ["CMT", 0, "CRD", "Nakamoto", "N"],
    baseTypes => ["text", "numeric", "text", "text", "text"],
    numBaseRows => 14,
    sqlWith => "SELECT med, count(*) FROM jan08 WHERE vendor_id = 'CMT' AND trip_distance = 0 AND payment_type = 'CRD' AND lastname = 'Nakamoto' AND sf_flag = 'N' GROUP BY med",
    sqlWithout => "SELECT med, count(*) FROM jan08 WHERE vendor_id = 'CMT' AND trip_distance = 0 AND payment_type = 'CRD' AND lastname = 'Nakamoto' AND sf_flag = 'N' AND trip_time_in_secs <> 696 GROUP BY med"
  },
  { db => "taxi",
    table => "jan08",
    unknownCol => "med",
    unknownColType => "text",
    answer => "84F313D324DE749703136FA0DB8C04EB",
    attack => "negDiff",
    isolateCol => "trip_time_in_secs",
    isolateType => "numeric",
    isolateVal => 558,
    statProb => 0.000140826835234874,
    baseCols => ["vendor_id", "trip_distance", "payment_type", "lastname", "sf_flag"],
    baseVals => ["CMT", 0, "CRD", "Nakamoto", "N"],
    baseTypes => ["text", "numeric", "text", "text", "text"],
    numBaseRows => 14,
    sqlWith => "SELECT med, count(*) FROM jan08 WHERE vendor_id = 'CMT' AND trip_distance = 0 AND payment_type = 'CRD' AND lastname = 'Nakamoto' AND sf_flag = 'N' GROUP BY med",
    sqlWithout => "SELECT med, count(*) FROM jan08 WHERE vendor_id = 'CMT' AND trip_distance = 0 AND payment_type = 'CRD' AND lastname = 'Nakamoto' AND sf_flag = 'N' AND trip_time_in_secs <> 558 GROUP BY med"
  },
];

sub getQueries { return $queries; }

1;
