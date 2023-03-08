#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --tuples-only -c"

if [[ $1 ]]
then
  #check if atomic number
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    ELEMENT=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE atomic_number=$1")
    PROPERTIES=$($PSQL "SELECT atomic_mass, melting_point_celsius, boiling_point_celsius, type_id FROM properties WHERE atomic_number=$1")
    TYPES=$($PSQL "SELECT type FROM types WHERE type_id=(SELECT type_id FROM properties WHERE atomic_number=$1)")
  else
    #check if symbol/name
    ELEMENT=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE name='$1' OR symbol='$1'")
    PROPERTIES=$($PSQL "SELECT atomic_mass, melting_point_celsius, boiling_point_celsius, type_id FROM properties JOIN elements USING(atomic_number) WHERE elements.name='$1' OR elements.symbol='$1'")
    TYPES=$($PSQL "SELECT type FROM types WHERE type_id=(SELECT type_id FROM properties WHERE atomic_number=(SELECT atomic_number FROM elements WHERE name='$1' OR symbol='$1'))")
  fi
    if [[ -z $ELEMENT ]]
    then
      echo I could not find that element in the database.
      exit
    else
      echo $ELEMENT  | while IFS=" |"  read atom_num sym name
        do
          echo $TYPES | while IFS=" |" read type_name
            do
              echo $PROPERTIES | while IFS=" |" read atom_mass melt_point boil_point type_id
              do
                echo "The element with atomic number $atom_num is $name ($sym). It's a $type_name, with a mass of $atom_mass amu. $name has a melting point of $melt_point celsius and a boiling point of $boil_point celsius."
              done
            done
        done
    fi
else
  echo Please provide an element as an argument.
fi



  
  
