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
  echo `date "+%Y-%m-%d %H:%M:%S"` ": File $file not found!" >> $LOG_FILE
  exit 1
fi

# Read the file line by line while ignoring headers
while IFS=, read -r username fullname group email; 
do

    # Check if the username is not empty
    if [ -z "$username" ]; then
        echo `date "+%Y-%m-%d %H:%M:%S"` ": Skipping empty username" >> $LOG_FILE
        continue
    fi
    
    # Check if the group is not empty
    if [ -z "$group" ]; then
        echo `date "+%Y-%m-%d %H:%M:%S"` ": Skipping empty group" >> $LOG_FILE
        continue
    fi

    # Check if group exists
    if [[ $(getent group "$group" | wc -l) -eq 0 ]]; then
        sudo groupadd "$group"
        if [[ $? -ne 0 ]]; then
            echo `date "+%Y-%m-%d %H:%M:%S"` ": Failed to create group $group." >> $LOG_FILE
            exit 1
        fi
        echo `date "+%Y-%m-%d %H:%M:%S"` ": Group $group created." >> $LOG_FILE
    fi

    # Check if the user exists
    if [[ $(getent passwd "$username" | wc -l) -eq 0 ]]; then

        # Create the user and set temporary password

        # Create the user with the specified username, full name, and group
        sudo useradd -m -s /bin/bash -G "$group" -c "$fullname" "$username"
        echo `date "+%Y-%m-%d %H:%M:%S"` ": User $username created and added to group $group." >> $LOG_FILE

        # Set the password for the user
        echo "$username:$PASSWORD" | sudo chpasswd
        echo `date "+%Y-%m-%d %H:%M:%S"` ": Password for user $username set to $PASSWORD." >> $LOG_FILE
        
        # Force password change on first login
        sudo chage -d 0 "$username"
        echo `date "+%Y-%m-%d %H:%M:%S"` ": User $username must change password on first login." >> $LOG_FILE

        # Enhance security by setting password expiration
        sudo chage -M 90 -m 7 -W 14 "$username"
        echo `date "+%Y-%m-%d %H:%M:%S"` ": Password expiration of user $username has been to 90 days, 7 days warning, and 14 days notice." >> $LOG_FILE
        
        # Set permissions for the home directory
        sudo chmod 700 "/home/$username"
        echo `date "+%Y-%m-%d %H:%M:%S"` ": Permissions for /home/$username set to 700." >> $LOG_FILE
        
        # Check if the email is not empty
        if [ -n "$email" ]; then
            # Send email notification to the user
            echo "Hello $fullname,

            Your new account has been created on $(hostname).
            Username: $username
            Temporary password: $PASSWORD

            You will be required to change your password on your first login.

            Thanks,
            Admin Team" | mail -a "From: Robert Amoah <robertamoah.dev@gmail.com>" -s "Your New Linux Account" "$email"
            echo `date "+%Y-%m-%d %H:%M:%S"` ": Email sent to $email." >> $LOG_FILE
        fi
    else
        echo "User $username already exists. Adding to group $group." >> $LOG_FILE
        sudo usermod -aG "$group" "$username"
    fi

    echo -e "\n\n" >> $LOG_FILE
done < <(tail -n +2 "$file")
