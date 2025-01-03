#!/bin/bash

# Define the database connection command
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Check if an argument is provided
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit
fi

# Determine if input is numeric or not
if [[ $1 =~ ^[0-9]+$ ]]
then
  QUERY="WHERE elements.atomic_number = $1"
else
  QUERY="WHERE elements.symbol ILIKE '$1' OR elements.name ILIKE '$1'"
fi

# Query the database based on the input
ELEMENT_INFO=$($PSQL "
  SELECT elements.atomic_number, elements.name, elements.symbol, types.type, properties.atomic_mass, 
         properties.melting_point_celsius, properties.boiling_point_celsius
  FROM elements
  JOIN properties ON elements.atomic_number = properties.atomic_number
  JOIN types ON properties.type_id = types.type_id
  $QUERY;
")

# Check if the element exists in the database
if [[ -z $ELEMENT_INFO ]]
then
  echo "I could not find that element in the database."
else
  # Parse the result into variables
  IFS="|" read -r ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING_POINT BOILING_POINT <<< "$ELEMENT_INFO"

  # Output the element information
  echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
fi
