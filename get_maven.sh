#!/bin/bash
if [ $EUID != 0 ]
then
    echo "Use this script as root or with the sudo prefix."
    exit
fi

newest_version=$(curl -s https://maven.apache.org/download.cgi | grep -Eo 'Maven ([1-9]).([0-9]+).([0-9]+)' | head -1 | awk '{print $2}')
echo "Newest maven version is: $newest_version"


javac=$(javac -version)
pat='^javac ([1-9]+).([0-9]+).([0-9]+)'
if ! [[ $javac =~ $pat ]]
then
    echo -e "No Java JDK installed which is required for correct functioning."
    echo -e "You can use my script to install java or do it yourself and go back to install maven. \n"
    echo -e "Would you like to do it with my script? ( Type \e[1m \"yes\" \e[0m to proceed, or type anything else to exit)"
    read decision
    case $decision in
        yes)
            wget https://raw.githubusercontent.com/Ultimaa/BashScriptForDeb/main/get_java.sh -P /tmp
            chmod +x /tmp/get_java.sh
            /tmp/get_java.sh
            rm /tmp/get_java.sh
            if ! [[ $javac =~ $pat ]]
            then
            echo "Failed to install the JDK from a script, try again yourself and go back to install Maven."
            exit
            fi
            ;;
        *)
            exit
            ;;               
    esac
fi

wget "https://dlcdn.apache.org/maven/maven-${newest_version:0:1}/$newest_version/binaries/apache-maven-$newest_version-bin.tar.gz" -P /tmp
tar xf /tmp/apache-maven-*.tar.gz -C /opt
ln -s /opt/apache-maven-"$newest_version" /opt/maven
touch /etc/profile.d/maven.sh
openjdkv=$(javac -version 2>&1 | grep -oP 'javac "?(1\.)?\K\d+')
echo "export JAVA_HOME=/usr/lib/jvm/java-$openjdkv-openjdk-amd64" >> /etc/profile.d/maven.sh
echo "export M2_HOME=/opt/maven" >> /etc/profile.d/maven.sh
echo "export MAVEN_HOME=/opt/maven" >> /etc/profile.d/maven.sh
echo "export PATH=\${M2_HOME}/bin:\${PATH}" >> /etc/profile.d/maven.sh
chmod +x /etc/profile.d/maven.sh
source /etc/profile.d/maven.sh
mvn -version