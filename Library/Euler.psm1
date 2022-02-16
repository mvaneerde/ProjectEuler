# with f_0 = 0, f_1 = 1, and f_i = f_(i - 2) + f_i
# calculate and return all Fibonacci numbers up to f_n
Function Get-FibonacciNumbers {
    Param([int]$n)

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
    Param([int]$n, [int]$r)

    If ($r -gt ($n - $r)) {
        $r = $n - $r;
    }

    $t = 1;

    For ([int]$i = 1; $i -le $r; $i++) {
        $t *= $n;
        $n--;
        $t /= $i;
    }

    Return $t;
}
Export-ModuleMember -Function "Get-NChooseR";
