### findMultiColumnAttacks.pl and findSingleColumnAttacks.pl

These programs each generate a file that contains a set of queries that may be used for difference attacks. An example of such a file is `example.queries.pl`.

### runAttackQueries.pl

This program reads a file containing the set of queries (i.e. `example.queries.pl`), runs the attacks, and generates an output the contains the individual results of each attack. An example of the output is at `example.answers.pl`.

### computeScore.pl

This program reads a file containing the set of answers, and tabulates the results into a file that may be read by gnuplot.

### More info

The comments within each of the programs gives details
