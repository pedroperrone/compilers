#!/bin/bash

valgrind --track-origins=yes --leak-check=full -s ./etapa4 < test/input.txt
