#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~ Salon Appointment Scheduler ~~~"

MAIN_MENU() {

  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # show available services
  AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services")
  echo -e "\nAvailable services:"
  echo "$AVAILABLE_SERVICES" | while read ID bar NAME
  do
    echo "$ID) $NAME"
  done

  # get service selected
  echo -e "\nSelect service:"
  read SERVICE_ID_SELECTED;

  # check if service available
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  # if service not available
  if [[ -z $SERVICE_NAME ]]
  then
    # back to main menu
    MAIN_MENU "Service selected not available"
  else
    # format service name
    SERVICE_NAME_FMT=$(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') 
    # ask for phone number
    echo -e "\nEnter phone number:"
    read CUSTOMER_PHONE;
    # check if customer already registered
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    # if not registered
    if [[ -z $CUSTOMER_ID ]]
    then
      # ask for name
      echo -e "\nPlease enter your name"
      read CUSTOMER_NAME
      # register new customer 
      INSERT_CUSTOMER $CUSTOMER_PHONE $CUSTOMER_NAME
      CUSTOMER_ID=$? 
    else
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
    fi
    # format customer name
    CUSTOMER_NAME_FMT=$(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g') 
    # ask for service time
    echo -e "\nEnter date and time for appointment:"
    read SERVICE_TIME
    # Enter new record in appointments
    APPOINTMENT_INSERT_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
    # Confirm appointment to the customer
    echo -e "\nI have put you down for a $SERVICE_NAME_FMT at $SERVICE_TIME, $CUSTOMER_NAME_FMT."
  fi
}

INSERT_CUSTOMER() {
  INSERT_RESULT=$($PSQL "INSERT INTO customers(phone,name) VALUES('$1','$2')")
  ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$1'")
  return $ID
}


MAIN_MENU
