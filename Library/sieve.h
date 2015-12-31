// sieve.h

// the sieve contains a bit for every odd number between 3 and n inclusive
// bit (i - 3) / 2 corresponds to number i
// we need (i - 3) / 2 + 1 bits
class sieve {
public:
	sieve (unsigned long long n) : _n(n), _p(0) {
		if (n <= 2) {
			return;
		}

		unsigned long long last_index = (n - 3) / 2;
		unsigned long long bits = last_index + 1;
		unsigned long long bytes = bits / 8 + (bits % 8 == 0 ? 0 : 1);
		_p = new unsigned char[bytes];

		for (unsigned long long byte_index = 0; byte_index < bytes; byte_index++) {
			_p[byte_index] = '\0';
		}

		for (unsigned long long i = 3, i_2 = 9; i_2 <= _n; (i_2 += 4 * i + 4), (i += 2)) {
			if (!check(i)) { continue; }

			// LOG(L"%llu is prime; clearing odd multiples of %llu >= %llu", i, i, i_2);

			for (unsigned long long c = i_2; c <= _n; c += 2 * i) {
				composite(c);
			}

			// for (unsigned long long j = 1; j <= n; j++) {
			// 	if (!check(j)) { continue; }
			// 	LOG(L"%llu still prime", j);
			// }
		}

		// for (unsigned long long byte_index = 0; byte_index < bytes; byte_index++) {
		// 	LOG(L"_p[%llu] = 0x%02x", byte_index, _p[byte_index]);
		// }
	}

	~sieve() {
		delete [] _p;
	}

	bool check(unsigned long long i) {
		// LOG(L"Checking %llu", i);
		if (i < 2) { return false; }
		if (i % 2 == 0) { return i == 2; }

		unsigned long long bit_index = (i - 3) / 2;

		// LOG(L"bit index: %llu; byte %02x, bit %llu", bit_index, _p[bit_index / 8], bit_index % 8);
		return (_p[bit_index / 8] & (((unsigned char)1) << (bit_index % 8))) == '\0';
	}

private:
	unsigned long long _n;
	unsigned char *_p;

	void composite(unsigned long long i) {
		// LOG(L"    %llu is composite", i);
		unsigned long long bit_index = (i - 3) / 2;
		_p[bit_index / 8] |= (((unsigned char)1) << (bit_index % 8));
	}
};
