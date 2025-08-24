This batch file backs up FireFox profiles to date-labeled Zip files (profilename-YYYY-MM-DD.zip). It tests to see whether Firefox is running and prompts the user to close it before performing a backup.

To use:

1. Set the profile folder, backup folder, and number of backups to retain in the CONFIGURATION section of the file.
2. Schedule a task to make backups on a regular basis.

The file uses Powershell to create the archives. I created this for my own personal use and thought it might be useful to others.
