package Euler;

use strict;

BEGIN {
	use Exporter ();
	our @EXPORT_OK = qw(
		&asin
		&extended_euclidean_algorithm
		&gcf
		&lcm
		&irreducible_pythagorean_triples
		&fibonacci
		&find_primes_below
		&mobius
		&modadd
		&modinv
		&modpow
		&modtimes
		&nCr
		&max
		&min
		&sieve
		&sieve_check
		&square_root
		&sum
		&triangle
	);
}

# arcsin
sub asin($) {
	my ($s) = @_;

	return atan2($s, sqrt(1 - $s * $s));
}

# given a and b
# return integers x and y
# such that ax + by = gcd(a, b)
sub extended_euclidean_algorithm($$) {
	my ($a, $b) = @_;
	my ($x, $lastx, $y, $lasty) = (0, 1, 1, 0);

	while ($b) {
		my $q = int $a / $b;
		($a, $b) = ($b, $a % $b);
		($x, $lastx) = ($lastx - $q * $x, $x);
		($y, $lasty) = ($lasty - $q * $y, $y);
	}

	return $lastx, $lasty;
}


# given two integers
# find the greatest common factor
# and return it
sub gcf($$) {
	my ($x, $y) = sort { $a <=> $b } @_;

	# no recursion here
	# if $y is zero then gcf($x, $y) is $x by convention
	while ($y) {
		my $z = $x % $y;
		return $y unless $z;

		($x, $y) = ($y, $z);
	}

	return $x;
}

# given two integers
# find the least common multiple
# and return it
sub lcm($$) {
	my ($x, $y) = @_;

	return $x * $y / gcf($x, $y);
}

# given a max and a callback function with three arguments
# finds all irreducible Pythagorean triples whose sum <= max
# doesn't include the vacuous triple (0, 1, 1)
# calls the callback function for each triple
#
# TODO: make this an iterator rather than a callback
# store u and v locally
#
sub irreducible_pythagorean_triples($&) {
	my $max = shift;
	my $callback = shift;

	# we generate irreducible triples by looking for relatively prime odd pairs (u, v)
	# where u and v are both odd and gcf(u, v) = 1
	# then (a, b, c) = sort (uv, (v^2 - u^2)/2, (v^2 + u^2)/2)
	#
	# note that a + b + c = v(u + v)

	# v^2 < v(u + v) <= max
	my $vmax = sqrt($max);
	# print "Looking at v's from 1 to $vmax\n";
	for (my $v = 3; $v <= $vmax; $v += 2) {

		# v(u + v) <= max; u + v <= max/v; u <= max/v - v
		my $umax = $max / $v - $v;
		$umax = $v - 2 if $umax > $v - 2;

		# print "v = 3; looking at u's from 1 to $umax\n";
		last if $umax < 1;

		for (my $u = 1; $u <= $umax; $u += 2) {
			next unless 1 == gcf($u, $v);
			# print "($u, $v)\n";
			&$callback(
				sort { $a <=> $b } (
					$u * $v,
					($v * $v - $u * $u) / 2,
					($v * $v + $u * $u) / 2
				)
			);
		}
	}
}

# returns an array of primes <= the given max
sub find_primes_below($) {
	my $max = shift;
	my @primes = ();

	# we'll use a bit array; initially 1: mark 0 if the index is known composite
	my $array = "";
	for (my $i = $max; $i >= 0; $i--) {
		vec($array, $i, 1) = 1;
	}

	for (my $i = 2; $i <= $max; $i++) {
		# skip composites
		next unless vec($array, $i, 1);

		# prime; mark off known composites
		push @primes, $i;
		for (my $m = $i * $i; $m <= $max; $m += $i) {
			vec($array, $m, 1) = 0;
		}
	}

	return @primes;
}

# creates a prime sieve up to the given max
sub sieve($) {
	my ($max) = @_;

	# use a bit array, initially 0
	# mark bit (i - 3) / 2 if i is known composite
	my $sieve = "";
	$max-- unless ($max & 1);

	# nothing to do if max <= 2
	return $sieve unless $max >= 3;

	# extend the array
	# print "Extending the array...\n";
	vec($sieve, ($max - 3) / 2, 1) = 0;

	# dump the sieve
	# for (my $i = 1; $i <= $max; $i += 2) {
	# 	print "    ", $i, " => ", vec($sieve, ($i - 3) / 2, 1), "\n";
	# }

	# sieve
	# print "Sieving numbers whose square <= $max...\n";

	for (
		my ($i, $two_i, $i_squared) = (3, 6, 9);
		$i_squared <= $max;
		($i, $two_i, $i_squared) = ($i + 2, $two_i + 4, $i_squared + 4 * $i + 4)
	) {
		# skip composites;
		next if vec($sieve, ($i - 3) / 2, 1);

		# print "$i is prime\n";

		# sieve out known composites
		for (my $c = $i_squared; $c <= $max; $c += $two_i) {
			# print "    $c is composite\n";
			vec($sieve, ($c - 3) / 2, 1) = 1;
		}
	}

	# dump the sieve
	# for (my $i = 1; $i <= $max; $i += 2) {
	# 	print "    ", $i, " => ", vec($sieve, ($i - 3) / 2, 1), "\n";
	# }

	return $sieve;
}

# queries a prime sieve to see if a given number is prime
sub sieve_check($$) {
	my ($sieve, $n) = @_;

	# 0 and 1 are known composite, 2 is known prime
	return ($n == 2) if $n <= 2;

	# other even numbers are known composite
	return 0 unless ($n & 1);

	# primes have 0, composites have 1
	return vec($sieve, ($n - 3) / 2, 1) == 0;
}

# given a base, an exponent, and a modulus
# calculates (base^exponent) % modulus
sub modpow($$$) {
	my ($b, $e, $m) = @_;

	# print "modpow($b, $e, $m) = ";

	my $p = 1;
	$b %= $m;

	while ($e) {
		if ($e % 2) {
			$p *= $b;
			$p %= $m;
		}

		$e = int ($e / 2);
		$b *= $b;
		$b %= $m;
	}

	# print "$p\n";
	return $p;
}

# calculate the Mobius function up to a given max
sub mobius($) {
	my ($m_max) = @_;
	my @mobius = (); $mobius[$m_max] = 2; $mobius[1] = 1;

	# initialize all to 2 (except 1, which is 1 by convention)
	for (my $i = 2; $i <= $m_max; $i++) {
		$mobius[$i] = 2;
	}

	# if this is the first time we've seen the number, it's prime
	for (my $i = 2; $i <= $m_max; $i++) {
		next unless $mobius[$i] == 2;

		# first multiple of the prime is prime
		$mobius[$i] = -1;

		# multiples of the prime's square are squareful
		my $i2 = $i * $i;
		for (my $ki2 = $i2; $ki2 <= $m_max; $ki2 += $i2) {
			# print "$ki2 is a multiple of $i^2\n";
			$mobius[$ki2] = 0;
		}

		# multiples of the prime have another prime factor
		for (my $ki = 2 * $i; $ki <= $m_max; $ki += $i) {
			# print "$ki is a multiple of $i\n";

			if ($mobius[$ki] == 2) {
				$mobius[$ki] = -1;
			} else {
				$mobius[$ki] *= -1;
			}
		}
	}

	return @mobius;
}

# calculates a + b mod m
sub modadd($$$) {
	my ($a, $b, $m) = @_;

	return ($a + $b) % $m;
}

# given n > 0 and p > n, calculates n^-1 mod p
sub modinv($$) {
	my ($n, $p) = @_;

	return modpow($n, $p - 2, $p);
}

# given x, y, and m, calculates (x * y) % m
sub modtimes($$$) {
	my ($x, $y, $m) = @_;

	return ($x * $y) % $m;
}

# given n and r, calculates n-choose-r
sub nCr($$) {
	my ($n, $r) = @_;

	$r = $n - $r if $r > $n - $r;

	my $t = 1;

	for (my $i = 1; $i <= $r; $i++) {
		$t *= $n;
		$n--;
		$t /= $i;
	}

	return $t;
}

# given n, calculate the nth Fibonacci number
sub fibonacci($) {
	my $n = shift;

	die "Fibonacci is only defined for n >= 1" unless $n >= 1;

	my ($a, $b) = (1, 1);

	while ($n-- > 2) {
		($a, $b) = ($b, $a + $b);
	}

	return $b;
}

# given an array of numbers, return the minimum
sub min(@) {
	@_ or die "empty set has no minimum";
	my $m = shift;
	map { $m = $_ if $_ < $m } @_;
	return $m;
}

# given an array of numbers, return the maximum
sub max(@) {
	@_ or die "empty set has no maximum";
	my $m = shift;
	map { $m = $_ if $_ > $m } @_;
	return $m;
}

# given a number, return the greatest integer less than or equal to its square root
sub square_root($) {
	my ($n) = @_;

	return 0 unless $n;
	return 1 if $n == 1;

	die "invalid argument $n" unless $n > 1;

	my ($below, $above) = (1, 2);

	# double until above^2 > n
	for (;;) {
		my $a2 = $above * $above;
		return $above if $a2 == $n;
		last if $a2 > $n;

		$below *= 2;
		$above *= 2;

		# print "ascending: ($below, $above)\n";
	}

	# use binary search to narrow down above/below
	for (;;) {
		die if $below >= $above;

		my $middle = int(($below + $above) / 2);
		my $m2 = $middle * $middle;

		return $middle if $m2 == $n;

		if ($m2 > $n) {
			$above = $middle;
			next;
		}

		$below = $middle;
		return $below if $below + 1 == $above;

		# print "narrowing: ($below, $above)\n";
	}
}

# given an array of numbers, return the sum
sub sum(@) {
	my $s = 0;
	map { $s += $_ } @_;
	return $s;
}

# return the nth triangular number
sub triangle($) {
	my ($n) = @_;
	return $n * ($n + 1) / 2;
}

# .pm files need to return a true value
1