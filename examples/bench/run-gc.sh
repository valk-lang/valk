#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_dir="$(cd "$script_dir/../.." && pwd)"
source_dir="$script_dir/gc"
build_dir="$repo_dir/debug/benchmarks/gc-suite"
all_languages=(valk go d csharp)
languages=()

usage() {
    printf 'Usage: %s [language ...]\n' "$0"
    printf '\nLanguages:\n'
    printf '  valk\n  go\n  d\n  csharp\n'
    printf '\nWith no language names, every implementation is built and run.\n'
}

while (($#)); do
    case "$1" in
        --list)
            printf '%s\n' "${all_languages[@]}"
            exit 0
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        c#)
            languages+=(csharp)
            shift
            ;;
        -* )
            printf 'Unknown option: %s\n' "$1" >&2
            usage >&2
            exit 1
            ;;
        *)
            languages+=("$1")
            shift
            ;;
    esac
done

if ((${#languages[@]} == 0)); then
    languages=("${all_languages[@]}")
fi

is_language() {
    local requested="$1"
    local language
    for language in "${all_languages[@]}"; do
        if [[ "$language" == "$requested" ]]; then
            return 0
        fi
    done
    return 1
}

for language in "${languages[@]}"; do
    if ! is_language "$language"; then
        printf 'Unknown language: %s\n' "$language" >&2
        usage >&2
        exit 1
    fi
done

if ! command -v /usr/bin/time >/dev/null 2>&1; then
    printf 'Required command not found: /usr/bin/time\n' >&2
    exit 1
fi

d_compiler=""
if command -v ldc2 >/dev/null 2>&1; then
    d_compiler="ldc2"
elif command -v dmd >/dev/null 2>&1; then
    d_compiler="dmd"
elif command -v gdc >/dev/null 2>&1; then
    d_compiler="gdc"
fi

mkdir -p "$build_dir"

build_language() {
    local language="$1"
    printf 'Building %s GC benchmark\n' "$language" >&2
    case "$language" in
        valk)
            if [[ ! -x "$repo_dir/valk" ]]; then
                printf 'Valk compiler not found: %s/valk\n' "$repo_dir" >&2
                exit 1
            fi
            "$repo_dir/valk" build "$source_dir/main.valk" --release -o "$build_dir/gc-valk" >/dev/null
            ;;
        go)
            command -v go >/dev/null 2>&1 || {
                printf 'Required command not found: go\n' >&2
                exit 1
            }
            go build -o "$build_dir/gc-go" "$source_dir/main.go"
            ;;
        d)
            if [[ -z "$d_compiler" ]]; then
                printf 'No D compiler found; install ldc2, dmd, or gdc\n' >&2
                exit 1
            fi
            case "$d_compiler" in
                ldc2) ldc2 -O3 -release -boundscheck=off -of="$build_dir/gc-d" "$source_dir/main.d" ;;
                dmd) dmd -O -release -inline -boundscheck=off -of="$build_dir/gc-d" "$source_dir/main.d" ;;
                gdc) gdc -O3 -frelease -o "$build_dir/gc-d" "$source_dir/main.d" ;;
            esac
            ;;
        csharp)
            command -v dotnet >/dev/null 2>&1 || {
                printf 'Required command not found: dotnet\n' >&2
                exit 1
            }
            local dotnet_version
            local dotnet_framework
            dotnet_version="$(dotnet --version)"
            dotnet_framework="net${dotnet_version%%.*}.0"
            DOTNET_CLI_HOME="$build_dir/dotnet-home" \
            DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1 \
            DOTNET_CLI_TELEMETRY_OPTOUT=1 \
            dotnet publish "$source_dir/gc-csharp.csproj" \
                --configuration Release \
                --output "$build_dir/csharp" \
                --nologo \
                -p:BaseIntermediateOutputPath="$build_dir/csharp-obj/" \
                -p:BaseOutputPath="$build_dir/csharp-bin/" \
                -p:GcTargetFramework="$dotnet_framework" \
                -p:DisableTransitiveFrameworkReferenceDownloads=true \
                -p:RestoreIgnoreFailedSources=true \
                -p:NuGetAudit=false \
                >/dev/null
            ;;
    esac
}

run_language() {
    local language="$1"
    local command=()
    local output="$build_dir/$language.out"
    local timing="$build_dir/$language.time"
    local results="$build_dir/$language.results"
    case "$language" in
        valk) command=("$build_dir/gc-valk") ;;
        go) command=("$build_dir/gc-go") ;;
        d) command=("$build_dir/gc-d") ;;
        csharp) command=(dotnet "$build_dir/csharp/gc-csharp.dll") ;;
    esac

    printf 'Running  %s GC benchmark\n' "$language" >&2
    /usr/bin/time -f '%e %M' -o "$timing" "${command[@]}" >"$output"
    if grep -q '^verify:   FAIL$' "$output"; then
        printf '%s GC benchmark failed verification\n' "$language" >&2
        cat "$output" >&2
        exit 1
    fi

    awk '
        /^=== / {
            scenario = $0
            sub(/^=== /, "", scenario)
            sub(/ ===$/, "", scenario)
        }
        /^time_ms:/ { time_ms[scenario] = $2 }
        /^mem_kb:/ { print scenario "\t" time_ms[scenario] "\t" $2 }
    ' "$output" >"$results"
}

for language in "${languages[@]}"; do
    build_language "$language"
done

for language in "${languages[@]}"; do
    run_language "$language"
done

result_value() {
    local language="$1"
    local scenario="$2"
    local column="$3"
    awk -F '\t' -v scenario="$scenario" -v column="$column" \
        '$1 == scenario { print $column }' "$build_dir/$language.results"
}

display_name() {
    case "$1" in
        valk) printf 'Valk' ;;
        go) printf 'Go' ;;
        d) printf 'D' ;;
        csharp) printf 'C#' ;;
    esac
}

scenarios=(
    'short-lived alloc'
    'stable-heap forced collects'
    'build long-lived chain'
    'free long-lived chain'
    'mutate live links'
    'short-lived churn with large live set'
    'tree churn'
)

printf '\nScenario time reported by each runtime:\n\n'
printf '| Scenario |'
for language in "${languages[@]}"; do
    printf ' %s |' "$(display_name "$language")"
done
printf '\n|---|'
for language in "${languages[@]}"; do printf '%s' '---:|'; done
printf '\n'
for scenario in "${scenarios[@]}"; do
    printf '| %s |' "$scenario"
    for language in "${languages[@]}"; do
        printf ' %s ms |' "$(result_value "$language" "$scenario" 2)"
    done
    printf '\n'
done

printf '\nManaged memory reported by each runtime:\n\n'
printf '| Scenario |'
for language in "${languages[@]}"; do
    printf ' %s |' "$(display_name "$language")"
done
printf '\n|---|'
for language in "${languages[@]}"; do printf '%s' '---:|'; done
printf '\n'
for scenario in "${scenarios[@]}"; do
    printf '| %s |' "$scenario"
    for language in "${languages[@]}"; do
        printf ' %s KiB |' "$(result_value "$language" "$scenario" 3)"
    done
    printf '\n'
done

printf '\nWhole-process measurements from GNU time:\n\n'
printf '| Language | Elapsed | Peak RSS |\n'
printf '|---|---:|---:|\n'
for language in "${languages[@]}"; do
    read -r elapsed rss <"$build_dir/$language.time"
    printf '| %s | %s s | %s KiB |\n' "$(display_name "$language")" "$elapsed" "$rss"
done
