// modpow.h

unsigned long long modpow(unsigned long long b, unsigned long long e, unsigned long long m) {
    unsigned long long x = 1;

    b %= m;
    while (e) {
        if (e % 2) {
            x *= b;
            x %= m;
        }

        e /= 2;
        b *= b;
        b %= m;
    }

    return x;
}

unsigned long long modtimes(unsigned long long a, unsigned long long b, unsigned long long m) {
    a %= m;
    b %= m;

    unsigned long long c = a * b;
    if (a > 0 && b > 0 && (c < a || c < b)) {
        // LOG("Overflow: %llu * %llu", a, b);
        exit(0);
    }
    c %= m;
    return c;
}

unsigned long long modadd(unsigned long long a, unsigned long long b, unsigned long long m) {
    return ((a % m) + (b % m)) % m;
}

unsigned long long modsubtract(unsigned long long a, unsigned long long b, unsigned long long m) {
    a %= m;
    b %= m;
    
    return (a >= b) ? (a - b) : (m + a - b);
}

unsigned long long modinv(unsigned long long n, unsigned long long p) {
	return modpow(n, p - 2, p);
}
