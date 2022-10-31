#!/bin/bash
# Show, select and install the version of OpenJDK available in the repository.
# Author @ : ultimaa@gmail.com
# GitHub : https://github.com/Ultimaa

#checks the permissions
if [ $EUID != 0 ]
then
    echo "Use this script as root or with the sudo prefix."
    exit
fi
#check if apt exists 
if [[ -z $(which apt) ]]
then
    echo "You do not have apt installed. You are probably not using a Debian/Ubuntu based system."
    exit
fi
apt update -qq
available_java_versions=($(apt-cache search --names-only 'openjdk-[1-9]+-jdk$' | awk '{print $1}' | grep -Eo '[1-9]+' | sort -n))
#check if the repository contains any version that can be installed
if [ -z $available_java_versions ]
then
    echo "You do not have in the source list any repository on which the openJDK is listed. Add the official repositories suitable for your system and try again."
    exit
fi
echo "Available OpenJDK versions in your system's repository are:" 
j=0;
for i in "${available_java_versions[@]}"
do
    echo "$j. OpenJDK - $i"
    let j++
done

echo "Choose which version of the JDK you want to install or type 'exit' to finish script: "
 
while true
do
    read selection
    if [ "$selection" = "exit" ]
    then
    exit
    fi

    if [ $selection -ge 0 ] && [ $selection -lt $j ]
    then
    break
    fi
    echo "You have selected an unavailable option."
done

apt install openjdk-${available_java_versions[$selection]}-jdk -y
if [ "$(dpkg -l | awk "/openjdk-${available_java_versions[$selection]}-jdk/ {print }"|wc -l)" -ge 1 ]
then
    echo "Correctly installed OpenJDK version :"
    javac -version
else
    echo "Installation failed."
fi
