#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_dir="$(cd "$script_dir/../.." && pwd)"
build_dir="$repo_dir/debug/benchmarks"
runs=3

all_benchmarks=(
    binary-tree
    json-serde
    lru
    merkletrees
    nsieve
    spectral-norm
    spectral-norm-multi
)
benchmarks=()

usage() {
    printf 'Usage: %s [--runs N] [benchmark ...]\n' "$0"
    printf '\nBenchmarks:\n'
    printf '  %s\n' "${all_benchmarks[@]}"
    printf '\nWith no benchmark names, all benchmarks are run.\n'
}

while (($#)); do
    case "$1" in
        --runs)
            if (($# < 2)); then
                printf 'Missing value after --runs\n' >&2
                exit 1
            fi
            runs="$2"
            shift 2
            ;;
        --list)
            printf '%s\n' "${all_benchmarks[@]}"
            exit 0
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -* )
            printf 'Unknown option: %s\n' "$1" >&2
            usage >&2
            exit 1
            ;;
        *)
            benchmarks+=("$1")
            shift
            ;;
    esac
done

if ! [[ "$runs" =~ ^[1-9][0-9]*$ ]]; then
    printf -- '--runs must be a positive integer\n' >&2
    exit 1
fi

if ((${#benchmarks[@]} == 0)); then
    benchmarks=("${all_benchmarks[@]}")
fi

is_benchmark() {
    local requested="$1"
    local benchmark
    for benchmark in "${all_benchmarks[@]}"; do
        if [[ "$benchmark" == "$requested" ]]; then
            return 0
        fi
    done
    return 1
}

for benchmark in "${benchmarks[@]}"; do
    if ! is_benchmark "$benchmark"; then
        printf 'Unknown benchmark: %s\n' "$benchmark" >&2
        usage >&2
        exit 1
    fi
done

for command in go rustc cargo /usr/bin/time; do
    if ! command -v "$command" >/dev/null 2>&1; then
        printf 'Required command not found: %s\n' "$command" >&2
        exit 1
    fi
done

if [[ ! -x "$repo_dir/valk" ]]; then
    printf 'Valk compiler not found: %s/valk\n' "$repo_dir" >&2
    exit 1
fi

mkdir -p "$build_dir"
measure_dir="$(mktemp -d)"
trap 'rm -rf "$measure_dir"' EXIT

benchmark_args() {
    case "$1" in
        binary-tree)  args=(19) ;;
        json-serde)   args=(sample 50000) ;;
        lru)          args=(1000 11000000) ;;
        merkletrees)  args=(18) ;;
        nsieve)       args=(13) ;;
        spectral-norm) args=(5500) ;;
        spectral-norm-multi) args=(8000 4) ;;
    esac
}

benchmark_input() {
    case "$1" in
        binary-tree)   printf '19' ;;
        json-serde)    printf 'sample, 50000' ;;
        lru)           printf '1000, 11000000' ;;
        merkletrees)   printf '18' ;;
        nsieve)        printf '13' ;;
        spectral-norm) printf '5500' ;;
        spectral-norm-multi) printf '8000, 4 workers' ;;
    esac
}

build_benchmark() {
    local benchmark="$1"
    local language="$2"
    local source_dir="$script_dir/$benchmark"
    local output="$build_dir/$benchmark-$language"

    printf 'Building %-14s %s\n' "$benchmark" "$language" >&2
    case "$language" in
        valk)
            "$repo_dir/valk" build "$source_dir/main.valk" --release -o "$output" >/dev/null
            ;;
        go)
            go build -o "$output" "$source_dir/main.go"
            ;;
        rust)
            if [[ -f "$source_dir/Cargo.toml" ]]; then
                cargo build --quiet --release \
                    --manifest-path "$source_dir/Cargo.toml" \
                    --target-dir "$build_dir/cargo-$benchmark"
                cp "$build_dir/cargo-$benchmark/release/$benchmark" "$output"
            else
                rustc -C opt-level=3 -C debuginfo=0 -o "$output" "$source_dir/main.rs"
            fi
            ;;
    esac
}

median() {
    sort -n "$1" | awk '
        { values[NR] = $1 }
        END {
            middle = int((NR + 1) / 2)
            if (NR % 2) printf "%.3f", values[middle]
            else printf "%.3f", (values[middle] + values[middle + 1]) / 2
        }
    '
}

median_memory() {
    sort -n "$1" | awk '
        { values[NR] = $1 / 1024 }
        END {
            middle = int((NR + 1) / 2)
            if (NR % 2) printf "%.1f", values[middle]
            else printf "%.1f", (values[middle] + values[middle + 1]) / 2
        }
    '
}

measure_benchmark() {
    local benchmark="$1"
    local language="$2"
    local binary="$build_dir/$benchmark-$language"
    local source_dir="$script_dir/$benchmark"
    local times="$measure_dir/$benchmark-$language-times"
    local memories="$measure_dir/$benchmark-$language-memory"
    local output="$measure_dir/$benchmark-$language-output"
    local timing="$measure_dir/$benchmark-$language-timing"
    local run
    local elapsed
    local rss
    local args=()

    benchmark_args "$benchmark"
    printf 'Running  %-14s %s (%s measured runs)\n' "$benchmark" "$language" "$runs" >&2

    (cd "$source_dir" && "$binary" "${args[@]}") >"$output"
    cp "$output" "$measure_dir/$benchmark-$language-reference"

    : >"$times"
    : >"$memories"
    for ((run = 1; run <= runs; run++)); do
        (cd "$source_dir" && /usr/bin/time -f '%e %M' -o "$timing" \
            "$binary" "${args[@]}") >"$output"
        read -r elapsed rss <"$timing"
        printf '%s\n' "$elapsed" >>"$times"
        printf '%s\n' "$rss" >>"$memories"
    done

    measured_time="$(median "$times")"
    measured_memory="$(median_memory "$memories")"
}

languages=(valk go rust)
results="$measure_dir/results"
: >"$results"

for benchmark in "${benchmarks[@]}"; do
    reference_output=""
    for language in "${languages[@]}"; do
        build_benchmark "$benchmark" "$language"
        measure_benchmark "$benchmark" "$language"

        output="$measure_dir/$benchmark-$language-reference"
        if [[ -z "$reference_output" ]]; then
            reference_output="$output"
        elif ! cmp -s "$reference_output" "$output"; then
            printf 'Warning: %s output differs between Valk and %s\n' \
                "$benchmark" "$language" >&2
        fi

        printf '%s\t%s\t%s\t%s\n' \
            "$benchmark" "$language" "$measured_time" "$measured_memory" >>"$results"
    done
done

printf '\nMedian of %s runs after one warm-up; memory is peak RSS.\n\n' "$runs"
printf '| Benchmark | Input | Valk time / memory | Go time / memory | Rust time / memory |\n'
printf '|---|---:|---:|---:|---:|---:|---:|---:|\n'
for benchmark in "${benchmarks[@]}"; do
    input="$(benchmark_input "$benchmark")"
    valk_time="$(awk -F '\t' -v b="$benchmark" '$1 == b && $2 == "valk" { print $3 }' "$results")"
    valk_memory="$(awk -F '\t' -v b="$benchmark" '$1 == b && $2 == "valk" { print $4 }' "$results")"
    go_time="$(awk -F '\t' -v b="$benchmark" '$1 == b && $2 == "go" { print $3 }' "$results")"
    go_memory="$(awk -F '\t' -v b="$benchmark" '$1 == b && $2 == "go" { print $4 }' "$results")"
    rust_time="$(awk -F '\t' -v b="$benchmark" '$1 == b && $2 == "rust" { print $3 }' "$results")"
    rust_memory="$(awk -F '\t' -v b="$benchmark" '$1 == b && $2 == "rust" { print $4 }' "$results")"
    printf '| %s | %s | %ss (%s MB) | %ss (%s MB) | %ss (%s MB) |\n' \
        "$benchmark" "$input" \
        "$valk_time" "$valk_memory" \
        "$go_time" "$go_memory" \
        "$rust_time" "$rust_memory"
done
