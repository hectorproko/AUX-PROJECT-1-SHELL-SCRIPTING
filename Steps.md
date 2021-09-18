

The script in action [video](https://www.youtube.com/watch?v=C48osDrHTxw) Terminal on the right used to connect to remote server and run script. Terminal on the left used to send the script and .txt with names to remote server and later connect as a different user to test newly created users.

# Step 1: Create an EC2 Instance

Before we start we need to have an environemnt to work with. I will we using my AWS account to create an EC2 instance with an Ubuntu Server.

* First thing I'm going to do when I log in to AWS is look for the **EC2** services. There are various methods to navigate to it, here I'm using the **search bar** <br /> 
![Markdown Logo](https://raw.githubusercontent.com/hectorproko/LAMP_STACK/main/images/ec2search.png) <br>

* Once you navigate to the **EC2** page look for a **Launch instance** button <br /> 
![Markdown Logo](https://raw.githubusercontent.com/hectorproko/LAMP_STACK/main/images/launchInstance.png) <br>

* You will then be prompted to pick an OS Image. I will be using **Ubuntu Server 20.04 LTS (HVM), SSD Volume**. Once done click **Select**

* I will pick the **t2.micro** instace type <br /> 
 ![Markdown Logo](https://raw.githubusercontent.com/hectorproko/LAMP_STACK/main/images/t2micro.png) <br>

* I will leave default settings and click **Review and Launch** <br /> 
![Markdown Logo](https://raw.githubusercontent.com/hectorproko/LAMP_STACK/main/images/reviewLaunch.png) <br>

* As you can see we have a Security Group applied to the instance by default which allows SSH connections <br /> 
![Markdown Logo](https://raw.githubusercontent.com/hectorproko/LAMP_STACK/main/images/sshDefault.png) <br>

* After reviewing you can launch your instancing by clicking <br /> 
![Markdown Logo](https://raw.githubusercontent.com/hectorproko/LAMP_STACK/main/images/launch.png) <br>

* We are prompted to create or use an existing Key Pair. I will be creating a new one. I will use this .pem key to SSH into the instance later on. <br /> 
![Markdown Logo](https://raw.githubusercontent.com/hectorproko/LAMP_STACK/main/images/keyPair.png) <br>

* Once you have downloaded your key launch intance <br /> 
![Markdown Logo](https://raw.githubusercontent.com/hectorproko/LAMP_STACK/main/images/LaunchInstances.png) <br>

* To go to the instances dashboard <br /> 
![Markdown Logo](https://raw.githubusercontent.com/hectorproko/LAMP_STACK/main/images/ViewInstances.png) <br>

* If your instance is up and running you will see something like this <br /> 
![Markdown Logo](https://raw.githubusercontent.com/hectorproko/LAMP_STACK/main/images/Running.png) <br>

* To find information on how to connect click on your **Instance ID**

* In the top-right corner you should see the button **Connect**, click on it <br /> 
![Markdown Logo](https://raw.githubusercontent.com/hectorproko/LAMP_STACK/main/images/Connect.png) <br>

* Look for the **SSH client** tab <br /> 
![Markdown Logo](https://raw.githubusercontent.com/hectorproko/LAMP_STACK/main/images/SSHclient.png) <br>

* Under **Example** you'll find an **ssh** command with eveything you need to connect to the instance from a terminal

**Examaple:**
```bash
ssh -i "daro.io.pem" ubuntu@ec2-3-216-90-84.compute-1.amazonaws.com
```
Make sure when you run the command that your current working directory in the terminal is where your KeyPair/.pem is located because in the above example I'm using a relative path to point to my key

* A successful log-in <br /> 
![Markdown Logo](https://raw.githubusercontent.com/hectorproko/LAMP_STACK/main/images/ubunutuLogIn.png) <br>


## Step 2: Transfer Script
For this project I have create two files [names.csv](https://raw.githubusercontent.com/hectorproko/Auxillary-Projects/main/names.csv) and [onboarding_users.sh](https://raw.githubusercontent.com/hectorproko/Auxillary-Projects/main/onboarding_users.sh). The **.csv** files only a list of random names used as input for the **.sh** files that will do the actual job.

To transfer files to remote server I'll use **scp** 
```bash
sudo scp -i "daro.io.pem" onboarding_users.sh names.csv ubuntu@ec2-3-216-90-84.compute-1.amazonaws.com:/home/ubuntu/
```
For the example above to work your current working directory needs to contain the **.pem** key and the two files.


## Step 3: Execute The Script
One the remote server our two files should be located in /home/ubuntu/. To run this script use **sh**
```bash
sh onboarding_users.sh
```
You can check newly created users by getting a list from **/etc/passwd** with the following command
```bash
cat /etc/passwd | awk -F':' '{ print $1}' | xargs -n1
```

## Step 3: Breaking down The Script
To see the whole code [onboarding_users.sh](https://raw.githubusercontent.com/hectorproko/Auxillary-Projects/main/onboarding_users.sh)

```bash
sudo groupadd developer #Adding group
nameList=$(cat ./names.csv) #Putting list of names in variable
groupName="developer" #variable for group name
```

**user_Check** function uses user names as input
```bash
user_Check(){
if [ $(id -u "$1" 2> /dev/null) ]
then
	echo "User $1 does exist" #Output if user exists
	ssh_setup $1 # calls another function with name as input
else
	echo "User $1 does NOT exist"
	echo "Creating $1"
	user_create $1 #calls another function with name as input
	ssh_setup $1 #calls another function with name as input
fi
}
```

Function **user_create** gets an name and creates a user
```bash
user_create(){
sudo useradd -m $1 -p $1 #creating user with name as the password
sudo usermod -g $groupName $1 #Adding user to group
}
```

**ssh_setup** function makes sure user can be connected to through **ssh**
```bash
ssh_setup(){
if [ ! -d "/home/$1/.ssh" ]; then #checkin if .ssh folde exists
  echo ".ssh does not exists."
  echo "Doing .ssh setup for user $1"
  sudo cp -r /home/$USER/.ssh /home/$1/.ssh #we duplicate the .ssh from our current user to the new one
  sudo chown $1 /home/$1/.ssh #we change ownership of the copied .ssh to the newly created user
  sudo chown $1 /home/$1/.ssh/authorized_keys #also changing ownsership 
fi
}
```

The actual part that starts things
```bash
#Itirating through names
for name in $nameList
do
	user_Check $name #Calling a function
done 
```