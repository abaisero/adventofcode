#!/bin/bash

for f in $(find . -name '[0-9][0-9].rb' | sort); do
  echo "==============="
  echo "running $f"
  echo "==============="
  $f
done

exit 0
