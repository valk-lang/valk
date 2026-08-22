extern long long library_add(long long left, long long right);

int main(void) {
    return library_add(20, 22) == 42 ? 0 : 1;
}
