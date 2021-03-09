echo "sudo su<<-EOF" > scp.txt
while IFS= read -r line; 
do
 echo "scp -o StrictHostKeyChecking=no -i console-zdm-ssh-key-2021-03-04.key oracle@$line:/home/oracle/part1.txt /tmp/part1-$line.txt" >> scp.txt
done<servers_ip.txt
echo "EOF" >> scp.txt
source scp.txt
sudo su<<EOF
chmod ugo+rw /tmp/*
chown oracle:oracle /tmp/*
EOF

