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
