// gcf.h

unsigned long long gcf(unsigned long long m, unsigned long long n) {
    unsigned long long t = 0;

    // make sure m >= n
    if (m < n) {
        t = m;
        m = n;
        n = t;
    }

    while (n) {
        t = m;
        m = n;
        n = t % n;
    }

    return m;
}
