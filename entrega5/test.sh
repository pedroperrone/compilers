#!/bin/bash

./etapa5 < input.txt > output.txt
cat output.txt
python3 ilocsim.py < output.txt
