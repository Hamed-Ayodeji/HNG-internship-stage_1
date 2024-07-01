#!/bin/bash

# Step 1: Check if the script is being run as root, if not, request root access
echo "################# Checking if the script is being run as root..."
if [[ "$(id -u)" -ne 0 ]]; then
  echo "This script needs to be run as root. Trying to elevate privileges..."
  exec sudo -E "$0" "$@"
fi

# Step 2: Create the log and password files and set appropriate permissions
echo "################# Creating log and password files..."
log_file="/var/log/user_management.log"
password_file="/var/secure/user_passwords.txt"
touch "$log_file"
touch "$password_file"

echo "################# Setting permissions..."
chmod 640 "$log_file" # Only root and members of root's group can read and write, others cannot access
chmod 600 "$password_file" # Only root can read and write

# Step 3: Log all the commands and their output to the file in /var/log/ called user_management.log
echo "################# Logging all the commands and their output..."
exec > >(tee -a "$log_file") 2>&1

# Step 4: Prompt the user to enter the name of the file containing the list of users and groups if not provided as an argument
echo "################# Prompting for the file containing the list of users and groups..."
user_file=$1
if [[ -z "$user_file" ]]; then
  read -p "Enter the name of the file containing the list of users and groups with its full path: " user_file
fi

# Step 5: Check if the file exists, if not exit the script, else proceed
echo "################# Checking if the file exists..."
if [[ ! -f "$user_file" ]]; then
  echo "################ Error: The file does not exist. Please provide a valid file name."
  exit 1
else
  echo "################ File exists. Proceeding with the script..."
fi

# Step 6: Create a function to create random passwords for the users
echo "################# Creating a function to generate random passwords..."
generate_password() {
  # Generate a random password using openssl
  openssl rand -base64 12
}

# Step 7: Read the file line by line and create users with a home directory and random password and add them to the appropriate groups
echo "################# Reading the file and creating users..."
while IFS=";" read -r username group
do
  # Check if the user already exists
  if id "$username" &>/dev/null; then
    echo "User $username already exists. Skipping..."
  else
    # Generate a random password
    password=$(generate_password)
    # Create the user with the generated password
    useradd -m -p "$password" "$username"
    echo "User $username created with password: $password"
    # Add the user to the specified group
    usermod -aG "$group" "$username"
    echo "User $username added to group $group"
    # Store the username and password in the password file
    echo "$username:$password" >> "$password_file"
  fi
done < "$user_file"