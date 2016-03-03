// mobius.h

// caller should free using delete []
signed char *mobius(long long max) {
    auto m = new signed char[max + 1];
    if (NULL == m) {
        return NULL;
    }

    // initialize all values to 2 (sentinel)
    for (long long i = 0; i <= max; i++) {
        m[i] = 2;
    }

    // set the first few by hand
    if (0 <= max) { m[0] = 0; } // actually undefined, but whatever
    if (1 <= max) { m[1] = 1; } // 1 is squarefree

                                       // calculate the mobius value for each integer
    for (long long i = 2; i <= max; i++) {
        if (m[i] != 2) { continue; }

        // i is a prime
        m[i] = -1;

        // zero out all multiples of i^2
        long long i2 = i * i;
        for (long long ki2 = i2; ki2 < max; ki2 += i2) {
            m[ki2] = 0;
        }

        // multiply all m[ki] by -1 for all multiples of i
        for (long long ki = 2 * i; ki < max; ki += i) {
            if (m[ki] == 2) { m[ki] = 1; }
            m[ki] *= -1;
        }
    }

    return m;
}