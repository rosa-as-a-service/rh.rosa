# Ansible Collection - rh.rosa

## Playbooks

### [rh.rosa.deploy_rosa](playbooks/README.md)

Playbook used to provision a ROSA HCP instance

### [rh.rosa.destroy_rosa](playbooks/README.md)

Playbook used to destroy a ROSA HCP instance

### [rh.rosa.preflight](playbooks/README.md)

Playbook used to validate the requirements for deploying ROSA

### Deploy Hub and Spoke ROSA Instances

#### [rh.rosa.deploy_hub_rosa](playbooks/README.md)

Playbook used to provision a Hub ROSA HCP instance

#### [rh.rosa.bootstrap_hub](playbooks/README.md)

Playbook used to bootstrap a Hub instance

#### [rh.rosa.deploy_spoke_rosa](playbooks/README.md)

Playbook used to provision a Spoke ROSA HCP instance

#### [rh.rosa.bootstrap_spoke](playbooks/README.md)

Playbook used to bootstrap a Spoke instance

## Roles

### [rh.rosa.create](roles/create/README.md)

This Role creates the following:

- STS Account Roles and Policies (HCP) required to install and support a ROSA HCP Cluster
- Managed OIDC configuration and provider
- Operator Roles and Policies for ROSA HCP
- A ROSA HCP Cluster (public by default, private optional)

### [rh.rosa.delete](roles/delete/README.md)

This playbook deletes all resources created by the **rh.rosa.create** role

## Requirements

- **An AWS IAM account with sufficient permissions to create a ROSA cluster [^1]**

- **Thoroughly read and understand the [Red Hat Openshift Service on AWS](https://docs.aws.amazon.com/ROSA/latest/userguide/what-is-rosa.html) documentation**

- **Complete the [ROSA getting started](https://console.redhat.com/openshift/create/rosa/getstarted) requirements**

  You must complete some AWS account and local configurations to create and manage ROSA clusters.

- **An offline OCM token**

  This token is generated through the Red Hat Hybrid Cloud Console. The purpose of this token is to verify that you have access and permission to create and upgrade clusters. This token is unique to your account and should not be shared.

- **VPC and Subnets**

  This collection assumes there has been a VPC and Subnet(s) pre-created (or use the `rh.rosa.vpc` role to create them).

  ROSA HCP requires:
  - At least 1 private subnet per AZ for worker nodes
  - Public subnets if deploying a public cluster (for load balancers)

## Common Variables

| Variable Name | Default Value | Required | Description |
| --- | --- | --- | --- |
| rosa_cluster_name | N/A | Yes | The name of the ROSA cluster |
| rosa_token | N/A | Yes | The offline OCM token |
| rosa_region | "ap-southeast-2" | Yes | The AWS Region for deployment |
| rosa_version | "4.18.0" | Yes | The version of ROSA to deploy |
| rosa_worker_nodes | 2 | Yes | The number of initial worker nodes |
| rosa_worker_instance_type | m5.xlarge | Yes | The EC2 instance type for worker nodes |
| rosa_private | false | No | Deploy as a private cluster |
| rosa_admin_username | "cluster-admin" | No | Admin username for the cluster |
| rosa_admin_password | N/A | No | Admin password for the cluster |
| rosa_subnets | N/A | Yes* | Subnet names to look up (if rosa_subnet_ids not set) |
| rosa_subnet_ids | N/A | Yes* | Subnet IDs to use directly |
| rosa_machine_cidr | N/A | No | Machine CIDR block |

> *Either `rosa_subnets` (lookup by name) or `rosa_subnet_ids` (direct IDs) must be provided.

### `rosa_subnets` example

```yaml
rosa_subnets:
  - name: "hub-private-2a"
  - name: "hub-private-2b"
  - name: "hub-public-2a"
  - name: "hub-public-2b"
```

### `rosa_subnet_ids` example

```yaml
rosa_subnet_ids:
  - "subnet-0de3d4efb7c41b5a3"
  - "subnet-0ab1c2d3e4f5a6b7c"
```

## Dependencies

Collections:
- kubernetes.core
- cloud.terraform
- amazon.aws

Terraform Providers:
- terraform-redhat/rhcs: ~> 1.7
- hashicorp/aws: >= 5.20.0

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
---
- hosts: localhost
  connection: local
  become: false
  gather_facts: false
  roles:
    - role: rh.rosa.create
```

## License

[GPL3.0](LICENSE)
