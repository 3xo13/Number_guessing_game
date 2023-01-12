#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\nEnter your username:"
read USERNAME

# checking user status
GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME'")
BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")
# if new user
if [[ -z $GAMES_PLAYED ]]
then
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here.\n"
  echo "Guess the secret number between 1 and 1000:"
  read GUSSED_NUM
else
# if user alredy exist
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  echo "Guess the secret number between 1 and 1000:"
  read GUSSED_NUM

fi

# random number between 1 and 1000
NUM=$((($RANDOM % 1000) + 1))

NUMBER_OF_GUESSES=0

GUESS(){
  # if user input is a number
if [[ $GUSSED_NUM =~ ^[0-9]+$ ]]
then
# increment guessing count for this round
NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))
# if user found the secret number
  if [[ $GUSSED_NUM = $NUM ]]
  then
  # if user played before 
      if [[ $GAMES_PLAYED ]]
      then
        GAMES_PLAYED=$(($GAMES_PLAYED + 1))
        #INSERT_RESULTS=$($PSQL "INSERT INTO users(username,games_played,best_game) VALUES('$USERNAME','$GAMES_PLAYED','$NUMBER_OF_GUESSES')")
        UPDATE_GAMES=$($PSQL "UPDATE users SET games_played = '$GAMES_PLAYED' WHERE username = '$USERNAME' ")
        # check best game 
        RECORD_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")
        
        if [[ $RECORD_GAME -gt $NUMBER_OF_GUESSES ]]
        then
        echo $RECORD_GAME $NUMBER_OF_GUESSES
          UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game = '$BEST_GAME' WHERE username = '$USERNAME' ")
        fi
        echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $GUSSED_NUM. Nice job!"
      # if the user did not play before
      else 
        INSERT_RESULTS=$($PSQL "INSERT INTO users(username,games_played,best_game) VALUES('$USERNAME',1,'$NUMBER_OF_GUESSES')")
        echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $GUSSED_NUM. Nice job!"
      fi
  # if user did not guess the secret number
  else
    if [[ $GUSSED_NUM < $NUM ]]
    then
      echo "It's higher than that, guess again:"
      read GUSSED_NUM
      GUESS
    else
      echo "It's lower than that, guess again:"
      read GUSSED_NUM
      GUESS
    fi
  fi
# if user intered anything other than a number
else
  echo "That is not an integer, guess again:"
  read GUSSED_NUM
  GUESS
fi
}
GUESS








