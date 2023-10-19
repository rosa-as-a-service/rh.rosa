# Ansible Collection - rh.rosa

## Playbooks

### [rh.rosa.deploy_rosa](playbooks/README.md)

Playbook used to provision a ROSA instance

### [rh.rosa.destroy_rosa](playbooks/README.md)

Playbook used to destroy a ROSA instance

### [rh.rosa.preflight](playbooks/README.md)

Playbook used to validate the requirements for deploying ROSA

### Deploy Hub and Spoke ROSA Instances

#### [rh.rosa.deploy_hub_rosa](playbooks/README.md)

Playbook used to provision a Hub ROSA instance

#### [rh.rosa.bootstrap_hub](playbooks/README.md)

Playbook used to bootstrap a Hub instance

#### [rh.rosa.deploy_spoke_rosa](playbooks/README.md)

Playbook used to provision a Spoke ROSA instance

#### [rh.rosa.bootstrap_spoke](playbooks/README.md)

Playbook used to bootstrap a Spoke instance

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
| rosa_aws_account_id | N/A | Yes | The AWS Account ID |
| rosa_aws_role_name | "{{ rosa_cluster_name }}-Installer-Role" | Yes | The name of the role used for the preflight validations |
| rosa_worker_nodes | 2 | Yes | The number of initial work nodes |
| rosa_worker_instance_type | m5.xlarge | Yes | The EC2 instance type to use for the ROSA worker nodes |
| rosa_version | "4.13.10" | Yes | The version of ROSA to deploy |
| rosa_vpc_cidr | N/A | Yes | The subnet of the VPC EG 10.0.0.0/24 |
| rosa_vpc_name | N/A | Yes | The Name of the VPC as found in `Tag:Name` |
| rosa_token | N/A | Yes | The offline OCM token |
| rosa_region | "ap-southeast-2" | Yes | The AWS Region that the resources will be deployed into |
| rosa_subnets | N/A | No | Details of the subnet(s) that ROSA should be deployed into. The quanity of subnets can either be 1, or greater than or equal to 3. Each subnet must have a `name` key, and may have `id`, and `availbility_zone` keys too. |
| rosa_cluster_name | N/A | Yes | The name of the ROSA cluster |

### `rosa_subnets` example

```yaml
rosa_subnets:
  - name: "hub-egress-private-2a"
    id: "subnet-0de3d4efb7c41b5a3"
```

## Dependencies

Collections:
- kuberenetes.core
- cloud.terraform

Terraform Providers:
- terraform-redhat/rhcs: >= 1.4.0
- terraform-redhat/rosa-sts/aws: >=0.0.13
- hashicorp/aws: >= 3.28

## Example Playbook

You can either create your own playbook to extend the `rh.rosa.create` role, or use the predefined playbook `rh.rosa.deploy`.

Example run using predefined playbook

```bash
ansible-playbook rh.rosa.deploy_rosa -v --vault-id @prompt
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
