use strict;
use Euler qw/nCr/;

die "Expected two arguments" unless 2 == @ARGV;

my ($n, $r) = @ARGV;

print Euler::nCr($n, $r), "\n";
