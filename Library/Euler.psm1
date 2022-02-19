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

    # we'll use a bit array, initially false
    # mark as true for numbers which are known composit
    $composite = [System.Collections.BitArray]::new($max + 1);
    For ([int]$p = 2; $p -le $max; $p++) {
        If (!$composite[$p]) {
            # we found a prime!
            $primes += $p;

            # mark off known composites from p^2 up to max
            For ([int]$kp = $p * $p; $kp -le $max; $kp += $p) {
                $composite[$kp] = $true;
            }
        }
    }

    Return $primes;
}
Export-ModuleMember -Function "Get-Primes";
