#!/bin/bash
set -e -o pipefail
rm -rf docs
mkdir docs
julia --color=no deps/document.jl
sed -i 's: on <span class="colophon-date" title="[^"]*">[^<]*</span>::' docs/*html
sed -i 's:</h1>: (HEAD REVISION)</h1>:' docs/index.html
rm -f docs/*.jl docs/*.cov
cp deps/make.jl docs/make.jl
