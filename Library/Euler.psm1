Function Get-Factorial {
    Param([Parameter(Mandatory)][int]$n);

    $f = [int64]1;
    While ($n -gt 0) {
        $f *= $n--;
    }

    Return $f;
}
Export-ModuleMember -Function "Get-Factorial";

Function Get-Factors {
    Param([Parameter(Mandatory)][int]$n);

    $fs = @{};

    For ([int]$p = 2; $n -gt 1; $p++) {
        While (($n % $p) -eq 0) {
            $n /= $p;
            $fs[$p] += 1;
        }
    }

    Return $fs;
}
Export-ModuleMember -Function "Get-Factors";

# with f_0 = 0, f_1 = 1, and f_i = f_(i - 2) + f_i
# calculate and return all Fibonacci numbers up to f_n
Function Get-FibonacciNumbers {
    Param([Parameter(Mandatory)][int]$n);

    If ($n -lt 0) {
        Throw "n needs to be >= 0";
    }

    $f = [int64[]](0);
    If ($n -eq 0) {
        Return $f;
    }

    $f += 1;

    $f = [int64[]]@(0, 1);
    For ($i = 2; $i -le $n; $i++) {
        $f += $f[-1] + $f[-2];
    }

    Return $f;
}
Export-ModuleMember -Function "Get-FibonacciNumbers";

# given n, returns the largest s satisfying s^2 <= n
Function Get-IntegerSquareRoot {
    Param([Parameter(Mandatory)][int64]$n);

    If ($n -lt 0) {
        Throw "n needs to be >= 0";
    }

    # set up a lower and an upper bound
    # invariant: low^2 <= n < high^2
    $low = [int64]0;

    # to do the upper bound, double until we get too high
    $high = [int64]1;
    While ($high * $high -le $n) {
        $high *= 2;
    }

    # shrink the bound between low and high
    While ($high -ne ($low + 1)) {
        # find the midpoint and guess it
        $guess = $high + $low;
        If (($guess % 2) -eq 1) {
            $guess -= 1;
        }
        $guess /= 2;

        If (($guess * $guess) -le $n) {
            $low = $guess;
        } Else {
            $high = $guess;
        }
    }

    # low^2 <= n < (low + 1)^2
    # so the integer square root of n is low
    Return $low;
}
Export-ModuleMember -Function "Get-IntegerSquareRoot";

# given b, p, and m, returns b^p mod m
Function Get-ModPow {
    Param(
        [Parameter(Mandatory)][int64]$base,
        [Parameter(Mandatory)][int64]$power,
        [Parameter(Mandatory)][int64]$modulus
    );

    $x = [int64]1;
    $base %= $modulus;
    While ($power) {
        If (($power % 2) -eq 1) {
            $x = ($x * $base) % $modulus;
            $power -= 1;
        }

        $power /= 2;
        $base = ($base * $base) % $modulus;
    }

    Return $x;

}
Export-ModuleMember -Function "Get-ModPow";

Function Get-NChooseR {
    Param(
        [Parameter(Mandatory)][int]$n,
        [Parameter(Mandatory)][int]$r
    )

    If ($r -gt ($n - $r)) {
        $r = $n - $r;
    }

    $t = [int64]1;

    For ([int]$i = 1; $i -le $r; $i++) {
        $t *= $n;
        $n--;
        $t /= $i;
    }

    Return $t;
}
Export-ModuleMember -Function "Get-NChooseR";

Function Get-Primes {
    Param([Parameter(Mandatory)][int]$max);

    $primes = @();

    # we want a ceiling, not a floor
    $sqrt_max = (Get-IntegerSquareRoot -n $max) + 1;

    # we'll use a bit array, initially false
    # mark as true for numbers which are known composit
    $composite = [System.Collections.BitArray]::new($max + 1);
    For ([int]$p = 2; $p -le $max; $p++) {
        If (!$composite[$p]) {
            # we found a prime!
            $primes += $p;

            If ($p -le $sqrt_max) {
                # mark off known composites from p^2 up to max
                For ([int]$kp = $p * $p; $kp -le $max; $kp += $p) {
                    $composite[$kp] = $true;
                }
            }
        }
    }

    Return $primes;
}
Export-ModuleMember -Function "Get-Primes";
