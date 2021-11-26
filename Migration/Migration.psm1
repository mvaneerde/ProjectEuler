Function Test-ByteArraysEqual {
    Param([byte[]]$a, [byte[]]$b);

    If ($a.Length -ne $b.Length) {
        Return $False;
    }

    For ($i = 0; $i -lt $a.Length; $i++) {
        If ($a[$i] -ne $b[$i]) {
            Return $False;
        }
    }

    Return $True;
}
Export-ModuleMember -Function "Test-ByteArraysEqual";
