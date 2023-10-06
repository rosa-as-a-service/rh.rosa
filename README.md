# Ansible Collection - rh.rosa

Role Name
=========

- create_rosa

    This playbook creates the following:

    - STS Roles and Policies required to install and support a ROSA STS Cluster
    - A ROSA STS PrivateLink Cluster
    - Operator Roles and Policies to operate a ROSA STS Cluster
    - OIDC provider to provide trust to Roles

- delete_rosa

    This playbook deletes all resources created by the **create_rosa** playbook


Requirements
------------

- An AWS IAM account with sufficient permissions to create a ROSA cluster [^1]

- Thoroughly read and understand the [Red Hat Openshift Service on AWS](https://docs.aws.amazon.com/ROSA/latest/userguide/what-is-rosa.html) documentation

- Complete the [ROSA getting started](https://console.redhat.com/openshift/create/rosa/getstarted) requirements

    You must complete some AWS account and local configurations to create and managed ROSA clusters.

- An offline OCM token

    This token is generated through the Red Hat Hybrid Cloud Console. The purpose of this token is to verify that you have access and permission to create and upgrade clusters. This token is unique to your account and should not be shared.


Role Variables
--------------

- region: "ap-southeast-2"

    The AWS Region that the resources will be deployed into
- aws_access_key_id: "{{ secret_aws_access_key_id }}"

    The AWS Access Key with sufficient permissions to create a ROSSA cluster
- aws_secret_access_key: "{{ secret_aws_secret_access_key }}"

    The AWS Access Key with sufficient permissions to create a ROSSA cluster
- rosa_token: "{{secret_rosa_token}}"
    The offline OCM token

- rosa_version: "4.13.10"

- work_dir: /var/tmp/


Dependencies
------------
Galaxy Collections:
- cloud.terraform 1.1.1  

Terraform Providers:
- terraform-redhat/rhcs: >= 1.4.0-prerelease.2
- terraform-redhat/rosa-sts/aws: >=0.0.13
- hashicorp/aws: >= 3.28

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: ansible
      roles:
         - role: create_rosa

License
-------

BSD
