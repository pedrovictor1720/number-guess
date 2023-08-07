#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=users -t --no-align -c"

#LÊ O NOME DO USUÁRIO
echo "Enter your username:"
read NAME

#PESQUISA SE ELE JÁ TEM CADASTRO NO SISTEMA
SEARCH=$($PSQL "SELECT username,games_played,best_game FROM users WHERE username='$NAME'")

#CASO O USUÁRIO AINDA NÃO ESTEJA CADASTRADO...
if [[ -z $SEARCH ]]
then
  echo "Welcome, $NAME! It looks like this is your first time here."
  INSERT_DATA=$($PSQL "INSERT INTO users(username,games_played) VALUES('$NAME',1)")

else
  #CASO ELE JÁ TENHA UM CADASTRO
  SEARCH_NM=$($PSQL "SELECT username FROM users WHERE username='$NAME'")
  SEARCH_GP=$($PSQL "SELECT games_played FROM users WHERE username='$NAME'")
  SEARCH_BG=$($PSQL "SELECT best_game FROM users WHERE username='$NAME'")
  echo "Welcome back, $SEARCH_NM! You have played $SEARCH_GP games, and your best game took $SEARCH_BG guesses."
  SEARCH_GP=$(( $SEARCH_GP + 1 ))
  INSERT_DATA=$($PSQL "UPDATE users SET games_played=$SEARCH_GP WHERE username='$NAME'")
fi

#GERA O NÚMERO ALEATÓRIO
TIMES=0
NUMBER_RANDOM=$(( RANDOM % 1000 + 1 ))
echo $NUMBER_RANDOM
echo "Guess the secret number between 1 and 1000:"

#FUNÇÃO QUE VERIFICA SE O USUÁRIO ACERTOU O NÚMERO ALEATÓRIO
GUESS_MENU() {

  while [[ $NUMBER -ne $NUMBER_RANDOM ]]
  do
    read NUMBER
    #CONFERE SE O VALOR DIGITADO É UM NÚMERO INTEIRO
    if [[ $NUMBER =~ (^[0-9]+$) ]]
    then
      TIMES=$(( $TIMES + 1 ))

      #SE FOR MENOR QUE O NÚMERO...
      if [[ $NUMBER < $NUMBER_RANDOM ]]
      then
        echo -e "It's higher than that, guess again:"

      elif [[ $NUMBER > $NUMBER_RANDOM ]]
      then
        echo -e "It's lower than that, guess again:"
      
      elif [[ $NUMBER == $NUMBER_RANDOM ]]
      then 
        echo "You guessed it in $TIMES tries. The secret number was $NUMBER_RANDOM. Nice job!"
        TEST=$($PSQL "Select * FROM users WHERE username='$NAME' AND best_game IS NOT NULL")
        if [[ -z $TEST ]]
        then
          INSERT_DATA_F=$($PSQL "UPDATE users SET best_game=$TIMES WHERE username='$NAME'")
        else
          INSERT_DATA_F=$($PSQL "UPDATE users SET best_game=$TIMES WHERE best_game > $TIMES AND username='$NAME'")
        fi
      fi
    else
      echo "That is not an integer, guess again:" 
    fi
  done
}

GUESS_MENU
