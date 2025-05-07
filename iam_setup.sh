#!/bin/bash

# Initialize variable for file containing user details
file=$1
PASSWORD="ChangeMe123"
LOG_FILE="iam_setup.log"


# Set the file to use users.txt if not provided
if [ -z "$file" ]; then
  file="users.txt"
fi

# Check if the file exists
if [ ! -f "$file" ]; then
  echo `date` ": File $file not found!" >> $LOG_FILE
  exit 1
fi

# Read the file line by line while ignoring headers
while IFS=, read -r username fullname group; 
do

    # Check if the username is not empty
    if [ -z "$username" ]; then
        echo `date` ": Skipping empty username" >> $LOG_FILE
        continue
    fi
    
    # Check if the group is not empty
    if [ -z "$group" ]; then
        echo `date` ": Skipping empty group" >> $LOG_FILE
        continue
    fi

    # Check if group exists
    if [[ $(getent group "$group" | wc -l) -eq 0 ]]; then
        echo `date` ": Group $group does not exist. Creating it." >> $LOG_FILE
        sudo groupadd "$group"
    fi

    # Check if the user exists
    if [[ $(getent passwd "$username" | wc -l) -eq 0 ]]; then

        # Create the user and set temporary password

        # Create the user with the specified username, full name, and group
        sudo useradd -m -s /bin/bash -G "$group" -c "$fullname" "$username"
        echo `date` ": User $username created and added to group $group." >> $LOG_FILE

        # Set the password for the user
        echo "$username:$PASSWORD" | sudo chpasswd
        echo `date` ": Password for user $username set to $PASSWORD." >> $LOG_FILE
        
        # Force password change on first login
        sudo chage -d 0 "$username"
        echo `date` ": User $username must change password on first login." >> $LOG_FILE
        
        # Set permissions for the home directory
        sudo chmod 700 "/home/$username"
        echo `date` ": Permissions for /home/$username set to 700." >> $LOG_FILE
    else
        echo "User $username already exists. Adding to group $group." >> $LOG_FILE
        sudo usermod -aG "$group" "$username"
    fi
done < $(tail -n +2 "$file")
