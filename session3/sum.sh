#!/bin/bash
sum=0
for i in {1..5}
do
  sum=$((sum + i))
done
echo "The sum of numbers from 1 to 5 is: $sum"