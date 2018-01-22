#!/bin/bash
echo 'Cleaning up leftover files from upgrade...'
sudo rm -rf /var/opt/gitlab/postgresql/data.9.2.18
