// given n find the largest k such that k^2 <= n
unsigned long long square_root(unsigned long long n) {
    if (n < 2) { return n; }

    unsigned long long below = 1;
    unsigned long long above = 2;

    // double until below^2 <= n < above^2
    for (;;) {
        unsigned long long a2 = above * above;
        if (a2 == n) { return above; }
        if (a2 > n) { break; }

        below *= 2;
        above *= 2;
    }

    // use binary search to narrow down the interval
    // until below^2 <= n < above^2 and below + 1 <= above
    for (;;) {
        if (below + 1 == above) {
            return below;
        }

        unsigned long long middle = (below + above) / 2;
        unsigned long long m2 = middle * middle;

        if (m2 == n) { return middle; }

        (m2 > n ? above : below) = middle;
    }
}
