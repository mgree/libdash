#!/bin/sh

echo "TESTING test.native"
for f in tests/*
do
    ./round_trip.sh ./test.native $f 2>test.err
done

echo "TESTING test.byte"
for f in tests/*
do
    ./round_trip.sh ./test.byte $f 2>test.err
done

