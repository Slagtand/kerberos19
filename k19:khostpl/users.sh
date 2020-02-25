#!/bin/bash

for num in {01..06}
do
    # users locals i de kerberos
    useradd "local$num"
    useradd "kuser$num"
    # passwd pels locals
    echo "local$num" | passwd local$num --stdin
done