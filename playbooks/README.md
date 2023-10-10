# Playbooks

## Deploy ROSA
This is a basic playbook that runs the rh.rosa.create role

## Destroy ROSA
This is a basic playbook that runs the rh.rosa.delete role

## Bootstrap Hub
This playbook runs all the neccessary tasks to bootstrap a Hub ROSA instance once it has been deployed

Optional variables:
 - `ssh_privatekey` - Used for ArgoCD private git repository configuration

## Bootstrap Spoke
This playbook runs all the neccessary tasks to bootstrap a Spoke ROSA instance once it has been deployed
