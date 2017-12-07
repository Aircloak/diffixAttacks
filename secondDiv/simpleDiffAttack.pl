use strict;
use Data::Dumper;
use lib '../../diffixAttackModules';
use diffixAttackConfig::dbConfig qw( getDatabaseConfig );
use diffixAttackUtilities::connectAir qw( queryDatabaseAir );
use diffixAttackUtilities::databaseRoutines qw( svConnect svDisconnect queryDatabaseRaw );
use diffixAttackUtilities::processAnswers qw( getHashesFromAnswers1 computeExpectedProb );
use diffixAttackUtilities::results qw( openRes closeRes );

require './simpleDiffAttackTests.pl';

# In this attack, we select the unknown value where the difference
# between the with and without counts are the greatest.

my $res;
my $tests = getTests();

my $run->{print} = $ARGV[0];	# 0 or 1;
$run->{resultsFile} = "results/simpleDiffAttack.txt";
my $p = $run->{print};
my $oneRunOnly = 0;

# comment away the following if you don't want to log queries
#logAirEvent("results/airLog1.txt");

$run->{testName} = "Simple Difference Attack";

$res->{total} = 0;
$res->{air}->{tot}->{correct} = 0;
$res->{raw}->{tot}->{correct} = 0;
$res->{air}->{tot}->{noGuess} = 0;	# if the correct value is LCF filtered
$res->{raw}->{tot}->{noGuess} = 0;	# if the correct value is LCF filtered
$res->{totExpProb} = 0;
$res->{numExpProb} = 0;

sub closeResSimpleDifferenceAttack {
my($res) = @_;
  my $report = '';
  if ($res->{raw}->{this}->{noGuess}) {
    $res->{outcome} = "FAIL";
    $report .= "FailReason: Raw answer showed no guess\n";
  }
  if ($res->{raw}->{this}->{correct} == 0) {
    $res->{outcome} = "FAIL";
    $report .= "FailReason: Raw answer got incorrect result\n";
  }
  if ($res->{air}->{this}->{correct}) {
    $report .= "Answer: Correct\n";
  }
  elsif ($res->{air}->{this}->{noGuess}) {
    $report .= "Answer: No Guess\n";
  }
  else {
    $report .= "Answer: Wrong\n";
  }
  $report .= "ExpectedProb: $res->{expProb}\n";
  if ($res->{air}->{this}->{noGuess} == 0) {
    # since the attacker is making a guess, we need to tally up the
    # expected statistical probability of the answer
    $res->{numExpProb}++;
    $res->{totExpProb} += $res->{expProb};
  }
  $report .= "ElapsedAir: $res->{air}->{elapsed}\n";
  $report .= "ElapsedRaw: $res->{raw}->{elapsed}\n";
  $report .= "Total: $res->{total}\n";
  $report .= "NoGuess: $res->{air}->{tot}->{noGuess}\n";
  $report .= "CleanTotal: $res->{numExpProb}\n";
  if ($res->{total} > 20) {
    my $expProb = ($res->{totExpProb} / $res->{numExpProb}) * 100;;
    my $conf = ($res->{air}->{tot}->{correct} / $res->{numExpProb}) * 100;
    my $improve = (($conf - $expProb) / (100 - $expProb)) * 100;
    my $confStr = sprintf "%.2f", $conf;
    my $improveStr = sprintf "%.2f", $improve;
    $report .= "Confidence: $confStr\n";
    $report .= "ConfidenceImprove: $improveStr\n";
    if ($conf > 75) {
      $res->{outcome} = "FAIL";
      $report .= "FailReason: High Confidence Attack\n";
    }
  }
  $report .= "Overall: $res->{outcome}\n";
  return($res->{outcome}, $report);
}

$res->{closeRoutine} = \&closeResSimpleDifferenceAttack;

foreach my $test (@{ $tests }) {
  $res->{air}->{this}->{correct} = 0;
  $res->{raw}->{this}->{correct} = 0;
  $res->{air}->{this}->{noGuess} = 0;	# if the correct value is LCF filtered
  $res->{raw}->{this}->{noGuess} = 0;	# if the correct value is LCF filtered
  $run->{db} = $test->{db};
  $res->{resultsFile} = $run->{resultsFile};
  $res->{testName} = $run->{testName};
  $run->{sql} = $test->{sqlWithout};
  openRes($run);
  # get data for both queries for the raw database
  my $db = getDatabaseConfig($run->{db});
  my $dbh = svConnect($db);
  my ($rowsRawWith, $elapsedRaw) = queryDatabaseRaw($dbh, $test->{sqlWith});
  my ($rowsRawWithout, $elapsedRaw) = 
                              queryDatabaseRaw($dbh, $test->{sqlWithout});
  svDisconnect($dbh);
  # for reasons I don't understand, sometimes I get an empty row count
  # incorrectly.  Thus the following....
  if (($rowsRawWith->{query}->{row_count} == 0) ||
           ($rowsRawWithout->{query}->{row_count} == 0)) {
    print "\nEmpty row count, skip test\n\n";
    sleep 10;
    next;
  }
  if ($p) {
    print Dumper $rowsRawWith;
    print Dumper $rowsRawWithout;
  }

  # now compute the expected probability that the victim has the
  # value it has
  $res->{expProb} = computeExpectedProb($rowsRawWith, $test->{answer});

  $res->{total}++;
  if ($p) { print "Make guess for raw\n"; }
  my $result = guessValue($rowsRawWith, $rowsRawWithout, $test->{answer}, $p);
  if ($result eq "correct") { 
    $res->{raw}->{this}->{correct}++; 
    $res->{raw}->{tot}->{correct}++; 
  }
  if ($result eq "noguess") { 
    $res->{raw}->{this}->{noGuess}++; 
    $res->{raw}->{tot}->{noGuess}++; 
  }

  $run->{sql} = $test->{sqlWith};
  my ($rowsAirWith, $elapsedAir) = queryDatabaseAir($run);
  $run->{sql} = $test->{sqlWithout};
  my ($rowsAirWithout, $elapsedAir) = queryDatabaseAir($run);
  if ($p) {
    print Dumper $rowsAirWith;
    print Dumper $rowsAirWithout;
  }

  if ($p) { print "Make guess for air\n"; }
  my $result = guessValue($rowsAirWith, $rowsAirWithout, $test->{answer}, $p);
  if ($result eq "correct") { 
    $res->{air}->{this}->{correct}++; 
    $res->{air}->{tot}->{correct}++; 
  }
  if ($result eq "noguess") { 
    $res->{air}->{this}->{noGuess}++; 
    $res->{air}->{tot}->{noGuess}++; 
  }

  $res->{air}->{elapsed} = $elapsedAir;
  $res->{raw}->{elapsed} = $elapsedRaw;

  closeRes($res);
  exit if ($oneRunOnly);
}

sub guessValue {
my($rw, $rwo, $ans, $p) = @_;
  my ($w) = getHashesFromAnswers1($rw);
  my ($wo) = getHashesFromAnswers1($rwo);
  my %w = %{ $w };
  my %wo = %{ $wo };

  # first loop through, and find most typical difference.  This reflects
  # the difference due to the noise layer. For now, I'm going to ignore
  # LCF filtered buckets.
  my @diffs = ();
  foreach (0..20) { $diffs[$_] = 0; }
  foreach my $val (keys %w) {
    if ((exists $w{$val}) && (exists $wo{$val})) {
      my $diff = $w{$val} - $wo{$val} + 10;
      if ($diff >= 0) { $diffs[$diff]++; }
    }
  }
  if ($p) { print "@diffs\n"; }
  my $max = 0;
  my $index = -1;
  foreach (0..20) {
    if ($diffs[$_] > $max) {
      $max = $diffs[$_];
      $index = $_;
    }
  }
  if ($p) { print "Max is $max at index $index\n"; }
  # ok, now we know the most typical difference.  See if there is one and
  # only one value that is different from the typical difference
  my $numDiff = 0;
  my $matchVal;
  foreach my $val (keys %w) {
    if ((exists $w{$val}) && (exists $wo{$val})) {
      my $diff = $w{$val} - $wo{$val} + 10;
      if ($diff != $index) {
        # this should be the victim's value
        $numDiff++;
        $matchVal = $val;
        if ($p) { print "numDiff $numDiff, match val = $val\n"; }
      }
    }
  }
  if ($numDiff == 1) {
    if ($matchVal == $ans) { return "correct"; }
    else { return "wrong"; }
  }
  else { return "noguess"; }
}

