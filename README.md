# DevOps Stage 1: Automated Linux User Creation

## Overview

In light of our development team's recent expansion, I have developed a Bash script named `create_users.sh`. This script streamlines the process of creating user accounts for new employees by reading their usernames and group memberships from a text file. Each line in this file adheres to the format `user;groups`, simplifying the specification of new users and their associated groups. Notably, a user can belong to multiple groups, delineated by commas, as shown below:

  ```txt
  john;developers,managers
  jane;developers
  ```

### Script Functionality

1. **User and Group Creation:**
   - For each line in the input file, the script creates a new user account, assigning the user to the specified groups.
   - If a specified group does not already exist, the script automatically creates it.
   - Each user has a personal group with the same group name as the username, this group name is not written in the text file.

2. **Home Directory Setup:**
   - The script sets up home directories for each user with the appropriate permissions and ownership.

3. **Password Management:**
   - The script generates a random password for each user.
   - These passwords are securely stored in `/var/secure/user_passwords.txt` in the order of users and their passwords delimited by comma, ensuring that only the file owner has access to them.

4. **Logging:**
   - All operations performed by the script are meticulously logged in `/var/log/user_management.log`, providing a comprehensive record of user account creation and management activities.

5. **Error Handling:**
   - The script is equipped with robust error handling capabilities, ensuring that any issues encountered during execution are promptly identified and resolved. For example, if the user already exists, the script will skip creating the user and log the error.
