#!/bin/bash

BIN_NAME=etapa3
TEST_PASSED_MESSAGE="\e[32mTests passed\e[0m"
TEST_FAILED_MESSAGE="\e[31mTests failed\e[0m"

valgrind --track-origins=yes --leak-check=full -s ./$BIN_NAME < test/input.txt

./$BIN_NAME < test/input.txt > test/actual.txt
result=$?

if [ $result -ne 0 ]; then
  echo -e $TEST_FAILED_MESSAGE
else
  if colordiff test/actual.txt test/expected.txt ; then
    echo -e $TEST_PASSED_MESSAGE
  else
    echo -e $TEST_FAILED_MESSAGE
  fi
fi
