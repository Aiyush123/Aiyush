**Monitoring Script Readme**

**Overview**

This script collects system statistics, including CPU usage, memory usage, filesystem usage, and details of the top 5 CPU-consuming processes. The data is output in a structured CSV file format for easy analysis.

**Features**

Collects real-time CPU usage.
Gathers memory statistics (total, used, free, and percentage used).
Records filesystem details (size, used, available, and usage percentage).
Lists the top 5 CPU-consuming processes (PID, Command, and CPU Usage).
Outputs data in a CSV file for easy integration with analysis tools.

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

Save the script as **monitoring_script.sh.**

Grant Execute Permission
Make the script executable by running the following command:

chmod +x monitoring_script.sh

Running the Script
The script can be executed with one or two arguments:

**Option 1**: Provide Duration Only

./monitoring_script.sh <DURATION>

<DURATION>: The duration in seconds for the monitoring interval.

Output file: Defaults to monitoring_report.txt.  can be txt , csv ,json 

**Option 2:** Provide Duration and Output File Name

./monitoring_script.sh <DURATION> <OUTPUT_FILE>
<DURATION>: The duration in seconds for the monitoring interval.
<OUTPUT_FILE>: The name of the output TXT file.
and if we want to run the script in background we can run as ./monitoring_script.sh 5 monitoring_report.txt &
when alert triger it will notify in terminal  and also save alert log with time in alert.log 


**Option 3: Interactive Input**

If no arguments are provided, the script will ask user to give duration only in positive integer and output file path 

Example

./monitoring_script.sh 

This will monitor the system for 60 seconds and save the data in system_report.csv.
