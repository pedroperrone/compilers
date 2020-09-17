#!/bin/bash

BIN_NAME=etapa2
TEST_PASSED_MESSAGE="\e[32mTest passed:"
TEST_FAILED_MESSAGE="\e[31mTest failed:"

function run_error_test {
  ./$BIN_NAME < $test_path/input.txt > $test_path/actual.txt
  result=$?

  if [ $result -eq 0 ]; then
    echo -e $TEST_FAILED_MESSAGE $test_path
  else
    if colordiff $test_path/actual.txt $test_path/expected.txt ; then
      echo -e $TEST_PASSED_MESSAGE $test_path
    else
      echo -e $TEST_FAILED_MESSAGE $test_path
    fi
  fi
}

function run_normal_test {
  ./$BIN_NAME < $test_path/input.txt
  result=$?

  if [ $result -eq 0 ]; then
    echo -e $TEST_PASSED_MESSAGE $test_path
  else
    echo -e $TEST_FAILED_MESSAGE $test_path
  fi
}

function run_test {
  test_path=$1

  if [ -f "$test_path/expected.txt" ]; then
    run_error_test $test_path
  else
    run_normal_test $test_path
  fi
}

for test in tests/*; do
  run_test $test
done
