#!/bin/bash

#Variables
DIR=$(dirname "$(readlink -f "$0")")
JavacInstalled=0
wget=0
curl=0
HomeCompiled=0
BuildToolsUrl="https://hub.spigotmc.org/jenkins/job/BuildTools/lastStableBuild/artifact/target/BuildTools.jar"
BuildToolsDownloaded=0
version="0"
#AutoPortForward=0

promptValue() {
 read -p "$1"": " val
 echo $val
 }
#Asks for eula compliance
echo "Do you agree to the minecraft eula? if no then no server for u :( link: https://account.mojang.com/documents/minecraft_eula"
while true; do
    	read -p "Do you agree? " yn
    	case $yn in
        	[Yy]* ) break;;
        	[Nn]* ) exit; break;;
        	* ) echo "Please answer yes or no.";;
    	esac
done
#Checks for java
echo "$(tput setaf 3)Headsup:$(tput sgr0) If you see any spaces in here:"
echo
pwd
echo
echo "Then this script will not work, to fix this you must execute the script from somewhere with no spaces in the working directory. (will fix in the fufture)"
sleep 5
if command -v java >/dev/null 2>&1 ; then
		echo "$(tput setaf 2)Found java"

	else
	    echo "Java not found"
	    echo "You can download the java here: https://www.oracle.com/technetwork/java/javase/downloads/index.html"
	    echo "Java 8 and higher are recommended if you plan on the server to work"
	    echo "Run this script again, after you have installed java."
	    exit
	fi
#Checks for Java Compiler
if command -v javac >/dev/null 2>&1 ; then
		echo "$(tput setaf 2)Found Java Compiler$(tput sgr0)"
		JavacInstalled=1

	else
		echo "$(tput setaf 3)Java Compiler Not Found$(tput sgr0)"
		echo "You can not compile server files without java compiler, however you can still download them from the internet"
		sleep 1.3
		JavacInstalled=0
	fi

#checks for internet connection
nc -z 8.8.8.8 53  >/dev/null 2>&1
online=$?
if [ $online -eq 0 ]; then
    echo "$(tput setaf 2)Found internet connection$(tput sgr0)"
else
    echo "$(tput setaf 2)No internet access, quitting...$(tput sgr0)"
    exit
fi
#checks for wget, and if wget is not found it checks for curl. If none are found the script quits.
if command -v wget >/dev/null 2>&1 ; then
	    echo "$(tput setaf 2)found wget$(tput sgr0)"
	    wget=1

	elif command -v curl >/dev/null 2>&1 ; then
	        	echo "$(tput setaf 2)found curl$(tput sgr0)"
	        	curl=1

	else
		echo "$(tput setaf 1)Looked for both wget and curl, found nothing.$(tput sgr0)"
		echo "You need either wget or curl for this script to be functional."
		echo "If you are on MacOS, all you need to do is open a terminal and type:"
		echo "brew install curl"
		#might add an install script here in the future tho ¯\_(ツ)_/¯
		exit
fi
#Asks if user want to compile server files, and if yes download buildtools and changes variable BuildToolsDownloaded to 1.
if [ $JavacInstalled -eq 1 ] ; then
	while [ $BuildToolsDownloaded -eq 0 ]; do
    	read -p "Do you want to compile the server files yourself? (recommended, but slow)? " yn
    		case $yn in
        		[Yy]* ) HomeCompiled=1;;
        		[Nn]* ) BuildToolsDownloaded=2;; #ik this is probably bad, but it a beginner
        		* ) echo "Please answer yes or no.";;
    		esac
    	if [ $HomeCompiled -eq 1 ] ; then
    		if [ $wget -eq 1 ] ; then
    			wget -O BuildTools.jar $BuildToolsUrl
    			BuildToolsDownloaded=1
    		elif [ $curl -eq 1 ] ; then
    			curl -o BuildTools.jar $BuildToolsUrl
    			BuildToolsDownloaded=1
    		fi
    	fi
	done
fi
if [ $BuildToolsDownloaded -eq 1 ] ; then
	version=$(promptValue "$(tput setaf 6)Enter the exact minecraft version you want to install on your server, FYI: If you enter an old version you might run into some java errors. $(tput sgr0)")
	if [ $version == "1.8.9" ] ; then
		echo "$(tput setaf 3)The last server version for 1.8 is 1.8.8, so changing install version to that.(it will work with client version 1.8.9)$(tput sgr0)"
		version="1.8.8"
	fi
	rm -rf BuildTools
	rm -rf minecraft_server
	mkdir BuildTools
	mkdir minecraft_server
	mv BuildTools.jar BuildTools
	cd BuildTools
	echo "$(tput setaf 7)"
	java -jar BuildTools.jar --rev $version --output-dir $DIR/minecraft_server
	echo "$(tput sgr0)"
	cd $DIR
	rm -rf BuildTools
fi

if [ $HomeCompiled -eq 0 ] ; then
	version=$(promptValue "$(tput setaf 6)Enter the exact minecraft version you want to download for your server$(tput sgr0)")
	if [ $version == "1.8.9" ] ; then
		echo "$(tput setaf 3)The last server version for 1.8 is 1.8.8, so changing install version to that.(it will work with client version 1.8.9)$(tput sgr0)"
		sleep 2
		version="1.8.8"
	fi
    rm -rf minecraft_server
    mkdir minecraft_server
    cd minecraft_server
    echo "eula=true" >> eula.txt
	if [ $wget -eq 1 ] ; then
    		wget -O PaperRetriver.jar https://papermc.io/api/v1/paper/$version/latest/download
    		paper=1
    elif [ $curl -eq 1 ] ; then
    		curl -o PaperRetriver.jar https://papermc.io/api/v1/paper/$version/latest/download
    		paper=1
    fi
    rm -rf cache
    java -jar PaperRetriver.jar -NotYetMyYoungPadawan #this is to stop the server from automatically running after patching.
    clear
    rm PaperRetriver.jar
    mv cache/patched_$version.jar $DIR/minecraft_server/Spigotpaper-$version.jar #Ik its a weird name but if it starts with spigot, i can use the same startup script on homecompiled and downloaded servers.
    rm -rf cache
    
fi
echo "Now you must choose how much ram your server is gonna use."
echo "For example, if you want to use one gigabyte of ram, type 1G. if you want 2 gigs you type 2G"
echo "If you want to set a specific amount of megabytes type (for example) 1024M"
echo "Dont use more than 75% of the ram on your computer unless you know what you are doing."
RAM=$(promptValue "So whats it gonna be champ? FYI: G and M needs to be CAPITALIZED. ")
cd $DIR/minecraft_server
echo "java -Xms$RAM -Xmx$RAM -jar Spigot*.jar " >> start.sh
chmod a+x start.sh
echo -e "chmod a+x start.sh\necho 'if it says cannot access start.sh: No such file or directory, be sure cd to minecraft_server before you run this script.'" >> Fix-permissions.sh
echo "To start the server, you need to run the start.sh script in the folder minecraft_server"
sleep 1.5
echo "If you decide to move the server folder after it is setup, you need to run the Fix-permissions.sh script after the file is moved. The Fix-permissions.sh script is located in the minecraft_server folder"
sleep 4

if [ $HomeCompiled -eq 1 ] ; then #Update script compilers
	
	elif [ $paper -eq 1 ] ; then #Update script for downloaders





# while true; do
#     	read -p "Do you want the script to handle portforwarding? " yn
#     	case $yn in
#         	[Yy]* ) AutoPortForward=1; break;;
#         	[Nn]* ) AutoPortForward=0; break;;
#         	* ) echo "Please answer yes or no.";;
#     	esac
# done