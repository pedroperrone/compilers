#!/bin/bash

./etapa2 < 1-test_global_vars.txt > actual.txt
result=$?

if [ $result -eq 0 ] ; then
  echo -e "\e[32m1 - Tests passed!\e[0m"
else
  echo -e "\e[31m1 - Tests failed!\e[0m"
fi

./etapa2  < 2-test_global_var_error.txt > actual.txt
result=$?

if [ $result -eq 0 ] ; then
  echo -e "\e[31m2 - Tests failed!\e[0m"
else
  if colordiff actual.txt 2-expected.txt ; then
    echo -e "\e[32m2 - Tests passed!\e[0m"
  else
    echo -e "\e[31m2 - Tests failed!\e[0m"
  fi
fi
