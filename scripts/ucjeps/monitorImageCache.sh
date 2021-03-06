#!/bin/bash -x
echo `date` ===============================
echo "============================================================="
echo "System Storage"
echo "============================================================="
time df -h
echo "============================================================="
echo "Size of $1"
echo "============================================================="
time du -sh $1
time du -s  $1
echo "============================================================="
echo "Number of Files in $1"
echo "============================================================="
time find $1  -name "*" -type f | wc -l
echo `date` ===============================
date
