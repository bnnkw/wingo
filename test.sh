#!/bin/sh

set -e

mkdir -p ./test_result

vim -S test/test_history.vim -c q --not-a-term >/dev/null && cat test_result/ok || cat test_result/error
