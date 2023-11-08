# To Do List
- [ ] Enable the following configurable logic
    ```yaml
    cluster-upgrades: automatic # this will configure scheduling reoccuring upgrades when set to automatic, otherwise do nothing https://docs.openshift.com/rosa/upgrading/rosa-upgrading.html#rosa-scheduling-upgrade_rosa-upgrading
    cluster-compliance: strict # this will be used to determine whether it matters if the cluster has fallen out of compliance
    ```