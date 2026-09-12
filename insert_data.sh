#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Truncate Table
echo $($PSQL "TRUNCATE teams, games;")

# Functions
Insert_Teams() {
  TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$1'")
  if [[ -z $TEAM_ID ]] 
  then
    INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$1')")
    if [[ $INSERT_TEAM == "INSERT 0 1" ]]
    then
      echo "Inserted: Team $1" >&2
    else
      echo "Failed Insert: Team $1" >&2
    fi
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$1'")
  fi

  echo "$TEAM_ID"
}

# insert values
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    # check team ID
    WINNER_ID=$(Insert_Teams "$WINNER")
    OPPONENT_ID=$(Insert_Teams "$OPPONENT")

    # insert into game
    INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_GAME == "INSERT 0 1" ]]
    then
      echo "Inserted: $YEAR $ROUND"
    fi
  fi
done

