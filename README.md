# AUX-PROJECT-1-SHELL-SCRIPTING

In this project we will onboard 20 new Linux users onto a server using a shell script that reads a csv file that contains the first name of the users to be onboarded.
We'll make sure the script
1. Add newly created user to group "developers"
2. Check of existence of user before creating it
3. Ensure the user created has a default home folder
4. Ensure that each user has a .ssh folder within its HOME folder. If it does not exist, then create it.


The script in action [video](https://www.youtube.com/watch?v=C48osDrHTxw) Terminal on the right used to connect to remote server and run script. Terminal on the left used to send the script and .txt with names to remote server and later connect as a different user to test newly created users.

Technologies/Tools used:
* AWS (EC2)
* Ubuntu Server 20.04 LTS
* Bash
* GitBash