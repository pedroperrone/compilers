#!/bin/bash

./etapa1 < test.txt > actual.txt

if colordiff actual.txt expected.txt ; then
  echo -e "\e[32mTests passed!\e[0m"
else
  echo -e "\e[31mTests failed!\e[0m"
fi

./etapa1
