use strict;
use Math::Round;
use Data::Dumper;
use Time::HiRes qw( usleep gettimeofday tv_interval );
use lib '../../diffixAttackModules';
use diffixAttackConfig::dbConfig qw( getDatabaseConfig );
use diffixAttackUtilities::bounties qw( getScore printScore );
use diffixAttackUtilities::connectAir qw( queryDatabaseAirQ getQueryResult );
use diffixAttackUtilities::databaseRoutines qw( svConnect queryDatabaseRaw );
use diffixAttackUtilities::processAnswers qw( getHashesFromAnswers1 );

# This attack tabulates the answers produced by `runAttackQueries.pl`.
#
# To run:
# `perl computeScore.pl answers.pl > results.txt`
#
# An example of `answers.pl` can be found at `example.answers.pl`.
#
# The output is written to standard out. Note that the output is suitable
# for reading by gnuplot.

$| = 1;

# ---------------- config ----------------------

my $maxGap = 16;
# we want to tag the best knowledge scores for the following
# achieved confidence improvements
my @bestK = (100, 95, 85, 70, 50);
# we want to tag the best confidence improvement scores for the
# following knowledge scores
my @bestCi = (0.1, 0.01, 0.001, 0.0001);
my $sigNum = 50;  # only tag scores that have at least this many samples

# ---------------- end config ----------------------

die "Must supply answer file in command line" if ($#ARGV < 0);
my $answerFile = $ARGV[0];
require $answerFile;
my $answers = getAnswers();
my @answers = @{ $answers };

# $numKnown will be the total number of answers, but we'll also
# pretend that this is the number of attacker-known cells to compute
# alpha. If it isn't, then we'll have to compute alpha by hand.
my $numKnown = 0;

# these probcategories are exclusive in that they record probs 0-1,
# 1-5, 5-10, etc. as a histogram. the $allProb index then gets all of them
my @probCategories = (1, 5, 10, 25, 50, 100, 101);
my $allProb = $#probCategories;		# index for all prob categories
# these row categories are cumulative: 0 means any number of rows, (or
# unknown), 50 means more than 50, 100 means more than 100, etc.
my @rowThresholds = (0);
my $a = $answers[0];
if (exists $a->{numBaseRows}) {
  @rowThresholds = (0,50,100,500,1000);
}
my $right;
my $wrong;
my $total;
my $statProb;
my $totRows;
foreach my $rows (0..$#rowThresholds) {
  foreach my $prob (0..$#probCategories) {
    foreach my $gap (0..$maxGap) {
      $right->[$prob]->[$gap]->[$rows] = 0;
      $wrong->[$prob]->[$gap]->[$rows] = 0;
      $statProb->[$prob]->[$gap]->[$rows] = 0;
      $total->[$prob]->[$gap]->[$rows] = 0;
      $totRows->[$prob]->[$gap]->[$rows] = 0;
    }
  }
}

my @totalNoGuess = ();
my @totalRight = ();
my @totalWrong = ();
my @totalStatProb = ();
my @totalAnswers = ();
foreach (0..$maxGap) { 
  $totalNoGuess[$_] = 0; 
  $totalRight[$_] = 0; 
  $totalWrong[$_] = 0; 
  $totalStatProb[$_] = 0; 
  $totalAnswers[$_] = 0; 
}

foreach my $a (@answers) {
  die "bad record with sig $a->{sig}" if
    (($a->{maxGuessGap} == -1) && ($a->{guess} ne "noguess"));
  $numKnown++;
  # figure out the stat prob category
  my $probIndex = 0;
  my $thisStatProb = int($a->{statProb} * 100);
  foreach (0..$#probCategories) {
    if ($thisStatProb <= $probCategories[$_]) {
      $probIndex = $_;
      last;
    }
  }
  die "bad prob index $probIndex, $thisStatProb" if ($probIndex >= $#probCategories);
  # figure out the num rows category
  my $numRows = 0;
  if (exists $a->{numBaseRows}) {
    $numRows = $a->{numBaseRows};
  }
  my $rowThresh = 0;
  for (my $rowIndex = $#rowThresholds; $rowIndex >= 0; $rowIndex--) {
    if ($numRows >= $rowThresholds[$rowIndex]) {
      $rowThresh = $rowIndex;
      last;
    }
  }
  my $thisGap = $a->{maxGuessGap};
  # now we increment all appropriate counters
  foreach my $gap (0..$maxGap) {
    foreach my $prob (0..$#probCategories) {
      foreach my $rows (0..$#probCategories) {
        if (($prob == $probIndex) &&
            ($thisGap >= $gap) && ($rows <= $rowThresh)) {
          $total->[$prob]->[$gap]->[$rows]++;
          $total->[$allProb]->[$gap]->[$rows]++;
          $statProb->[$prob]->[$gap]->[$rows] += $a->{statProb};
          $statProb->[$allProb]->[$gap]->[$rows] += $a->{statProb};
          $totRows->[$prob]->[$gap]->[$rows] += $numRows;
          $totRows->[$allProb]->[$gap]->[$rows] += $numRows;
          if ($a->{guess} eq "right") {
            $right->[$prob]->[$gap]->[$rows]++;
            $right->[$allProb]->[$gap]->[$rows]++;
          }
          elsif ($a->{guess} eq "wrong") {
            $wrong->[$prob]->[$gap]->[$rows]++;
            $wrong->[$allProb]->[$gap]->[$rows]++;
          }
        }
      }
    }
  }
}

my @scoreList = ();

foreach my $gap (0..$maxGap) {
  foreach my $prob (0..$#probCategories) {
    foreach my $rows (0..$#rowThresholds) {
      if ($total->[$prob]->[$gap]->[$rows]) {
        my $score->{right} = $right->[$prob]->[$gap]->[$rows];
        $score->{wrong} = $wrong->[$prob]->[$gap]->[$rows];
        $score->{statProb} = ($statProb->[$prob]->[$gap]->[$rows]/$total->[$prob]->[$gap]->[$rows]);
        $score->{known} = $numKnown;
        $score->{gap} = $gap;
        $score->{statCat} = $probCategories[$prob];
        $score->{rowCat} = $rowThresholds[$rows];
        $score->{rows} = int($totRows->[$prob]->[$gap]->[$rows]/$total->[$prob]->[$gap]->[$rows]);
        $score->{tag} = 0;
        $score = getScore($score);
        push @scoreList, $score;
        #printScore(*STDOUT, $score);
      }
    }
  }
}

my @bK = ();
foreach (0..$#bestK) { $bK[$_] = 0; }
my @bCi = ();
foreach (0..$#bestCi) { $bCi[$_] = 0; }

# now go through and record the best results
foreach my $s (@scoreList) {
  next if (($s->{right} + $s->{wrong}) < $sigNum);
  for (my $i = 0; $i <= $#bestK; $i++) {
    my $ci = $bestK[$i];
    if ($s->{kappa} >= $ci) {
      # see if this gives us the best knowledge score
      if ($s->{alpha} > $bK[$i]) {
        $bK[$i] = $s->{alpha};
      }
      last;
    }
  }
  for (my $i = 0; $i <= $#bestCi; $i++) {
    my $k = $bestCi[$i];
    if ($s->{alpha} >= $k) {
      # see if this gives us the best knowledge score
      if ($s->{kappa} > $bCi[$i]) {
        $bCi[$i] = $s->{kappa};
      }
      last;
    }
  }
}

# and go through again and record the best results
foreach my $s (@scoreList) {
  next if (($s->{right} + $s->{wrong}) < $sigNum);
  for (my $i = 0; $i <= $#bestK; $i++) {
    my $ci = $bestK[$i];
    if ($s->{kappa} >= $ci) {
      # see if this gives us the best knowledge score
      if ($s->{alpha} == $bK[$i]) {
        $s->{tag} = 1;
      }
      last;
    }
  }
  for (my $i = 0; $i <= $#bestCi; $i++) {
    my $k = $bestCi[$i];
    if ($s->{alpha} >= $k) {
      # see if this gives us the best knowledge score
      if ($s->{kappa} == $bCi[$i]) {
        $s->{tag} = 1;
      }
      last;
    }
  }
}

foreach my $s (@scoreList) {
  printScore(*STDOUT, $s);
}
