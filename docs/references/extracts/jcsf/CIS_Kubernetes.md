# JCSF extract: CIS Kubernetes

Source: `JCSF v7_public.xlsx` sheet `CIS Kubernetes`.

| ID в CIS k8s | Требование | Примечание | JCSF |
| --- | --- | --- | --- |
| Control Plane Components |  |  |  |
| Control Plane Node Configuration Files |  |  |  |
| 1.1.1 | Ensure that the API server pod specification file permissions are set to 600 or more restrictive | Ensure that the API server pod specification file has permissions of 600 or more restrictive. | ORCH-2-5 |
| 1.1.2 | Ensure that the API server pod specification file ownership is set to root:root | Ensure that the API server pod specification file ownership is set to root:root. | ORCH-2-5 |
| 1.1.3 | Ensure that the controller manager pod specification file permissions are set to 600 or more restrictive | Ensure that the controller manager pod specification file has permissions of 600 or more restrictive. | ORCH-2-5 |
| 1.1.4 | Ensure that the controller manager pod specification file ownership is set to root:root | Ensure that the controller manager pod specification file ownership is set to root:root. | ORCH-2-5 |
| 1.1.5 | Ensure that the scheduler pod specification file permissions are set to 600 or more restrictive | Ensure that the scheduler pod specification file has permissions of 600 or more restrictive. | ORCH-2-5 |
| 1.1.6 | Ensure that the scheduler pod specification file ownership is set to root:root | Ensure that the scheduler pod specification file ownership is set to root:root. | ORCH-2-5 |
| 1.1.7 | Ensure that the etcd pod specification file permissions are set to 600 or more restrictive | Ensure that the /etc/kubernetes/manifests/etcd.yaml file has permissions of 600 or more restrictive. | ORCH-2-5 |
| 1.1.8 | Ensure that the etcd pod specification file ownership is set to root:root | Ensure that the /etc/kubernetes/manifests/etcd.yaml file ownership is set to root:root. | ORCH-2-5 |
| 1.1.9 | Ensure that the Container Network Interface file permissions are set to 600 or more restrictive | Ensure that the Container Network Interface files have permissions of 600 or more restrictive. | ORCH-2-5 |
| 1.1.10 | Ensure that the Container Network Interface file ownership is set to root:root | Ensure that the Container Network Interface files have ownership set to root:root. | ORCH-2-5 |
| 1.1.11 | Ensure that the etcd data directory permissions are set to 700 or more restrictive | Ensure that the etcd data directory has permissions of 700 or more restrictive. | ORCH-2-5 |
| 1.1.12 | Ensure that the etcd data directory ownership is set to etcd:etcd | Ensure that the etcd data directory ownership is set to etcd:etcd. | ORCH-2-5 |
| 1.1.13 | Ensure that the default administrative credential file permissions are set to 600 | Ensure that the admin.conf file (and super-admin.conf file, where it exists) have permissions of 600. | ORCH-2-5 |
| 1.1.14 | Ensure that the default administrative credential file ownership is set to root:root | Ensure that the admin.conf (and super-admin.conf file, where it exists) file ownership is set to root:root. | ORCH-2-5 |
| 1.1.15 | Ensure that the scheduler.conf file permissions are set to 600 or more restrictive | Ensure that the scheduler.conf file has permissions of 600 or more restrictive. | ORCH-2-5 |
| 1.1.16 | Ensure that the scheduler.conf file ownership is set to root:root | Ensure that the scheduler.conf file ownership is set to root:root. | ORCH-2-5 |
| 1.1.17 | Ensure that the controller-manager.conf file permissions are set to 600 or more restrictive | Ensure that the controller-manager.conf file has permissions of 600 or more restrictive. | ORCH-2-5 |
| 1.1.18 | Ensure that the controller-manager.conf file ownership is set to root:root | Ensure that the controller-manager.conf file ownership is set to root:root. | ORCH-2-5 |
| 1.1.19 | Ensure that the Kubernetes PKI directory and file ownership is set to root:root | Ensure that the Kubernetes PKI directory and file ownership is set to root:root. | ORCH-2-5 |
| 1.1.20 | Ensure that the Kubernetes PKI certificate file permissions are set to 644 or more restrictive | Ensure that Kubernetes PKI certificate files have permissions of 644 or more restrictive. | ORCH-2-5 |
| 1.1.21 | Ensure that the Kubernetes PKI key file permissions are set to 600 | Ensure that Kubernetes PKI key files have permissions of 600. | ORCH-2-5 |
| API Server |  |  |  |
| 1.2.1 | Ensure that the --anonymous-auth argument is set to false | Disable anonymous requests to the API server. | ORCH-1-1 |
| 1.2.2 | Ensure that the --token-auth-file parameter is not set | Do not use token based authentication. | ORCH-1-2 |
| 1.2.3 | Ensure that the DenyServiceExternalIPs is set | This admission controller rejects all net-new usage of the Service field externalIPs. | - |
| 1.2.4 | Ensure that the --kubelet-client-certificate and --kubelet client-key arguments are set as appropriate | Enable certificate based kubelet authentication. | ORCH-1-5 |
| 1.2.5 | Ensure that the --kubelet-certificate-authority argument is set as appropriate | Verify kubelet's certificate before establishing connection. | ORCH-1-5 |
| 1.2.6 | Ensure that the --authorization-mode argument is not set to AlwaysAllow | Do not always authorize all requests. | ORCH-1-1 |
| 1.2.7 | Ensure that the --authorization-mode argument includes Node | Restrict kubelet nodes to reading only objects associated with them. | ORCH-1-1 |
| 1.2.8 | Ensure that the --authorization-mode argument includes RBAC | Turn on Role Based Access Control. | ORCH-1-1; ORCH-2-10 |
| 1.2.9 | Ensure that the admission control plugin EventRateLimit is set | Limit the rate at which the API server accepts requests. | - |
| 1.2.10 | Ensure that the admission control plugin AlwaysAdmit is not set | Do not allow all requests. | ORCH-1-6 |
| 1.2.11 | Ensure that the admission control plugin AlwaysPullImages is set | Always pull images. | ORCH-2-4 |
| 1.2.12 | Ensure that the admission control plugin ServiceAccount is set | Automate service accounts management. | - |
| 1.2.13 | Ensure that the admission control plugin NamespaceLifecycle is set | Reject creating objects in a namespace that is undergoing termination. | ORCH-3-1 |
| 1.2.14 | Ensure that the admission control plugin NodeRestriction is set | Limit the Node and Pod objects that a kubelet could modify. | - |
| 1.2.15 | Ensure that the --profiling argument is set to false | Disable profiling, if not needed. | - |
| 1.2.16 | Ensure that the --audit-log-path argument is set | Enable auditing on the Kubernetes API Server and set the desired audit log path. | ORCH-2-8 |
| 1.2.17 | Ensure that the --audit-log-maxage argument is set to 30 or as appropriate | Retain the logs for at least 30 days or as appropriate. | ORCH-2-8 |
| 1.2.18 | Ensure that the --audit-log-maxbackup argument is set to 10 or as appropriate | Retain 10 or an appropriate number of old log files. | ORCH-2-8 |
| 1.2.19 | Ensure that the --audit-log-maxsize argument is set to 100 or as appropriate | Rotate log files on reaching 100 MB or as appropriate. | ORCH-2-8 |
| 1.2.20 | Ensure that the --request-timeout argument is set as appropriate | Set global request timeout for API server requests as appropriate. | - |
| 1.2.21 | Ensure that the --service-account-lookup argument is set to true | Validate service account before validating token. | - |
| 1.2.22 | Ensure that the --service-account-key-file argument is set as appropriate | Explicitly set a service account public key file for service accounts on the apiserver. | - |
| 1.2.23 | Ensure that the --etcd-certfile and --etcd-keyfile arguments are set as appropriate | etcd should be configured to make use of TLS encryption for client connections. | ORCH-1-7 |
| 1.2.24 | Ensure that the --tls-cert-file and --tls-private-key-file arguments are set as appropriate | Setup TLS connection on the API server. | ORCH-1-4 |
| 1.2.25 | Ensure that the --client-ca-file argument is set as appropriate | Setup TLS connection on the API server. | - |
| 1.2.26 | Ensure that the --etcd-cafile argument is set as appropriate | etcd should be configured to make use of TLS encryption for client connections. | ORCH-1-7 |
| 1.2.27 | Ensure that the --encryption-provider-config argument is set as appropriate | Encrypt etcd key-value store. | ORCH-3-4 |
| 1.2.28 | Ensure that encryption providers are appropriately configured | Where etcd encryption is used, appropriate providers should be configured. | ORCH-3-4 |
| 1.2.29 | Ensure that the API Server only makes use of Strong Cryptographic Ciphers | Ensure that the API server is configured to only use strong cryptographic ciphers. | ORCH-1-4 |
| 1.2.30 | Ensure that the --service-account-extend-token-expiration parameter is set to false | By default Kubernetes extends service account token lifetimes to one year to aid in transition from the legacy token settings. | - |
| Controller Manager |  |  |  |
| 1.3.1 | Ensure that the --terminated-pod-gc-threshold argument is set as appropriate | Activate garbage collector on pod termination, as appropriate. | - |
| 1.3.2 | Ensure that the --profiling argument is set to false | Disable profiling, if not needed. | - |
| 1.3.3 | Ensure that the --use-service-account-credentials argument is set to true | Use individual service account credentials for each controller. | - |
| 1.3.4 | Ensure that the --service-account-private-key-file argument is set as appropriate | Explicitly set a service account private key file for service accounts on the controller manager. | - |
| 1.3.5 | Ensure that the --root-ca-file argument is set as appropriate | Allow pods to verify the API server's serving certificate before establishing connections. | - |
| 1.3.6 | Ensure that the RotateKubeletServerCertificate argument is set to true | Enable kubelet server certificate rotation on controller-manager. | - |
| 1.3.7 | Ensure that the --bind-address argument is set to 127.0.0.1 | Do not bind the Controller Manager service to non-loopback insecure addresses. | - |
| Scheduler |  |  |  |
| 1.4.1 | Ensure that the --profiling argument is set to false | Disable profiling, if not needed. | - |
| 1.4.2 | Ensure that the --bind-address argument is set to 127.0.0.1 | Do not bind the scheduler service to non-loopback insecure addresses. | - |
| Etcd |  |  |  |
| 2.1 | Ensure that the --cert-file and --key-file arguments are set as appropriate | Configure TLS encryption for the etcd service. | ORCH-3-4 |
| 2.2 | Ensure that the --cert-file and --key-file arguments are set as appropriate | Configure TLS encryption for the etcd service. | ORCH-3-4 |
| 2.3 | Ensure that the --client-cert-auth argument is set to true | Enable client authentication on etcd service. | ORCH-3-4 |
| 2.4 | Ensure that the --auto-tls argument is not set to true | Do not use self-signed certificates for TLS. | ORCH-3-4 |
| 2.5 | Ensure that the --peer-cert-file and --peer-key-file arguments are set as appropriate | etcd should be configured to make use of TLS encryption for peer connections. | ORCH-3-4 |
| 2.6 | Ensure that the --peer-client-cert-auth argument is set to true | etcd should be configured for peer authentication. | ORCH-3-4 |
| 2.7 | Ensure that the --peer-auto-tls argument is not set to true | Do not use automatically generated self-signed certificates for TLS connections between peers. | ORCH-3-4 |
| 2.8 | Ensure that a unique Certificate Authority is used for etcd | Use a different certificate authority for etcd from the one used for Kubernetes. | ORCH-3-4 |
| Control Plane Configuration |  |  |  |
| Authentication and Authorization |  |  |  |
| 3.1.1 | Client certificate authentication should not be used for users | Kubernetes provides the option to use client certificates for user authentication. However as there is no way to revoke these certificates when a user leaves an organization or loses their credential, they are not suitable for this purpose. It is not possible to fully disable client certificate use within a cluster as it is used for component to component authentication. | ORCH-2-11 |
| 3.1.2 | Service account token authentication should not be used for users | Kubernetes provides service account tokens which are intended for use by workloads running in the Kubernetes cluster, for authentication to the API server. These tokens are not designed for use by end-users and do not provide for features such as revocation or expiry, making them insecure. A newer version of the feature (Bound service account token volumes) does introduce expiry but still does not allow for specific revocation. | ORCH-1-3; ORCH-2-11 |
| 3.1.3 | Bootstrap token authentication should not be used for users | Kubernetes provides bootstrap tokens which are intended for use by new nodes joining the cluster. These tokens are not designed for use by end-users they are specifically designed for the purpose of bootstrapping new nodes and not for general authentication. | ORCH-1-3; ORCH-2-11 |
| Logging |  |  |  |
| 3.2.1 | Ensure that a minimal audit policy is created | Kubernetes can audit the details of requests made to the API server. The --audit policy-file flag must be set for this logging to be enabled. | ORCH-2-8 |
| 3.2.2 | Ensure that the audit policy covers key security concerns | Ensure that the audit policy created for the cluster covers key security concerns. | ORCH-2-9; CONT-2-3; CONT-3-3 |
| Worker Nodes |  |  |  |
| Worker Node Configuration Files |  |  |  |
| 4.1.1 | Ensure that the kubelet service file permissions are set to 600 or more restrictive | Ensure that the kubelet service file has permissions of 600 or more restrictive. | ORCH-2-6 |
| 4.1.2 | Ensure that the kubelet service file ownership is set to root:root | Ensure that the kubelet service file ownership is set to root:root. | ORCH-2-6 |
| 4.1.3 | If proxy kubeconfig file exists ensure permissions are set to 600 or more restrictive | If kube-proxy is running, and if it is using a file-based kubeconfig file, ensure that the proxy kubeconfig file has permissions of 600 or more restrictive. | ORCH-2-6 |
| 4.1.4 | If proxy kubeconfig file exists ensure ownership is set to root:root | If kube-proxy is running, ensure that the file ownership of its kubeconfig file is set to root:root. | ORCH-2-6 |
| 4.1.5 | Ensure that the --kubeconfig kubelet.conf file permissions are set to 600 or more restrictive | Ensure that the kubelet.conf file has permissions of 600 or more restrictive. | ORCH-2-6 |
| 4.1.6 | Ensure that the --kubeconfig kubelet.conf file ownership is set to root:root | Ensure that the kubelet.conf file ownership is set to root:root. | ORCH-2-6 |
| 4.1.7 | Ensure that the certificate authorities file permissions are set to 644 or more restrictive | Ensure that the certificate authorities file has permissions of 644 or more restrictive. | ORCH-2-6 |
| 4.1.8 | Ensure that the client certificate authorities file ownership is set to root:root | Ensure that the certificate authorities file ownership is set to root:root. | ORCH-2-6 |
| 4.1.9 | If the kubelet config.yaml configuration file is being used validate permissions set to 600 or more restrictive | Ensure that if the kubelet refers to a configuration file with the --config argument, that file has permissions of 600 or more restrictive. | ORCH-2-6 |
| 4.1.10 | If the kubelet config.yaml configuration file is being used validate file ownership is set to root:root | Ensure that if the kubelet refers to a configuration file with the --config argument, that file is owned by root:root. | ORCH-2-6 |
| Kubelet |  |  |  |
| 4.2.1 | Ensure that the --anonymous-auth argument is set to false | Disable anonymous requests to the Kubelet server. | ORCH-1-8 |
| 4.2.2 | Ensure that the --authorization-mode argument is not set to AlwaysAllow | Do not allow all requests. Enable explicit authorization. | ORCH-1-8; ORCH-1-11 |
| 4.2.3 | Ensure that the --client-ca-file argument is set as appropriate | Enable Kubelet authentication using certificates. | ORCH-1-5; ORCH-1-10 |
| 4.2.4 | Verify that if defined, readOnlyPort is set to 0 | Disable the read-only port. | ORCH-1-9 |
| 4.2.5 | Ensure that the --streaming-connection-idle-timeout argument is not set to 0 | Do not disable timeouts on streaming connections. | - |
| 4.2.6 | Ensure that the --make-iptables-util-chains argument is set to true | Allow Kubelet to manage iptables. | - |
| 4.2.7 | Ensure that the --hostname-override argument is not set | Do not override node hostnames. | - |
| 4.2.8 | Ensure that the eventRecordQPS argument is set to a level which ensures appropriate event capture | Security relevant information should be captured. The eventRecordQPS on the Kubelet configuration can be used to limit the rate at which events are gathered and sets the maximum event creations per second. Setting this too low could result in relevant events not being logged, however the unlimited setting of 0 could result in a denial of service on the kubelet. | - |
| 4.2.9 | Ensure that the --tls-cert-file and --tls-private-key-file arguments are set as appropriate | Setup TLS connection on the Kubelets. | ORCH-1-10 |
| 4.2.10 | Ensure that the --rotate-certificates argument is not set to false | Enable kubelet client certificate rotation. | ORCH-3-3 |
| 4.2.11 | Verify that the RotateKubeletServerCertificate argument is set to true | Enable kubelet server certificate rotation. | ORCH-3-3 |
| 4.2.12 | Ensure that the Kubelet only makes use of Strong Cryptographic Ciphers | Ensure that the Kubelet is configured to only use strong cryptographic ciphers. | ORCH-1-10 |
| 4.2.13 | Ensure that a limit is set on pod PIDs | Ensure that the Kubelet sets limits on the number of PIDs that can be created by pods running on the node. | MAN-2-8; CONT-1-2 |
| 4.2.14 | Ensure that the --seccomp-default parameter is set to true | Ensure that the Kubelet enforces the use of the RuntimeDefault seccomp profile. | MAN-4-2 |
| 4.2.15 | Ensure that the --IPAddressDeny is set to any | Ensuring that --IPAddressDeny is set to "Any" will facilitate allowlisting of only IP addresses that are explicitly set with the --IPAddressAllow parameter which will block unspecified IP addresses from communicating with the kubelet component. | - |
| Kube-proxy |  |  |  |
| 4.3.1 | Ensure that the kube-proxy metrics service is bound to localhost | Do not bind the kube-proxy metrics port to non-loopback addresses. | - |
| Policies |  |  |  |
| RBAC and Service Accounts |  |  |  |
| 5.1.1 | Ensure that the cluster-admin role is only used where required | The RBAC role cluster-admin provides wide-ranging powers over the environment and should be used only where and when needed. | ORCH-2-1; ORCH-2-3; ORCH-2-10 |
| 5.1.2 | Minimize access to secrets | The Kubernetes API stores secrets, which may be service account tokens for the Kubernetes API or credentials used by workloads in the cluster. Access to these secrets should be restricted to the smallest possible group of users to reduce the risk of privilege escalation. | ORCH-2-10; MAN-1-1 |
| 5.1.3 | Minimize wildcard use in Roles and ClusterRoles | Kubernetes Roles and ClusterRoles provide access to resources based on sets of objects and actions that can be taken on those objects. It is possible to set either of these to be the wildcard "*" which matches all items. Use of wildcards is not optimal from a security perspective as it may allow for inadvertent access to be granted when new resources are added to the Kubernetes API either as CRDs or in later versions of the product. | ORCH-2-10 |
| 5.1.4 | Minimize access to create pods | The ability to create pods in a namespace can provide a number of opportunities for privilege escalation, such as assigning privileged service accounts to these pods or mounting hostPaths with access to sensitive data (unless Pod Security Policies are implemented to restrict this access). As such, access to create new pods should be restricted to the smallest possible group of users. | ORCH-2-10 |
| 5.1.5 | Ensure that default service accounts are not actively used | The default service account should not be used to ensure that rights granted to applications can be more easily audited and reviewed. | ORCH-2-10 |
| 5.1.6 | Ensure that Service Account Tokens are only mounted where necessary | Service accounts tokens should not be mounted in pods except where the workload running in the pod explicitly needs to communicate with the API server. | ORCH-2-10 |
| 5.1.7 | Avoid use of system:masters group | The special group system:masters should not be used to grant permissions to any user or service account, except where strictly necessary (e.g. bootstrapping access prior to RBAC being fully available). | ORCH-2-10 |
| 5.1.8 | Limit use of the Bind, Impersonate and Escalate permissions in the Kubernetes cluster | Cluster roles and roles with the impersonate, bind or escalate permissions should not be granted unless strictly required. Each of these permissions allow a particular subject to escalate their privileges beyond those explicitly granted by cluster administrators. | ORCH-2-10 |
| 5.1.9 | Minimize access to create persistent volumes | The ability to create persistent volumes in a cluster can provide an opportunity for privilege escalation, via the creation of hostPath volumes. As persistent volumes are not covered by Pod Security Admission, a user with access to create persistent volumes may be able to get access to sensitive files from the underlying host even where restrictive Pod Security Admission policies are in place. | ORCH-2-10 |
| 5.1.10 | Minimize access to the proxy sub-resource of nodes | Users with access to the Proxy sub-resource of Node objects automatically have permissions to use the kubelet API, which may allow for privilege escalation or bypass cluster security controls such as audit logs. The kubelet provides an API which includes rights to execute commands in any container running on the node. Access to this API is covered by permissions to the main Kubernetes API via the node object. The proxy sub-resource specifically allows wide ranging access to the kubelet API. Direct access to the kubelet API bypasses controls like audit logging (there is no audit log of kubelet API access) and admission control. | ORCH-2-10 |
| 5.1.11 | Minimize access to the approval sub-resource of certificatesigningrequests objects | Users with access to the update the approval sub-resource of CertificateSigningRequests objects can approve new client certificates for the Kubernetes API effectively allowing them to create new high-privileged user accounts. This can allow for privilege escalation to full cluster administrator, depending on users configured in the cluster. | ORCH-2-10 |
| 5.1.12 | Minimize access to webhook configuration objects | Users with rights to create/modify/delete validatingwebhookconfigurations or mutatingwebhookconfigurations can control webhooks that can read any object admitted to the cluster, and in the case of mutating webhooks, also mutate admitted objects. This could allow for privilege escalation or disruption of the operation of the cluster. | ORCH-2-10 |
| 5.1.13 | Minimize access to the service account token creation | Users with rights to create new service account tokens at a cluster level, can create long-lived privileged credentials in the cluster. This could allow for privilege escalation and persistent access to the cluster, even if the users account has been revoked. | ORCH-2-10 |
| Pod Security Standards |  |  |  |
| 5.2.1 | Ensure that the cluster has at least one active policy control mechanism in place | Every Kubernetes cluster should have at least one policy control mechanism in place to enforce the other requirements in this section. This could be the in-built Pod Security Admission controller, or a third party policy control system. | ORCH-2-13; MAN-3-1; CONT-3-4; CONT-4-1 |
| 5.2.2 | Minimize the admission of privileged containers | Do not generally permit containers to be run with the securityContext.privileged flag set to true. | MAN-1-2; MAN-3-3 |
| 5.2.3 | Minimize the admission of containers wishing to share the host process ID namespace | Do not generally permit containers to be run with the hostPID flag set to true. | MAN-2-5 |
| 5.2.4 | Minimize the admission of containers wishing to share the host IPC namespace | Do not generally permit containers to be run with the hostIPC flag set to true. | MAN-2-6 |
| 5.2.5 | Minimize the admission of containers wishing to share the host network namespace | Do not generally permit containers to be run with the hostNetwork flag set to true. | MAN-1-3 |
| 5.2.6 | Minimize the admission of containers with allowPrivilegeEscalation | Do not generally permit containers to be run with the allowPrivilegeEscalation flag set to true. Allowing this right can lead to a process running a container getting more rights than it started with. It's important to note that these rights are still constrained by the overall container sandbox, and this setting does not relate to the use of privileged containers. | MAN-1-4 |
| 5.2.7 | Minimize the admission of root containers | Do not generally permit containers to be run as the root user. | MAN-3-2 |
| 5.2.8 | Minimize the admission of containers with the NET_RAW capability | Do not generally permit containers with the potentially dangerous NET_RAW capability. | MAN-3-4 |
| 5.2.9 | Minimize the admission of containers with added capabilities | Do not generally permit containers with capabilities assigned beyond the default set. | MAN-1-4; MAN-3-4; MAN-4-1 |
| 5.2.10 | Minimize the admission of containers with capabilities assigned | Do not generally permit containers with capabilities. | MAN-1-4; MAN-3-4; MAN-4-1 |
| 5.2.11 | Minimize the admission of Windows HostProcess Containers | Do not generally permit Windows containers to be run with the hostProcess flag set to true. | MAN-2-5 |
| 5.2.12 | Minimize the admission of HostPath volumes | Do not generally admit containers which make use of hostPath volumes. | MAN-2-2; MAN-2-4 |
| 5.2.13 | Minimize the admission of containers which use HostPorts | Do not generally permit containers which require the use of HostPorts. | MAN-1-3 |
| Network Policies and CNI |  |  |  |
| 5.3.1 | Ensure that the CNI in use supports Network Policies | There are a variety of CNI plugins available for Kubernetes. If the CNI in use does not support Network Policies it may not be possible to effectively restrict traffic in the cluster. | CONT-2-1 |
| 5.3.2 | Ensure that all Namespaces have Network Policies defined | Use network policies to isolate traffic in your cluster network. | CONT-2-1; CONT-2-2; CONT-2-3; CONT-3-1; CONT-3-2; CONT-3-3 |
| Secrets Management |  |  |  |
| 5.4.1 | Prefer using secrets as files over secrets as environment variables | Kubernetes supports mounting secrets as data volumes or as environment variables. Minimize the use of environment variable secrets. | MAN-1-1 |
| 5.4.2 | Consider external secret storage | Consider the use of an external secrets storage and management system, instead of using Kubernetes Secrets directly, if you have more complex secret management needs. Ensure the solution requires authentication to access secrets, has auditing of access to and use of secrets, and encrypts secrets. Some solutions also make it easier to rotate secrets. | ORCH-3-6 |
| Extensible Admission Control |  |  |  |
| 5.5.1 | Configure Image Provenance using ImagePolicyWebhook admission controller | Configure Image Provenance for your deployment. | IMG-1-2; IMG-1-5; IMG-2-1; IMG-3-3 |
| General Policies |  |  |  |
| 5.6.1 | Create administrative boundaries between resources using namespaces | Use namespaces to isolate your Kubernetes objects. | CONT-2-3;CONT-3-3 |
| 5.6.2 | Ensure that the seccomp profile is set to docker/default in your pod definitions | Enable docker/default seccomp profile in your pod definitions. | MAN-4-2; CONT-1-1 |
| 5.6.3 | Apply Security Context to Your Pods and Containers | Apply Security Context to Your Pods and Containers. | MAN-4-1 |
| 5.6.4 | The default namespace should not be used | Kubernetes provides a default namespace, where objects are placed if no namespace is specified for them. Placing objects in this namespace makes application of RBAC and other controls more difficult. | - |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
