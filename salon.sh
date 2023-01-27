#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "Welcome to My Salon, how can I help you?" 
  
  # Get services
  SALON_SERVICES=$($PSQL "SELECT * FROM services")

  # if service is not available
  if [[ -z SALON_SERVICES ]]
  then
    # send to main menu
    EXIT "We are closed today, please come back later"
  else
    # Show the services
    
    echo "$SALON_SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done
  fi
  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
    1) SERVICES_MENU ;;
    2) SERVICES_MENU ;;
    3) SERVICES_MENU ;;
    4) SERVICES_MENU ;;
    5) SERVICES_MENU ;;
    6) EXIT ;;
    *) MAIN_MENU "I could not find that service. What would you like today?\n" ;;
  esac
}

SERVICES_MENU() {
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")
  # if input is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # Send to Service Menu
    MAIN_MENU "That is not a valid input, please select again."
  else
    # Ask for their phone number
      echo -e "What's your phone number"
      read CUSTOMER_PHONE

      # check if phone number exist
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_NAME ]]
      then
        # Ask for their name
        echo -e "\nWhat's your name?"
        read CUSTOMER_NAME

        # insert new customer
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      fi

      # Ask for appointment time
      echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
      read SERVICE_TIME

      # get customer_id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name = '$CUSTOMER_NAME'")

      # insert appointment
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")

      # confirmation of appointment and exit
      echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME., $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
  fi
  
}

EXIT() {
  echo -e "\nThank you for stopping in.\n"
}

MAIN_MENU