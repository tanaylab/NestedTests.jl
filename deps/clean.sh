#!/bin/bash
set -e -o pipefail
rm -rf tracefile.info src/*.cov src/*/*.cov test/*.cov docs/build docs/assets docs/*.html docs/*.js deps/.format deps/.untested
