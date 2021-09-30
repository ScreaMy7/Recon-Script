#!/bin/bash
CUR_PATH=$(pwd)
for i in $(cat $CUR_PATH/wordlist/alterations.txt); do echo $i.$1;
done;