use strict;
use Math::Random qw(random_uniform_integer);
use Data::Dumper;
use Storable qw(dclone);
use Math::Random qw(random_permutation);
use Scalar::Util qw(looks_like_number);
use lib '../../diffixAttackModules';
use diffixAttackConfig::dbConfig qw( getDatabaseConfig );
use diffixAttackUtilities::connectAir qw( getColumnsFromAir );
use diffixAttackUtilities::databaseRoutines qw( svConnect queryDatabaseRaw );
use diffixAttackUtilities::results qw( openRes );
use diffixAttackUtilities::getCombs qw( getBaseAndNonBaseFromMask getNextMask getBitMask );

# 1. Get the table columns.
# 2. Loop through combinations of columns, where be have "base" columns
#    and "isolating" column.  What we want is, for a given set of base
#    values, find a case in the isolating column where one user can be
#    isolate either with a '<>' or an '='.  For both cases, we need a
#    user who has a distinct value in the isolating column.  Note that
#    any of the base columns can also be an unknown column.  This is
#    what we want to learn about the victim.  There has to be I'd say at
#    least 10 users in the group defined by the base columns and the
#    isolating column.
# 
# How does this loop work?
# 1.  The combinations of columns can be 1 col, 2 cols, etc.  We can
#     query the raw database but require a count of 10.  We can stop
#     after getting some number of attackable scenarios (100 or so).
# 2.  For each base group, we check to see if there is a singleton
#     in the isolating col.  To do this, we can just insert the values into
#     assoc array, one for each column, and then afterwards walk
#     through the arrays and see if there are singletons.  Ok, that's easy.
# 3.  To do this, we can order by the base group columns and walk through
#     the resulting array.
# 


# In the following, we remove columns that are problematic for whatever
# reason (i.e. inconsistent handling of reals between air and raw or
# empty fields)

my $tests = [
  { db => "banking",
    table => "cards",
    exclude => ["client_id"],
    text => ["card_type", "issues", "disp_type", "birth_number", "lastname"],
    uid => "client_id"
  },
  { db => "banking",
    table => "accounts",
    exclude => ["client_id"],
    text => ["frequency", "disp_type", "birth_number", "lastname"],
    uid => "client_id"
  },
  { db => "banking",
    table => "transactions",
    exclude => ["client_id", "account"],
    text => ["trans_date", "operation", "k_symbol", "bank", "account",
             "frequency", "disp_type", "birth_number", "lastname"],
    uid => "client_id"
  },
  { db => "scihub",
    table => "sep2015",
    exclude => ["uid", "long", "lat"],
    text => ["doc", "country", "city", "lastname"],
    uid => "uid"
  },
  { db => "census0",
    table => "uidperhousehold",
    exclude => ["uid"],
    text => ["lastname"],
    uid => "uid"
  },
  { db => "taxi",
    table => "jan08",
    exclude => ["hack", "dropoff_longitude", "dropoff_latitude",
                "pickup_longitude", "pickup_latitude"],
    text => ["med", "vendor_id", "sf_flag", "pickup_datetime",
             "dropoff_datetime", "payment_type", "lastname", "lastname"],
    uid => "hack"
  },
];

my $onlyGetEqualityAttacks = 0;
my $attacksPerDb = 30;
# a couple constants
my $ISBASE = 1;
my $NOTBASE = 0;

my $run->{testName} = "Get Potential Diff Attacks";
$run->{resultsFile} = "results/getPotentialDiffAttacks.txt";
$run->{print} = $ARGV[0];
my $p = 0;
$p = $run->{print};

foreach my $test (@{ $tests }) {
  $run->{table} = $test->{table};
  $run->{db} = $test->{db};
  $run->{uid} = $test->{uid};
  $run->{text} = $test->{text};
  openRes($run);
  my($cols, $ignore) = getColumnsFromAir($run);
  if ($p) { print "@{$cols}\n"; }
  foreach (@{ $test->{exclude} }) {
    $cols = removeCol($cols, $_);
  }
  my @cols = random_permutation(@{$cols});
  # lets limit this to say 10 columns.  That should be enough to find attacks.
  while ($#cols > 9) {
    pop @cols;
  }
  if ($p) { print "@{$cols}\n"; }
  my $cols = \@cols;
  $run->{sql} = buildQueryFromColumns($cols, $run->{table}, $run->{uid});
  my $db = getDatabaseConfig($run->{db});
  my $dbh = svConnect($db);
  my ($rowsRaw, $elapsedRaw) = queryDatabaseRaw($dbh, $run->{sql});
  # ok, now I have the whole database with the uid column as last column
  # I'm going to loop through a bunch of base cases.

  my $numCases = 0;
  $run->{colNames} = $cols;
  $run->{testedKeys} = 0;
  $run->{testedUids} = 0;
  $run->{testedUnknown} = 0;
  $run->{testedDistinct} = 0;
  $run->{foundAttacks} = 0;
  for (my $bgs = 1; $bgs <= $#cols; $bgs++) {
    # this loop increases the number of columns in the "base" group
    # bgs = "base group size"
    my $bitmask = getBitMask($bgs);
    while (1) {
      (my $base, my $nonbase) = getBaseAndNonBaseFromMask($bitmask, @cols);
      $run->{base} = $base;
      $run->{nonbase} = $nonbase;
      $run = buildDiffAttacks($run, $rowsRaw, 1);
      if ($p) { print "@{$base}\n"; }
      $bitmask = getNextMask($bgs, $bitmask, $#cols + 1);
      last if (!defined $bitmask);
      last if (++$numCases > $attacksPerDb);
    }
  }
}
print "\nTested: Keys $run->{testedKeys}, Uids $run->{testedUid}, unknown $run->{testedUnknown}, distinct $run->{testedDistinct}\n";
print "Found: $run->{foundAttacks}\n";

sub buildDiffAttacks {
my($run, $res, $numAttacks) = @_;
  # we are going to build a structure indexed by a string composed
  # of the column values from the base columns.  It looks like this:
  # $s->{k}->{'baseStr'}->{b}->[$i]->[$j] = value
  # $s->{k}->{'baseStr'}->{n}->[$i]->[$j] = value
  # $s->{k}->{'baseStr'}->{u}->[$j] = value
  # $s->{k}->{'baseStr'}->{num} = numRows
  # $s->{bName}->[$i] = colName;
  # $s->{nName}->[$i] = colName;
  # 'baseStr' is the string build from the base column values ($bs)
  # n and b are barewords for "nonbase" and "base" respectively
  # u is bareword for "uid"
  # $i is the column index (use @bi and @nbi for mapping the db
  #       column indexes into the base and nonbase column indices)
  # $j is the row index for the given base string

  my @names = @{ $run->{colNames} };
  # @bi is an array with the column indexes for the base columns
  my @bi = @{ $run->{base} };
  # @nbi is an array with the indexes for the other (non-base) columns
  my @nbi = @{ $run->{nonbase} };
  # we use @bi and @nbi to find the indexes to the db rows
  my @btype = ();
  foreach (@bi) {
    @btype[$_] = $ISBASE;
  }
  foreach (@nbi) {
    @btype[$_] = $NOTBASE;
  }
  my $s = undef;    # this is our structure, lets start building!
  my @baseColNames = ();
  # populate column names
  if ($p) { print "\n\nBase:\n"; }
  for (my $i = 0; $i <= $#bi; $i++) {
    $s->{bName}->[$i] = $names[$bi[$i]];
    push @baseColNames, $names[$bi[$i]];
    if ($p) { print "    $names[$bi[$i]]\n"; }
  }
  $run->{baseColNames} = \@baseColNames;
  if ($p) { print "\n\nNon-Base:\n"; }
  for (my $i = 0; $i <= $#nbi; $i++) {
    $s->{nName}->[$i] = $names[$nbi[$i]];
    if ($p) { print "    $names[$nbi[$i]]\n"; }
  }
  if ($p) { print "\n\n"; }

  my @rowsRaw = @{ $res->{query}->{rows} };

  foreach my $row (@rowsRaw) {
    # we want to make a key ...
    my $key = makeKeyFromBase($row, \@btype);
    my $j;
    if (exists $s->{k}->{$key}) {
      $j = $s->{k}->{$key}->{num} + 1;
      $s->{k}->{$key}->{num} = $j;
    }
    else {
      # initialize entry
      $s->{k}->{$key}->{num} = 0;
      $j = 0;
    }
    my $bii = 0;
    my $nbii = 0;
    for (my $i = 0; $i <= $#btype; $i++) {
      if ($btype[$i] == $NOTBASE) {
        $s->{k}->{$key}->{n}->[$nbii]->[$j] = $row->{row}->[$i];
        $nbii++;
      }
      else {
        $s->{k}->{$key}->{b}->[$bii]->[$j] = $row->{row}->[$i];
        $bii++;
      }
      # add the uid column
      $s->{k}->{$key}->{u}->[$j] = $row->{row}->[($#btype+1)];
    }
  }

  # now we have a structure, we want to first find out if there are any
  # base groups that have, say, 100 or more rows.  Anything with less
  # is likely not a good candidate for finding an attack.
  foreach my $key (keys %{ $s->{k} }) {
    $run->{testedKeys}++;
    next if ($s->{k}->{$key}->{num} < 100);
    # now we are going to determine if there are enough unique uids
    # for this base group.  We want at least 15.
    my %uids = ();
    my $uidCount = 0;
    my @uuids = @{ $s->{k}->{$key}->{u} };
    for (my $j = 0; $j <= $#uuids; $j++) {
      if (exists $uids{$uuids[$j]}) {
        $uids{$uuids[$j]}++;
      }
      else {
        $uids{$uuids[$j]} = 1;
        last if (++$uidCount >= 15);  # good enough, we can quit looking
      }
    }
    $run->{testedUids}++;
    next if ($uidCount < 15);

    # now determine if there are isolatable users using any of the non-base
    # columns (meaning, we can remove that user with 'col <> val').
    for (my $i = 0; $i < $#nbi; $i++) {      # for each non-base column
      # initialize an assoc array to hold the values
      $run->{isolateColName} = $names[$nbi[$i]];
      my %vals = ();
      my %valsRow = ();
      my @uvals = @{ $s->{k}->{$key}->{n}->[$i] };
      for (my $j = 0; $j <= $#uvals; $j++) {
        if (exists $vals{$uvals[$j]}) {
          $vals{$uvals[$j]}++;
        }
        else {
          $vals{$uvals[$j]} = 1;
          $valsRow{$uvals[$j]} = $j;
        }
      }
      # now see how many of the values are unique.  check for the
      # special case where there are only two distinct values, and
      # one of them is unique ($twoDistinctVals)
      my @keys = (keys %vals);
      next if ($#keys == 0);
      $run->{twoDistinctVals} = 0;
      if ($#keys == 1) { $run->{twoDistinctVals} = 1; }
      next if (($run->{twoDistinctVals} == 0) && ($onlyGetEqualityAttacks));
      for (my $k = 0; $k <= $#keys; $k++) {
        $run->{testedDistinct}++;
        my $vkey = $keys[$k];
        next if ($vals{$vkey} != 1);
        # We have a singleton with $run->{isolateColName} ($i) as the isolating
        # column at row index $valsRow{$vkey}.
        # Now we need to determine whether there is another
        # non-base column that has enough users with the same value
        # as the victim (in that non-base column).  This requires
        # another loop through the data for this key
        if ($p) { print "singleton col $run->{isolateColName}, value $vkey\n"; }
        my $victimRow = $valsRow{$vkey};
        my @valsCount = ();
        my @totalCount = ();
        my @victimNVals = ();
        for (0..$#nbi) { 
          @valsCount[$_] = 0; 
          @totalCount[$_] = 0; 
          $victimNVals[$_] = $s->{k}->{$key}->{n}->[$_]->[$victimRow];
        }
        if ($p) { print "Victim's non-base values: @victimNVals\n"; }
        # this is for later making the SQL
        my @victimBVals = ();
        for (0..$#bi) { 
          $victimBVals[$_] = $s->{k}->{$key}->{b}->[$_]->[$victimRow];
        }
        for (my $i1 = 0; $i1 < $#nbi; $i1++) {
          next if ($i == $i1);       # $i is the isolating column
          if ($p) { print "Try col $i1 ($names[$nbi[$i1]]), val $victimNVals[$i1]\n"; }
          my @uvals1 = @{ $s->{k}->{$key}->{n}->[$i] };
          for (my $j1 = 0; $j1 <= $#uvals1; $j1++) {
            next if ($j1 == $victimRow);
            $totalCount[$i1]++;
            if ($s->{k}->{$key}->{n}->[$i1]->[$j1] eq $victimNVals[$i1]) {
              $valsCount[$i1]++;
              if ($p) { print "     row $j1 match ($valsCount[$i1])\n"; }
            }
          }
        }
        # ok, we counted the matching values, let's see if any are big
        # enough
        for (my $i1 = 0; $i1 < $#nbi; $i1++) {
          $run->{testedUnknown}++;
          next if ($valsCount[$i1] < 10);
          # this next line to avoid cases where pretty much everyone
          # has the same "unknown" value
          next if (($run->{twoDistinctVals} == 0) &&
                   (($valsCount[$i1] / $totalCount[$i1]) > 0.5));
          # ok, we have a difference attack!
          $run->{foundAttacks}++;
          $run->{unknownColName} = $names[$nbi[$i1]];
          $run->{unknownColVal} = $victimNVals[$i1];
          $run->{isolateVal} = $vkey;
          $run->{baseVals} = \@victimBVals;
          if ($p) { print "isolator $run->{isolateColName} = $run->{isolateVal}\n"; }
          if ($p) { print "     base @{$s->{bName}} = $key\n"; }
          if ($p) { print "     baseVals @victimBVals\n"; }
          if ($p) { print "     unknown $run->{unknownColName} = $victimNVals[$i1]\n\n"; }
          makeSQL($run);
          if (--$numAttacks <= 0) {
            return $run;
          }
        }
      }
    }
  }
  return $run;
}

sub makeSQL {
my($run) = @_;
  my @bn = @{ $run->{baseColNames} };
  my @bv = @{ $run->{baseVals} };
  my $ukn = $run->{unknownColName};
  my $ison = $run->{isolateColName};
  my $isov = $run->{isolateVal};
  my $tab = $run->{table};
  # make WHERE conditions (with and without isolator)
  my $whereWith = '';
  for (my $i = 0; $i <= $#bn; $i++) {
    if (colIsText($run, $bn[$i])) {
      $whereWith .= "$bn[$i] = '$bv[$i]'";
    }
    else {
      $whereWith .= "$bn[$i] = $bv[$i]";
    }
    if ($i != $#bn) {
      $whereWith .= " AND ";
    }
  }
  my $whereWithout = $whereWith." AND $ison <> '$isov'";
  if ($run->{twoDistinctVals}) {
    # in this special case, we can run the attack using '=' instead of
    # '<>'.
    print "Got equality case!\n";
  }
  # note that the following is incorrect if we have an equality case.
  # as it stands, you'll need to tweak these by hand in that case
  print "  { db => \"$run->{db}\",\n";
  print "    answer => \"$run->{unknownColVal}\",\n";
  print "    sqlWith => \"SELECT $ukn, count(*) FROM $tab WHERE $whereWith GROUP BY $ukn\",\n";
  print "    sqlWithout => \"SELECT $ukn, count(*) FROM $tab WHERE $whereWithout GROUP BY $ukn\"\n  },\n";
}

sub makeKeyFromBase {
my($row, $btype) = @_;
  my $key = '';
  my $str = '';
  my @btype = @{ $btype };
  for (my $i = 0; $i <= $#btype; $i++) {
    next if ($btype[$i] == $NOTBASE);
    my $val = $row->{row}->[$i];
    if (looks_like_number($val)) {
      if ($val - int($val)) {
        # This truncates reals to 3 digits, because postgres reals sometimes
        # keeps only that much (but in fact this is an unreliable way to
        # try to compare cloak output with postgres output for reals, so
        # be careful when trying to attack real columns).
        $str = sprintf "%0.3f", $val;
      }
      else {
        $str = sprintf "%d", $val;
      }
      # the raw database can return a fractional part with trailing
      # zeros, while the cloak may not, so we simply force a bunch of
      # zeros (even if the number is an 
      $key .= ":".$str;
    }
    else { $key .= ":".$val; }
  }
  return $key;
}

sub buildQueryFromColumns {
my($cols, $table, $uid) = @_;
  my $sql = "SELECT ";
  my @cols = @{ $cols };
  my $i;
  for ($i = 0; $i <= $#cols; $i++) {
    $sql .= "$cols[$i], ";
  }
  $sql .= "$uid FROM $table";
  return $sql;
}

sub removeCol {
my($cols, $uid) = @_;
  my @colsArray = ();
  foreach my $col (@{ $cols }) {
    if ($col ne $uid) {
      push @colsArray, $col;
    }
  }
  return \@colsArray;
}

sub colIsText {
my($run, $col) = @_;
  foreach my $name (@{ $run->{text} }) {
    if ($name eq $col) { return 1; }
  }
  return 0;
}
