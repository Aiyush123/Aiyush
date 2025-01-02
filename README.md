**Monitoring Script Readme**

**Overview**

This script collects system statistics, including CPU usage, memory usage, filesystem usage, and details of the top 5 CPU-consuming processes. The data is output in a structured TXT,JSON,CSV file format for easy analysis. And alert are save in alert.log 

**Features**

Collects real-time CPU usage.
Gathers memory statistics (total, used, free, and percentage used).
Records filesystem details (size, used, available, and usage percentage).
Lists the top 5 CPU-consuming processes (PID, Command, and CPU Usage).
Outputs data in a TXT,JSON,CSV file for easy integration with analysis tools.

**Prerequisites**

Ensure the following tools are available on your system:

Bash shell
top command
free command
df command
ps command
awk and head utilities

**Usage Instructions**
Script File Name

Save the script as **monitor_script.sh.**

Grant Execute Permission
Make the script executable by running the following command:

chmod +x monitor_script.sh

Running the Script
The script can be executed with one or two arguments:

**Option 1**: Provide Duration Only

**command:** ./monitor_script.sh <DURATION>

<DURATION>: The duration in seconds for the monitoring interval.

Output file: Defaults to system_report.txt.  can be txt , csv ,json 

**Option 2:** Provide Duration and Output File Name

**command:** ./monitor_script.sh <DURATION> <OUTPUT_FILE>
<DURATION>: The duration in seconds for the monitoring interval.
<OUTPUT_FILE>: The name of the output TXT file.
and if we want to run the script in background we can run as ./monitor_script.sh 5 system_report.txt &
when alert triger it will notify in terminal  and also save alert log with time in alert.log 


**Option 3: Interactive Input**

If no arguments are provided only ./monitor_script.sh, the script will ask user to give duration only in positive integer and output file path 

Example
**command :** ./monitor_system.sh
No arguments provided. Enter details interactively:
Enter monitoring interval in seconds (default: 5): 2
Enter output format (text, json, csv - default: text): text
Monitoring system performance every 2 seconds. Press Ctrl+C to stop.


This will monitor the system and save the data in system_report.csv.

**Option 4: live monitoring (real-time CLI graph wit)**

Save the script monitor_visualization.sh
give executable permission 
chmod +x monitor_visualization.sh 

**command :** ./monitor_visualization.sh (if you run this it will take defaut intervel time for rel time graf as 0.5 millsec)
if you want to change its intervel run command:

**command:** ./monitor_visualization.sh 0.1

