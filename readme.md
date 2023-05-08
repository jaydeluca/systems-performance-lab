# Systems Performance Lab

![Eye of Sauron](./media/eye_of_sauron.jpg)

Experimental lab to experiment with observability tools on a raspberry pi.


## Setup
This lab is uses Raspberry PI OS (64-bit)

When creating with Raspberry Pi Imager, add wifi and enable ssh with username and password. will manually add ssh key for ansible use.

@TODO figure out a better way to automate this part

You will need to identify the IP of the raspberry PI, and then add your SSH key to it (if not done during imaging setup for pi)  

Use username you setup in imager step:

`ssh-copy-id -i ~/.ssh/raspberrypi.pub pi@192.168.1.178`


Surf the node to test things manually if needed:
```
ssh-add -K ~/.ssh/raspberrypi
ssh pi@192.168.1.178
```


## Ansible

WIP: You can run the playbooks via a docker container:

```
docker build -t watchtower-ansible -f ansible/Dockerfile .
docker run -v "${PWD}":/workspace:ro -v ~/.ssh:/root/.ssh:ro --rm watchtower-ansible:latest ansible-playbook --inventory-file ansible/inventory/all.ini ansible/bootstrap.yml
```

Or run locally, ensure ansible is setup:

```
python3 -m pip install --user ansible
```

Make sure to update `/ansible/inventory/all.ini` with the IP address of the PI

### Bootstrap Playbook
Run this to do basic setup when first setting up the PI  
* Installs node_exporter process on the pi for us to collect infrastructure metrics on it
* Installs docker daemon for running containers
* Configures Prometheus and starts up container
* Configures linux performance tools

```
ansible-playbook --inventory-file ansible/inventory/all.ini ansible/bootstrap.yml --ask-become-pass
```

Setup and configure other stuff:

* Sets up Postgres and postgres-exporter

```
ansible-playbook --inventory-file ansible/inventory/all.ini ansible/postgres.yml
```

Updating Prometheus Config, restarting:
```
ansible-playbook --inventory-file ansible/inventory/all.ini ansible/prometheus.yml --start-at-task="Setup Prometheus Config file"
```

## Prometheus
Docker up up and away

It will run on your computer and scrape metrics from the PI.

Update `prometheus/config/prometheus.yml` with IP address of pi.


## Grafana
To recreate container and pull in new configs:
```
docker-compose up -d --no-deps --build --force-recreate grafana
```

Access at [http://localhost:3000/login](http://localhost:3000/login)

admin/admin

## Troubleshooting

Not seeing metrics?

```
systemctl status prometheus
journalctl -u prometheus.service
```

If you see "cannot execute binary file: Exec format error" it likely means you're using a 32 bit OS and you should switch to 64.


## TODO

- [ ] Make it easier to bootstrap with a new IP without having to update several files
- [ ] Automate addition of SSH key to server on first use