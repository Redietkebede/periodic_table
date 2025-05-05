#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Check for no argument
if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit
fi

INPUT=$1

# Determine search condition based on input type
if [[ $INPUT =~ ^[0-9]+$ ]]; then
  SEARCH_CONDITION="e.atomic_number = $INPUT"
elif [[ $INPUT =~ ^[A-Z][a-z]?$ ]]; then
  SEARCH_CONDITION="e.symbol = '$INPUT'"
else
  SEARCH_CONDITION="e.name = '$INPUT'"
fi

# Query element info
ELEMENT=$($PSQL "
  SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, 
         p.melting_point_celsius, p.boiling_point_celsius
  FROM elements e
  JOIN properties p ON e.atomic_number = p.atomic_number
  JOIN types t ON p.type_id = t.type_id
  WHERE $SEARCH_CONDITION
")

# If no result
if [[ -z $ELEMENT ]]; then
  echo "I could not find that element in the database."
  exit
fi

# Parse and format output
echo "$ELEMENT" | while IFS='|' read -r ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELT BOIL
do
  echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
done
