#!/usr/bin/bash

# A simple script to mimic running a simulation
#
# Requires two inputs
#   a : float
#   b : float
#
# Echos the simulation parameters and writes the result
# of the simulation (a * b)

echo "Running simulation with parameters a = ${1} and b = ${2}"

ans=$(bc -l <<<"${1}*${2}")

echo "${ans}" > "output.txt"

