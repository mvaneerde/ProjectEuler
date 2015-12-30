use strict;

my $n = shift @ARGV;

my %fs = ();

for (my $p = 2; $n > 1; $p++) {
	until ($n % $p) {
		$n /= $p;
		$fs{$p}++;
	}
}

if (%fs) {
	print join(" ", map { $fs{$_} == 1 ? $_ : "$_^$fs{$_}" } sort { $a <=> $b } keys %fs), "\n";
} else {
	print "1\n";
}