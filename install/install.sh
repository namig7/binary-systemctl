#! /bin/bash

# MIT License
# Copyright (c) 2022
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

CYAN='\033[0;36m'
GREEN='\033[1;32m'
NC='\033[0m' # No Color
filename="sample.service"
conf="sample.conf"
lr="samplelr.conf"
search="SERVICE_NAME"
sampleprojectname="PROJECT_NAME"
system="system"
samplename="UNAME"
folderToScan="/home/ubuntu/ms"
folderInstall="/home/ubuntu/install/"
ListFile="/home/ubuntu/install/list"
username="ubuntu"
project="ms"

echo -e "${CYAN}Please Enter the project name:${NC} "
read project

# Reading binary names
echo -e "${BLUE}$(date +'%Y/%m/%d %H:%M:%S:%3N')${NC}     Reading binary names... "
echo -ne "${BLUE}[#####                  ]${NC}   (33%)\r"
cd $folderToScan
echo -ne "${BLUE}[#############          ]${NC}   (66%)\r"
ls -d */ | cut -f1 -d'/' >> $ListFile
cd $folderInstall
mkdir ready/
echo -ne "${BLUE}[#######################]${NC}   ${GREEN}(100%)${NC} - Done\r"
echo -ne '\n'

# Configuration of the binaries as a systemctl

while read -r system; do
    
    echo -e "${BLUE}$(date +'%Y/%m/%d %H:%M:%S:%3N')${NC}     Configuring $system service"
    
    # Creating temporary files
    echo -e "${BLUE}$(date +'%Y/%m/%d %H:%M:%S:%3N')${NC}     Creating temporary files:"
    echo -ne "${BLUE}[                       ]${NC}   (0%)\r"
    
    mkdir "ready/$system/"
    cp "./$filename" "./ready/$system/$system.service"
    echo -ne "${BLUE}[#####                  ]${NC}   (25%)\r"
    cp "./$conf" "./ready/$system/$system.conf"
    echo -ne "${BLUE}[###########            ]${NC}   (50%)\r"
    cp "./$lr" "./ready/$system/$system-lr.conf"
    echo -ne "${BLUE}[################       ]${NC}   (75%)\r"
    cd "./ready/$system/"
    echo -ne "${BLUE}[#######################]${NC}   ${GREEN}(100%)${NC} - Done\r"
    echo -ne '\n'
    
    
    # Creating systemctl service file
    echo -e "${BLUE}$(date +'%Y/%m/%d %H:%M:%S:%3N')${NC}     Creating Systemctl service file:"
    echo -ne "${BLUE}[                       ]${NC}   (0%)\r"
    if [[ $samplename != "" && $username != "" ]]; then
        sed -i "s/$samplename/$username/g" "$system.service"
    fi
    echo -ne "${BLUE}[#####                  ]${NC}   (33%)\r"
    if [[ $search != "" && $system != "" ]]; then
        sed -i "s/$search/$system/g" "$system.service"
    fi
    echo -ne "${BLUE}[#############          ]${NC}   (66%)\r"
    if [[ $sampleprojectname != "" && $project != "" ]]; then
        sed -i "s/$sampleprojectname/${project^^}/g" "$system.service"
    fi
    echo -ne "${BLUE}[#######################]${NC}   ${GREEN}(100%)${NC} - Done\r"
    echo -ne '\n'
    
    
    # Preparing rsyslog configuration file
    echo -e "${BLUE}$(date +'%Y/%m/%d %H:%M:%S:%3N')${NC}     Preparing rsyslog configuration file: "
    echo -ne "${BLUE}[                       ]${NC}   (0%)\r"
    if [[ $search != "" && $system != "" ]]; then
        sed -i "s/$search/$system/g" "$system.conf"
    fi
    echo -ne "${BLUE}[###########            ]${NC}   (50%)\r"
    if [[ $sampleprojectname != "" && $project != "" ]]; then
        sed -i "s/$sampleprojectname/${project,,}/g" "$system.conf"
    fi
    echo -ne "${BLUE}[#######################]${NC}   ${GREEN}(100%)${NC} - Done\r"
    echo -ne '\n'
    
    
    # Preparing logrotate configuration file
    echo -e "${BLUE}$(date +'%Y/%m/%d %H:%M:%S:%3N')${NC}     Preparing logrotate configuration file: "
    echo -ne "${BLUE}[                       ]${NC}   (0%)\r"
    if [[ $search != "" && $system != "" ]]; then
        sed -i "s/$search/$system/g" "$system-lr.conf"
    fi
    echo -ne "${BLUE}[###########            ]${NC}   (50%)\r"
    if [[ $sampleprojectname != "" && $project != "" ]]; then
        sed -i "s/$sampleprojectname/${project,,}/g" "$system-lr.conf"
    fi
    cp "$(pwd)/$system-lr.conf" "/etc/logrotate.d/"
    echo -ne "${BLUE}[#######################]${NC}   ${GREEN}(100%)${NC} - Done\r"
    echo -ne '\n'
    
    
    # End of configuration preparing process
    cd ../../
    
    
    # Enabling systemctl service
    echo -e "${BLUE}$(date +'%Y/%m/%d %H:%M:%S:%3N')${NC}     Enabling systemctl service: "
    echo -ne "${BLUE}[                       ]${NC}   (0%)\r"
    cp "$(pwd)/ready/$system.service" "/etc/systemd/system/"
    echo -ne "${BLUE}[#####                  ]${NC}   (33%)\r"
    systemctl daemon-reload
    echo -ne "${BLUE}[#############          ]${NC}   (66%)\r"
    systemctl enable "$system.service"
    echo -ne "${BLUE}[#######################]${NC}   ${GREEN}(100%)${NC} - Done\r"
    echo -ne '\n'
    
done < "$ListFile"


# Creating and setting up common folder for rsyslog
mkdir "/var/log/${project,,}/"
chown -R syslog:syslog "/var/log/${project,,}"

while read -r system; do
    
    # Setting up rsyslog
    echo -e "${BLUE}$(date +'%Y/%m/%d %H:%M:%S:%3N')${NC}     Setting up rsyslog for $system: "
    echo -ne "${BLUE}[                       ]${NC}   (0%)\r"
    mkdir "/var/log/${project,,}/$system"
    echo -ne "${BLUE}[#####                  ]${NC}   (33%)\r"
    chown -R syslog:syslog "/var/log/${project,,}/$system"
    echo -ne "${BLUE}[#############          ]${NC}   (66%)\r"
    cp "$(pwd)/ready/$system.conf" "/etc/rsyslog.d/"
    systemctl restart rsyslog.service
    echo -ne "${BLUE}[#######################]${NC}   ${GREEN}(100%)${NC} - Done\r"
    
    systemctl start "$system"
    
done < "$ListFile"

while read -r system; do
    
    # Setting up logrotate
    echo -e "${BLUE}$(date +'%Y/%m/%d %H:%M:%S:%3N')${NC}     Setting up logrotate for $system: "
    echo -ne "${BLUE}[                       ]${NC}   (0%)\r"
    logrotate /etc/logrotate.d/"$system-lr.conf"
    echo -ne "${BLUE}[#######################]${NC}   ${GREEN}(100%)${NC} - Done\r"
    
    
    # Removing temporary files
    echo -e "${BLUE}$(date +'%Y/%m/%d %H:%M:%S:%3N')${NC}     Removing temporary files"
    rm -rf ./ready
    echo " "
    
done < "$ListFile"

rm $ListFile

echo -e "${BLUE}$(date +'%Y/%m/%d %H:%M:%S:%3N')${NC}     Congrats! All is set!"