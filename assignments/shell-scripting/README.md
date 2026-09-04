# System Information Script

A shell script that prints basic system information, takes input from the user, creates a directory and file, and saves the running processes into that file using output redirection.

## What the script does
- Prints the current date
- Prints the hostname
- Prints the username
- Prints the disk usage
- Prints the running processes
- Uses variables to store and reuse data
- Takes user input using `read -p`
- Creates a directory using `mkdir`
- Creates a file using `touch`
- Saves the running processes into the file using `>` output redirection

## Commands used
`mkdir`, `touch`, `echo`, `df`, `ps`, `read -p`, variables, `>` output redirection

## The script (sysinfo.sh)
```bash
#!/bin/bash
# System Information Script

# Store data in variables
CURRENT_DATE=$(date)
HOST_NAME=$(hostname)
USER_NAME=$(whoami)

echo "=============================="
echo " SYSTEM INFORMATION"
echo "=============================="

echo "Current Date : $CURRENT_DATE"
echo "Hostname     : $HOST_NAME"
echo "Username     : $USER_NAME"

echo ""
echo "----- Disk Usage -----"
df -h

echo ""
echo "----- Running Processes -----"
ps aux

# Take input from the user
read -p "Enter a name for the report directory: " DIR_NAME
read -p "Enter a name for the report file: " FILE_NAME

# Create directory and file
mkdir -p "$DIR_NAME"
touch "$DIR_NAME/$FILE_NAME"

# Store running processes in the file using output redirection
ps aux > "$DIR_NAME/$FILE_NAME"

echo ""
echo "Running processes saved to: $DIR_NAME/$FILE_NAME"
```

## How to run
```bash
chmod +x sysinfo.sh
./sysinfo.sh
```

## Sample output
```text
==============================
 SYSTEM INFORMATION
==============================
Current Date : Fri Sep  4 01:42:31 IST 2026
Hostname     : Parths-MacBook-Air.local
Username     : parthtaneja

----- Disk Usage -----
Filesystem       Size   Used  Avail Capacity iused ifree %iused  Mounted on
/dev/disk3s1s1  494Gi   22Gi  241Gi     9%    364k  2.5G    0%   /

----- Running Processes -----
USER           PID  %CPU %MEM      VSZ    RSS TTY   STAT STARTED      TIME COMMAND
root             1   0.0  0.1 435300800   4000   ??  Ss    09:10   0:01.20 /sbin/launchd
parthtaneja  19982   0.3  0.5 435301248   1472   ??  S     09:38   0:00.15 bash sysinfo.sh
...

Enter a name for the report directory: reports
Enter a name for the report file: processes.txt

Running processes saved to: reports/processes.txt
```

## Result
After running, a `reports/` directory is created containing `processes.txt`, which holds the full `ps aux` output captured with `>` redirection.

## Screenshots

Script run showing the current date, hostname, username, disk usage, and running processes:

![System information output](screenshots/image.png)

End of the process list, the `read -p` input prompts, and the confirmation that the file was saved:

![User input and saved confirmation](<screenshots/image copy.png>)

Contents of the created file, confirming the running processes were saved with `>` redirection:

![Saved processes file](<screenshots/image copy 2.png>)
