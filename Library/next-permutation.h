// next_permutation.h

// given a permutation p[] of a comparable type T,
// rearrange the permutation to be the next permutation in lexicographical order
// or return false if the permutation is already maxed
template<typename T>
bool next_permutation(size_t n, T p[]) {
    // find the rightmost adjacent pair in ascending order
    // if there is no such pair this is the last permutation
    size_t m = n - 1;
    for (; m > 0; m--) {
        if (p[m - 1] < p[m]) {
            break;
        }
    }

    if (m == 0) {
        // no ascending pairs
        return false;
    }

    // p[m- 1] and p[m] are the last ascending pair
    // subtract one from m so it's p[m] and p[m + 1]
    m--;

    // find the rightmost p[k] that is greater than p[m]
    size_t k = n - 1;
    for (; true; k--) {
        if (p[k] > p[m]) {
            break;
        }
    }

    // swap p[m] and p[k]
    T temp = p[k];
    p[k] = p[m];
    p[m] = temp;

    // p[m + 1] through the end of the array are in descending order
    // reverse this so they are in ascending order
    size_t left = m + 1;
    size_t right = n - 1;
    for (; left < right; left++, right--) {
        // swap p[left] and p[right]
        T temp = p[right];
        p[right] = p[left];
        p[left] = temp;
    }

    return true;
}
