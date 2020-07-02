#!/bin/bash
# Create a valid docker tag from the branch name.

echo -n $CIRCLE_BRANCH | sed 's!/!-!'
