#!/bin/bash
# Author: Huy Nguyen .D // Duy Nguyen Duc
# Mini shell linux project: Convert multicast IPv4 to MAC address.
# Do not remove comment

#Script to convert decimal IP to binary

function dectobin()
{
    CONV=({0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1})

    ip=""
    for byte in `echo ${1} | tr "." " "`
    do
        ip="${ip}.${CONV[${byte}]}"
    done
    echo ${ip:1}
}

function iptomac()
{
#Read file line by line
input=$1
while IFS= read -r line
do 
    echo "$line"
    a=`dectobin "${line}"`
    echo ${a}
#Get 23 bit of IPv4 address
    #echo "Binary: ${a:(-25)}" | tr --delete .
    s2=`echo "${a:(-25)}" | tr --delete .`
	echo "${s2}"
#Convert 24 bit to hex
    s1=0
    s1+=${s2}
    echo "Binary address:${s1}"

    s1=`echo "obase=16;ibase=2;${s1}" | bc`
    echo "Hexa:${s1}"
#Some occation "bc" command does not print "0" in the head of address
    addrlen=`echo ${s1} | awk '{print length}'`
    echo ${s1} | awk '{print length}'
    s2=${s1}
    s3=6
    s4=0
    index=$((${s3}-${addrlen}))
    while [ ${index} -gt 0 ]
    do
	s2=${s4}${s2}
	index=$((${index}-1))
    done
    #if [ ${addrlen} == ${s3} ]
    #then
	#s2=0
	#s2+=${s1}
    #else 
	#s2=${s1}
    #fi
#Add space between two hex
    s2=`echo ${s2} | sed 's/.\{2\}/& /g'`
    echo ${s2} | sed 's/.\{2\}/& /g'
    mac="01 00 5E "
    mac+=${s2}
    echo ${mac}
    echo ${mac} >> iptomac_out
    echo -e '\n'
    echo -e '\n' >> iptomac_out
done < "$input"
}

function mactoip()
{
#Read file line by line
input=$1
while IFS= read -r line
do
    echo "$line"

#Remove space of MAC address
    s2=`echo "${line// /}"` #Remove space
    s2=`echo "${s2:(-6)}"`
    s1=1    
    s1+=${s2}
    s1=`echo "obase=2;ibase=16;${s1}" | bc`
    s1=`echo "${s1:(-23)}"`

    octet2=${s1:0:7}
    octet2=`echo "obase=10;ibase=2;${octet2}" | bc`

    octet3=${s1:7:8}
    octet3=`echo "obase=10;ibase=2;${octet3}" | bc`

    octet4=${s1:15:8}
    octet4=`echo "obase=10;ibase=2;${octet4}" | bc`	    

    ip=224-239
    ip=${ip}.${octet2}.${octet3}.${octet4} 
    echo ${ip}
    echo ${ip} >> mactoip_out
    
    ip=224-239
    bit_24=128
    let octet2=${octet2}+${bit_24}
    ip=${ip}.${octet2}.${octet3}.${octet4} >> mactoip_out
    echo ${ip}
    echo ${ip} >> mactoip_out

    echo -e '\n' >> mactoip_out
done < "$input"
}

function convertmulticast()
{
	if [[ $1 == "-h" ]]
	then
	    echo "NAME"
	    echo "	convertmulticast"
	    
	    echo "DESCIPTION"
	    echo "	Use to convert multicast IP to multicast MAC and contrary"
	
	    echo "EXAMPLE"
	    echo "	convertmulticast -h"
	    echo "		Display information"
	    echo "	convertmulticast -im iptomac_in"
	    echo "		Convert IP to MAC from file iptomac_in"
	    echo "	convertmulticast -mi mactoip_in"
	    echo "		Convert MAC to IP from file mactoip_in"
	    	    
	elif [[ $1 == "-im" ]]
	then
	    iptomac "$2"
	else
	    mactoip "$2"
	fi
}

convertmulticast