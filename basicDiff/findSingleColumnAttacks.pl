use strict;
use Data::Dumper;
use lib '../../diffixAttackModules';
use diffixAttackConfig::dbConfig qw( getDatabaseConfig );
use diffixAttackUtilities::databaseRoutines qw( svConnect queryDatabaseRaw );

# This attack assumes that the attacker knows that a given column has
# a distinct value per user. This column is the `knownCol` entry in
# the attack configuration `$attackCol`. 
#
# This program produces an output file for each entry in `$attackCol`.
# These output files may then be used to run attacks using
# `runAttackQueries.pl`
#
# Each attack in the output file has a single negative condition for the
# query that excludes the user, and no negative condition for the query
# that conditionally includes the user. The `SELECT` requests a count
# of all values in the `unknownCol`.
#
# The `maxPairs` value determines the number of attack pairs that are
# produced by this program.
#
# This program queries the raw database, not the cloak.

$| = 1;

# ---------------- config ----------------------

my $p = 0;		# print debug info or not
my $runTest = 0;

# here are the columns to attack:
my $attackColTest = [
  { db => "banking",
    table => "cards",
    knownCol => "card_id",
    knownColType => "numeric",
    unknownCol => "card_type",		# 3 distinct types
    unknownColType => "text",
    maxPairs => 50
  },
];
my $attackCol = [
  { db => "banking",
    table => "cards",
    knownCol => "card_id",
    knownColType => "numeric",
    unknownCol => "card_type",		# 3 distinct types
    unknownColType => "text",
    maxPairs => 600
  },
  { db => "banking",
    table => "disp",
    knownCol => "disp_id",
    knownColType => "numeric",
    unknownCol => "type",
    unknownColType => "text",
    maxPairs => 600
  },
  { db => "banking",
    table => "accounts",
    knownCol => "client_id",
    knownColType => "numeric",
    unknownCol => "acct_district_id",	# 77 distinct types
    unknownColType => "numeric",
    maxPairs => 600
  },
  { db => "census1",
    table => "uidperperson",
    knownCol => "uid",
    knownColType => "numeric",
    unknownCol => "pernum",	# 20 distinct types
    unknownColType => "numeric",
    maxPairs => 600
  },
  { db => "census1",
    table => "uidperperson",
    knownCol => "uid",
    knownColType => "numeric",
    unknownCol => "hinsemp",	# 2 distinct types, one with 54%
    unknownColType => "numeric",
    maxPairs => 600
  },
  { db => "census1",
    table => "uidperperson",
    knownCol => "uid",
    knownColType => "numeric",
    unknownCol => "race",	# 9 distinct types, one with 77%
    unknownColType => "numeric",
    maxPairs => 600
  },
  { db => "census1",
    table => "uidperperson",
    knownCol => "uid",
    knownColType => "numeric",
    unknownCol => "gq",		# 5 distinct types, one with 95%
    unknownColType => "numeric",
    maxPairs => 600
  },
];

# ---------------- end config ----------------------


my $attacks = $attackCol;
if ($runTest) { $attacks = $attackColTest; }

foreach my $att (@{ $attacks }) {
  makeQueries($att);
}

sub makeQueries {
my($att) = @_;
  my $fname = $att->{db}.'.'.$att->{table}.'.'.$att->{unknownCol}.'.'.$att->{knownCol}.'.singleCol.queries.pl';
  if ($runTest) {
    $fname = $att->{db}.'.'.$att->{table}.'.'.$att->{unknownCol}.'.'.$att->{knownCol}.'.singleCol.test.pl';
  }
  open(my $ofh, ">", $fname) or die "Open failed: $fname";

  # start by querying the raw database to get the known information
  my $sql = "SELECT $att->{knownCol}, $att->{unknownCol} FROM $att->{table} LIMIT $att->{maxPairs}";
  my $db = getDatabaseConfig($att->{db});
  my $dbh = svConnect($db);
  my ($rows, $elapsedRaw) = queryDatabaseRaw($dbh, $sql);
  if ($p) { print "Known Values\n"; print Dumper $rows; }
  
  # $rows contains each isolating value. Now we can loop through and
  # execute the difference attacks
  
  # Make an assoc array to hold the results
  my $totalQueries = 0;
  my $totalRows = 0;
  # And one to use later to compute confidence improvement
  my %statGuess = ();
  my $sql = "SELECT $att->{unknownCol}, count(*) FROM $att->{table} GROUP BY 1";
  my ($temp, $elapsedRaw) = queryDatabaseRaw($dbh, $sql);
  foreach (@{ $temp->{query}->{rows} }) {
    my $val = $_->{row}->[0];
    $statGuess{$val} = $_->{row}->[1];
    $totalRows += $_->{row}->[1];
  }
  my %statProb = ();
  foreach my $val (keys %statGuess) {
    $statProb{$val} = $statGuess{$val} / $totalRows;
  }
  
  print $ofh "use strict;\n\n";
  print $ofh "my \$queries = [\n";
  foreach (@{ $rows->{query}->{rows} }) {
    print $ofh "  { db => \"$att->{db}\",\n";
    print $ofh "    table => \"$att->{table}\",\n";
    print $ofh "    unknownCol => \"$att->{unknownCol}\",\n";
    if ($att->{unknownColType} eq "text") {
      print $ofh "    answer => \"$_->{row}->[1]\",\n";
    }
    else {
      print $ofh "    answer => $_->{row}->[1],\n";
    }
    print $ofh "    unknownColType => \"$att->{unknownColType}\",\n";
    if ($att->{knownColType} eq "text") {
      print $ofh "    isolateVal => \"$_->{row}->[0]\",\n";
    }
    else {
      print $ofh "    isolateVal => $_->{row}->[0],\n";
    }
    print $ofh "    isolateCol => \"$att->{knownCol}\",\n";
    print $ofh "    isolateType => \"$att->{knownColType}\",\n";
    print $ofh "    attack => \"negDiff\",\n";
    print $ofh "    statProb => $statProb{$_->{row}->[1]},\n";
    print $ofh "    baseCols => [],\n";
    print $ofh "    baseVals => [],\n";
    print $ofh "    baseTypes => [],\n";
    print $ofh "},\n";
  }
  print $ofh "];\n\n";
  print $ofh "sub getQueries { return \$queries; }\n\n1;\n";
  close($ofh);
}
