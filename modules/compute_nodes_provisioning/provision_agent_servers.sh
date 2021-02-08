### copy key for the bastion test server
cp ../../keys/wls-wdt-testkey .
ansible servers   -m ping -i hosts
ansible-playbook -vv -i hosts install_agent.yaml
ansible-playbook -vv -i hosts remove_agent.yaml



ansible servers  -f 50 -m ping -i ansible_hosts.txt
ansible-playbook -vv -f 50 -i ansible_hosts.txt install_agent.yaml
ansible-playbook -vv -f 50 -i ansible_hosts.txt remove_agent.yaml
