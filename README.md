# Ansible Collection - rh.rosa

## Playbooks

### [rh.rosa.deploy_rosa](playbooks/README.md)

Playbook use to provision a ROSA instance

### [rh.rosa.destroy_rosa](playbooks/README.md)

Playbook used to destroy a ROSA instance

## Roles

### [rh.rosa.create](roles/create/README.md)

This Role creates the following:

- STS Roles and Policies required to install and support a ROSA STS Cluster
- A ROSA STS PrivateLink Cluster
- Operator Roles and Policies to operate a ROSA STS Cluster
- OIDC provider to provide trust to Roles

### [rh.rosa.delete](roles/delete/README.md)

This playbook deletes all resources created by the **rh.rosa.create** role

## Requirements

- **An AWS IAM account with sufficient permissions to create a ROSA cluster [^1]**

- **Thoroughly read and understand the [Red Hat Openshift Service on AWS](https://docs.aws.amazon.com/ROSA/latest/userguide/what-is-rosa.html) documentation**

- **Complete the [ROSA getting started](https://console.redhat.com/openshift/create/rosa/getstarted) requirements**

  You must complete some AWS account and local configurations to create and managed ROSA clusters.

- **An offline OCM token**

  This token is generated through the Red Hat Hybrid Cloud Console. The purpose of this token is to verify that you have access and permission to create and upgrade clusters. This token is unique to your account and should not be shared.

- **VPC and Subnets**

  This play assumes there has been a VPC and Subnet(s) pre-created.

  The VPC and Subnet(s) must also pass a verification for egress traffic:

  ```bash
  rosa verify network --subnet-ids "${subnet-ids}" --region="${aws_region}" --role-arn="arn:aws:iam::${aws_account}:role/${role-name}"
  ````
 
## Common Variables

| Variable Name | Default Value | Required | Description |
| --- | --- | --- | --- |
| aws_access_key_id | N/A | Yes | The AWS Access Key with sufficient permissions to create a ROSSA cluster |
| aws_secret_access_key | N/A | Yes | The AWS Access Key with sufficient permissions to create a ROSSA cluster |
| rosa_region | "ap-southeast-2" | Yes | The AWS Region that the resources will be deployed into |
| rosa_token | N/A | Yes | The offline OCM token |
| rosa_version | "4.13.10" | Yes | The version of ROSA to deploy |
| rosa_vpc_name | N/A | Yes | The Name of the VPC as found in `Tag:Name` |
| rosa_subnet_1 | N/A | No | The name of the first subnet |
| rosa_subnet_2 | N/A | No | The name of the second subnet |

## Dependencies

Collections:
- kuberenetes.core
- cloud.terraform

Terraform Providers:
- terraform-redhat/rhcs: >= 1.4.0-prerelease.2
- terraform-redhat/rosa-sts/aws: >=0.0.13
- hashicorp/aws: >= 3.28

## Example Playbook

You can either create your own playbook to extend the `rh.rosa.create` role, or use the predefined playbook `rh.rosa.deploy`.

Example run using predefined playbook

```bash
ansible-playbook rh.rosa.deploy -v --vault-id @prompt
```

> **Note**
>
> It is highly recommended you place the required variables in `group_vars/all/{vars,secrets}.yml`
>
> This will ensure the required variables are used.

Example custom playbook

```yaml
# requires aws cli to be installed on the Ansible management host
    ---
    - hosts: localhost
      connection: local
      become: false
      gather_facts: false
      pre_tasks:
        - name: Confirm AWS credentials are valid
          ansible.builtin.shell:
            cmd: 'aws sts get-caller-identity'
      roles:
        - role: rh.rosa.create
```

## License

[GPL3.0](LICENSE)
