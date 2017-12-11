#!/usr/bin/env bash

set -e -x

for test_case in `ls $PWD/tests | grep -e '$*\.lua'`; do
  tarantool $PWD/tests/$test_case
  echo "[+] Case: $test_case -- OK"
done
# kill -s TERM %1 || echo "it's ok"
echo "[+] Done"
