#!/bin/zsh



docker run -v "${PWD}":/workspace:ro -v ~/.ssh:/root/.ssh:ro --rm watchtower-ansible:latest ansible-playbook --inventory-file ansible/inventory/all.ini ansible/bootstrap.yml