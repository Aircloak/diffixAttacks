use strict;
use Math::Round;
use Data::Dumper;
use Time::HiRes qw( usleep gettimeofday tv_interval );
use lib '../../diffixAttackModules';
use diffixAttackConfig::dbConfig qw( getDatabaseConfig );
use diffixAttackUtilities::bounties qw( getScore printScore );
use diffixAttackUtilities::connectAir qw( queryDatabaseAirQ getQueryResult );
use diffixAttackUtilities::databaseRoutines qw( svConnect queryDatabaseRaw );
use diffixAttackUtilities::processAnswers qw( getHashesFromAnswers1 getQuerySignature );

# This program takes as input a file containing difference attack queries,
# runs the attacks on the cloak, and produces as output a file indicating
# the outcome of each attack. An example of the input file can be found
# at `example.queries.pl`.
#
# To run:
# `perl runAttackQueries.pl queries.pl answers.pl
#
# where `queries.pl` is the file containing the queries. The output file
# produced by this command is named `answers.pl.temp.txt`.
#
# Depending on the number of attacks, it can take a long time for this
# program to run, and of course the program may fail without completing
# all the attacks. To avoid running the attacks over again, this program
# assumes that answers that have already been produced in prior runs are
# in the file `answers.pl`. An example of this file can be found at
# `example.answers.pl`. If there is no `answers.pl` file, then this program
# will create one that contains the needed perl structures but contains
# no answers. If there is an `answers.pl` file, then this program reads
# that file, and checks each existing answer to ensure that the attack is
# not repeated.
#
# In any event, the output of this program is `answers.pl.temp.txt`, which
# contains the answers produced in this run. If the program terminates
# before finishing all the attacks, then the `answers.pl` file must be
# edited by hand to incorporate the answers in `answers.pl.temp.txt`, and
# then the `answers.pl.temp.txt` file should be deleted. (Note it would not
# be hard to make a program that does this automatically, but we haven't
# bothered to do that.)
# 

$| = 1;

# ---------------- config ----------------------

my $p = 0;		# print debug info or not
my $parallel = 8;	# max number parallel queries
my $maxGap = 16;

# ---------------- end config ----------------------

my $startTV = [ gettimeofday ];
my $averageElapsed = 0;
my $numElapsed = 0;

# constants for query state. Must be negative.
my $notStarted = -1;
my $finished = -2;

die "Must supply query and answer files in command line" if ($#ARGV < 1);
my $queryFile = $ARGV[0];
require $queryFile;

my $answerFile = $ARGV[1];
my %signatures = ();
if (open(my $temp, "<", $answerFile)) {
  require $answerFile;
  # record prior answers in a array, if any
  my $answers = getAnswers();
  foreach (@{ $answers }) {
    $signatures{$_->{sig}} = 1;
  }
}
else {
  # setup basic answer file "shell" as a courtesy
  open(my $temp, ">", $answerFile);
  print $temp "use strict;\n\nmy \$answers = [\n];\n\nsub getAnswers{return \$answers;}\n\n1;\n";
  close $temp;
}
print "%signatures\n";
my $outputFile = $answerFile.".temp.txt";
open(my $ofh, ">>", $outputFile) or die "Open failed: $outputFile";

print $ofh "use strict;\n\nmy \$answers = [\n";

#zzzz need to make assoc array from answer file

my $airIndex = 0;

# set up the data structure for the ongoing queries. This is simply
# an array of indexes into @qList
my $queries = getQueries();
my @qList = @{ $queries };
foreach my $q (@qList) {
  $q->{qidWith} = $notStarted;
  $q->{qidWithout} = $notStarted;
  $q->{refWith} = 0;
  $q->{refWithout} = 0;
  $q->{startTVWith} = 0;
  $q->{startTVWithout} = 0;
}
my @ongoingQueries = ();
my $numOngoingPairs = int($parallel/2);
foreach (0..($numOngoingPairs-1)) {
  $ongoingQueries[$_] = $notStarted;
}

# at most poll each query four times per second
my $delayInc = int(250000/$parallel);
my $delay = $delayInc;
while(1) {
  my $madeProgress = 0;
  # first check to see if any pairs of queries have finished. If so,
  # process and tally the results
  foreach (0..($numOngoingPairs-1)) {
    my $qi = $ongoingQueries[$_];
    next if ($qi == $notStarted);
    my $q = $qList[$qi];
    if ($p) { print "Check result of queries $_:$qi, with qids $q->{qidWith}, $q->{qidWithout}\n"; }
    if ($q->{qidWith} != $finished) {
      my $rowsWith = getQueryResult($q->{qidWith});
      if ($rowsWith->{query}->{query_state} eq "completed") {
        if ($p) { print Dumper $rowsWith; }
        $madeProgress = 1;
        my $refWith = getHashesFromAnswers1($rowsWith);
        $q->{refWith} = $refWith;
        if ($p) { print Dumper $q->{refWith}; }
        $q->{qidWith} = $finished;
        my $newTV = [ gettimeofday ];
        $q->{elapsed} = tv_interval($q->{startTVWith}, $newTV);
        $numElapsed++; $averageElapsed += $q->{elapsed};
        my $elapsedAll = tv_interval($startTV, $newTV);
        if ($p) { print "$qi 'with' finished with Elapsed time $q->{elapsed} ($elapsedAll)\n"; }
      }
    }
    if ($q->{qidWithout} != $finished) {
      my $rowsWithout = getQueryResult($q->{qidWithout});
      if ($rowsWithout->{query}->{query_state} eq "completed") {
        if ($p) { print Dumper $rowsWithout; }
        $madeProgress = 1;
        my $refWithout = getHashesFromAnswers1($rowsWithout);
        $q->{refWithout} = $refWithout;
        if ($p) { print Dumper $q->{refWithout}; }
        $q->{qidWithout} = $finished;
        my $newTV = [ gettimeofday ];
        $q->{elapsed} = tv_interval($q->{startTVWithout}, $newTV);
        $numElapsed++; $averageElapsed += $q->{elapsed};
        my $elapsedAll = tv_interval($startTV, $newTV);
        if ($p) { print "$qi 'without' finished with Elapsed time $q->{elapsed} ($elapsedAll)\n"; }
      }
    }
    if (($q->{qidWith} == $finished) && ($q->{qidWithout} == $finished)) {
      if ($p) { print "Both queries finished, so process\n"; }
      # both queries have completed, so update the data structures and
      # tally the results
      $ongoingQueries[$_] = $notStarted;
      my %arrayWithout = %{ $q->{refWithout} };
      my %arrayWith = %{ $q->{refWith} };
      # whichever bucket includes the victim is statistically most likely to
      # be larger than the paired bucket that excludes the victim. So we
      # walk through and find the pair with the greatest distance, and this
      # is our guess. Furthermore, if the max is greater than the next
      # biggest difference by 2, then it is even more likely to be the
      # victim, so we check for that as well (and 3 etc.)

      # put the values into an array so that we can reference them by index
      my @valsArray = getValsFromAnswers($q);
      if ($p) { print "valsArray: @valsArray\n"; }
      $q->{maxGuessGap} = -1;
      $q->{guess} = "noguess";
      foreach my $gap (0..$maxGap) {
        # We start by selecting the first two entries, and seeing if
        # they exceed the gap threshold. If they don't, then we set
        # $totalMax to 2 to indicate that there is not a single max
        # with a large enough gap
        my $val = $valsArray[0];
        my $max = $arrayWith{$val} - $arrayWithout{$val};
        my $guess = $val;

        if ($#valsArray >= 1) {
          $val = $valsArray[1];
          my $diff = $arrayWith{$val} - $arrayWithout{$val};
          my $totalMax = 1;
          if (abs($max - $diff) <= $gap) {
            # not enough difference between the first 2 buckets, so initialize
            # as multiple maxes
            $totalMax = 2;
            if ($diff > $max) {
              # nevertheless record the max
              $max = $diff;
              $guess = $val;
            }
          }
          elsif ($diff > ($max + $gap)) {
            $max = $diff;
            $guess = $val;
            $totalMax = 1;
          }
          # now check the remaining buckets
          for (my $i = 2; $i <= $#valsArray; $i++) {
            my $val = $valsArray[$i];
            my $diff = $arrayWith{$val} - $arrayWithout{$val};
            if ($p) { print "Try $val with diff $diff ($arrayWith{$val}, $arrayWithout{$val})\n"; }
            if (($diff >= $max) && ($diff <= ($max + $gap))) {
              $totalMax++;
            }
            elsif ($diff > ($max + $gap)) {
              $max = $diff;
              $guess = $val;
              $totalMax = 1;
            }
          }
          if ($totalMax > 1) {
            if ($p) { print "No Guess ($totalMax)\n"; }
          }
          else {
            if ($p) { print "Guess is $guess, answer is $q->{answer}\n"; }
            $q->{maxGuessGap} = $gap;
            if ($guess eq $q->{answer}) {
              die "unexpected answer right" if ($q->{guess} eq "wrong");
              $q->{guess} = "right";
            }
            else {
              die "unexpected answer wrong" if ($q->{guess} eq "right");
              $q->{guess} = "wrong";
            }
          }
        }
      }
      printAnswer($ofh, $q);
    }
    # smooth out the rate of queries
    if ($madeProgress) { $delay = $delayInc; }
    else {$delay += $delayInc; }
    usleep $delay;
  }
  # next see if we can start any parallel query pairs
  foreach (0..($numOngoingPairs-1)) {
    my $qi = $ongoingQueries[$_];
    if ($p) { print "Check to start more queries at $_,$qi\n"; }
    # first move past any queries that have already been answered
    while(1) {
      last if ($airIndex > $#qList);
      my $q = $qList[$airIndex];
      my $sig = getQuerySignature($q);
      if (exists $signatures{$sig}) { 
        print "Skip query with signature $sig ($airIndex)\n";
        $airIndex++; 
      }
      elsif ($q->{attack} eq "posDiff") {
        print "Skip query with attack posDiff ($airIndex)\n";
        $airIndex++; 
      }
      else { last; }
    }
    if (($qi == $notStarted) && ($airIndex <= $#qList)) {
      if ($p) { print "Start query pair\n"; }
      # ok, lets start a query pair here
      my $q = $qList[$airIndex];
      $ongoingQueries[$_] = $airIndex;
      $airIndex++;
      if ($p) { print "Try query:\n"; print Dumper $q; }
      if ($q->{attack} eq "negDiff") {
        my $run->{print} = $p;
        $run->{db} = $q->{db};

        # This is the query that excludes the victim
        $run->{sql} = getNegDiffSql($q, "exclude");
        if ($p) { print Dumper $run; }
        $q->{startTVWithout} = [ gettimeofday ];
        $q->{qidWithout} = queryDatabaseAirQ($run);

        # This is the query that includes the victim
        $run->{sql} = getNegDiffSql($q, "include");
        if ($p) { print Dumper $run; }
        $q->{startTVWith} = [ gettimeofday ];
        $q->{qidWith} = queryDatabaseAirQ($run);
      }
    }
  }
  # finally, let's see if we are done
  my $done = 0;
  if ($airIndex > $#qList) {
    $done = 1;
    foreach (0..($numOngoingPairs-1)) {
      if ($ongoingQueries[$_] != $notStarted) {
        $done = 0;
      }
    }
  }
  last if $done;
}
print $ofh "];\n\nsub getAnswers{ return \$answers; }\n\n1;\n";
close($ofh);

sub getNegDiffSql {
my($q, $type) = @_;

  my @baseCols = @{ $q->{baseCols} };
  my $where = '';
  if (($type eq "exclude") || ($#baseCols >= 0)) {
    $where = 'WHERE ';
  }
  if ($type eq "exclude") {
    # add the negative condition
    if ($q->{isolateType} eq "text") {
      $where .= "$q->{isolateCol} <> '$q->{isolateVal}' ";
    }
    else {
      $where .= "$q->{isolateCol} <> $q->{isolateVal} ";
    }
    if ($#baseCols >= 0) {
      $where .= "AND ";
    }
  }
  # add the positive base conditions, if any
  for (my $i = 0; $i <= $#baseCols; $i++) {
    if ($q->{baseTypes}->[$i] eq "text") {
      $where .= "$q->{baseCols}->[$i] = '$q->{baseVals}->[$i]' ";
    }
    else {
      $where .= "$q->{baseCols}->[$i] = $q->{baseVals}->[$i] ";
    }
    if ($i < $#baseCols) {
      $where .= "AND ";
    }
  }
  my $sql = "SELECT $q->{unknownCol}, count(*) FROM $q->{table} $where GROUP BY 1";
  return $sql;
}

sub getValsFromAnswers {
my($q) = @_;
  # Here I'm only going to collect values that are in both answers.
  # Note that as a result I am throwing away information that might
  # help with my guess (though I doubt it would help much).
  my %arrayWithout = %{ $q->{refWithout} };
  my %arrayWith = %{ $q->{refWith} };
  my @valsArray = ();
  foreach my $key (keys %arrayWith) {
    if ($p) { print "check key $key\n"; }
    if (exists $arrayWithout{$key}) {
      if ($p) { print "add key $key\n"; }
      push @valsArray, $key;
    }
  }
  return @valsArray;
}

sub printAnswer {
my($ofh, $q) = @_;
  my $sig = getQuerySignature($q);
  my @baseVals = @{ $q->{baseVals} };
  my $bv = '';
  for (my $i = 0; $i <= $#baseVals; $i++) {
    if ($q->{baseTypes}->[$i] eq "text") {
      $bv .= "\"$q->{baseVals}->[$i]\"";
    }
    else {
      $bv .= "$q->{baseVals}->[$i]";
    }
    if ($i != $#baseVals) { $bv .= ", "; }
  } 
  my $bt = '';
  for (my $i = 0; $i <= $#baseVals; $i++) {
    $bt .= "\"$q->{baseTypes}->[$i]\"";
    if ($i != $#baseVals) { $bt .= ", "; }
  } 
  my $bc = '';
  for (my $i = 0; $i <= $#baseVals; $i++) {
    $bc .= "\"$q->{baseCols}->[$i]\"";
    if ($i != $#baseVals) { $bc .= ", "; }
  } 
  print $ofh "  {\n";
  print $ofh "    db => \"$q->{db}\",\n";
  print $ofh "    table => \"$q->{table}\",\n";
  print $ofh "    baseVals => [$bv],\n";
  print $ofh "    baseTypes => [$bt],\n";
  print $ofh "    baseCols => [$bc],\n";
  if ($q->{isolateType} eq "text") {
    print $ofh "    isolateVal => \"$q->{isolateVal}\",\n";
  }
  else {
    print $ofh "    isolateVal => $q->{isolateVal},\n";
  }
  if ($q->{unknownColType} eq "text") {
    print $ofh "    answer => \"$q->{answer}\",\n";
  }
  else {
    print $ofh "    answer => $q->{answer},\n";
  }
  print $ofh "    attack => \"$q->{attack}\",\n";
  print $ofh "    isolateCol => \"$q->{isolateCol}\",\n";
  print $ofh "    unknownColType => \"$q->{unknownColType}\",\n";
  print $ofh "    isolateType => \"$q->{isolateType}\",\n";
  print $ofh "    statProb => $q->{statProb},\n";
  print $ofh "    maxGuessGap => $q->{maxGuessGap},\n";
  print $ofh "    answer => \"$q->{answer}\",\n";
  print $ofh "    unknownCol => \"$q->{unknownCol}\",\n";
  print $ofh "    guess => \"$q->{guess}\",\n";
  print $ofh "    elapsed => $q->{elapsed},\n";
  print $ofh "    sig => \"$sig\",\n";
  if (exists $q->{numBaseRows}) {
    print $ofh "    numBaseRows => $q->{numBaseRows},\n";
  }
  print $ofh "  },\n";
}
