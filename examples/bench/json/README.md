# Dynamic JSON benchmark

This benchmark decodes the same small JSON object into each language's dynamic
JSON representation, then encodes the final value the same number of times.
The iteration count defaults to `2000000` and can be passed as the first
argument.

Unlike `json-serde`, this workload does not decode directly into a typed model.
