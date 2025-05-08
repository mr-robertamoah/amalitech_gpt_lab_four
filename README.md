# Project Overview

This project includes a bash script (`iam_setup.sh`) designed to automate user and group management on a Linux system based on a CSV file input.

## Features

- Accepts an optional path to a comma-separated CSV file (defaults to `users.txt` if not provided).
- The CSV file should include `username`, `fullname` and `group` and may include an optional `email` column. When specified, the script sends an email notification to the user with their account details.
- Creates groups if they do not exist and adds users to the specified groups.
- Sets a default temporary password for new users and enforces password change on first login.
- Applies password expiration policies and sets secure permissions on user home directories.
- Logs all operations and events to a log file named `iam_setup.log` in the working directory.
- Contains a `screenshots` directory that stores output images showing users, groups, user home directories, both before and after the script is run.

## Usage

Run the script with or without specifying the path to a CSV file:

```bash
./iam_setup.sh [optional_path_to_csv_file]
```

- If no file path is provided, the script defaults to using `users.txt` in the working directory.
- The CSV file should have columns: `username`, `fullname`, `group`, and optionally `email`.
- If the `email` column is present, users will receive an email with their account details.

## Logging

- All activities and important events are logged to `iam_setup.log` in the working directory for auditing and troubleshooting purposes.

### Log Entry Structure

Each entry in the log file follows this format:

```
YYYY-MM-DD HH:MM:SS : Description of the event
```

Example entries:

```
<timestamp> : <message>.
```

## Screenshots Directory

The `screenshots` directory contains images that visually document the script's execution stages:

- `1 - check for existing users and groups.png`: Displays the initial state of users and groups before the script runs.
- `2 - running of script.png`: Shows the script execution in progress.
- `3 - users and groups created.png`: Shows the users and groups after creation.
- `4 - emails sent.png`: Confirms the sending of email notifications to users.
- `5 - user password enforced.png`: Displays the enforcement of user password policies.


