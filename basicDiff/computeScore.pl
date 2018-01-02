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

# ---------------- end config ----------------------

die "Must supply answer file in command line" if ($#ARGV < 0);
my $answerFile = $ARGV[0];
require $answerFile;
my $answers = getAnswers();

# $numKnown will be the total number of answers, but we'll also
# pretend that this is the number of attacker-known cells to compute
# alpha. If it isn't, then we'll have to compute alpha by hand.
my $numKnown = 0;

my @probCategories = (1, 5, 10, 25, 50, 100);
my $right;
my $wrong;
my $noGuess;
my $total;
my $statProb;
foreach my $prob (0..($#probCategories-1)) {
  foreach my $gap (0..$maxGap) {
    $right->[$prob]->[$gap] = 0;
    $wrong->[$prob]->[$gap] = 0;
    $noGuess->[$prob]->[$gap] = 0;
    $statProb->[$prob]->[$gap] = 0;
    $total->[$prob]->[$gap] = 0;
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

foreach my $a (@{ $answers }) {
  $numKnown++;
  # figure out the stat prob category
  my $probIndex = 0;
  my $thisStatProb = int($a->{statProb} * 100);
  foreach (0..$#probCategories) {
    if ($thisStatProb < $probCategories[$_]) {
      $probIndex = $_;
      last;
    }
  }
  foreach my $gap (0..$maxGap) {
    if ($gap > $a->{maxGuessGap}) {
      $totalNoGuess[$gap]++;
      $noGuess->[$probIndex]->[$gap]++;
    }
    else {
      $totalStatProb[$gap] += $a->{statProb};
      $totalAnswers[$gap]++;
      $total->[$probIndex]->[$gap]++;
      $statProb->[$probIndex]->[$gap] += $a->{statProb};
      if ($a->{guess} eq "right") {
        $totalRight[$gap]++;
        $right->[$probIndex]->[$gap]++;
      }
      else {
        $totalWrong[$gap]++;
        $wrong->[$probIndex]->[$gap]++;
      }
    }
  }
}

print "\nFinal Results\n-------------\n";
foreach my $gap (0..$maxGap) {
  my $gapStr = sprintf "%2d", $gap;
  foreach my $prob (0..$#probCategories) {
    my $probStr = sprintf "%3d", $probCategories[$prob];
    if ($total->[$prob]->[$gap]) {
      my $score->{right} = $right->[$prob]->[$gap];
      $score->{wrong} = $wrong->[$prob]->[$gap];
      $score->{statProb} = ($statProb->[$prob]->[$gap]/$total->[$prob]->[$gap]);
      $score->{known} = $numKnown;
      $score = getScore($score);
      my $tag = "gap ".$gapStr." prob < ".$probStr;
      printScore(*STDOUT, $tag, $score);
    }
  }
  if ($totalAnswers[$gap]) {
    my $score->{right} = $totalRight[$gap];
    $score->{wrong} = $totalWrong[$gap];
    $score->{statProb} = ($totalStatProb[$gap]/$totalAnswers[$gap]);
    $score->{known} = $numKnown;
    $score = getScore($score);
    my $tag = "gap ".$gapStr." all probs";
    printScore(*STDOUT, $tag, $score);
  }
}

