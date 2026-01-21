# RBAC

RBAC YAML configuration for the `jenkins` ServiceAccount, Role, RoleBinding, ClusterRole, and ClusterRoleBinding to ensure the ServiceAccount can create all the resources in your YAML file, including dynamic provisioning with StorageClasses and PersistentVolumes.

### **1. ServiceAccount**

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins
  namespace: threetierapp
```

### **2. Role**

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: jenkins-role
  namespace: threetierapp
rules:
  # Core API resources
  - apiGroups: [""]
    resources:
      - secrets
      - configmaps
      - persistentvolumeclaims
      - services
      - pods
      - pods/log
      - pods/exec
      - pods/portforward
      - events
      - endpoints
      - replicationcontrollers # ADDED THIS
      - resourcequotas
      - limitranges
      - serviceaccounts
    verbs: ["get", "list", "watch", "create", "update", "delete", "patch"]

  # Apps API group
  - apiGroups: ["apps"]
    resources:
      - deployments
      - deployments/scale
      - deployments/status
      - replicasets
      - replicasets/scale
      - replicasets/status
      - statefulsets
      - statefulsets/scale
      - statefulsets/status
      - daemonsets
      - daemonsets/status
    verbs: ["get", "list", "watch", "create", "update", "delete", "patch"]

  # Networking API group
  - apiGroups: ["networking.k8s.io"]
    resources:
      - ingresses
      - ingresses/status
      - networkpolicies
    verbs: ["get", "list", "watch", "create", "update", "delete", "patch"]

  # Autoscaling
  - apiGroups: ["autoscaling"]
    resources:
      - horizontalpodautoscalers
      - horizontalpodautoscalers/status
    verbs: ["get", "list", "watch", "create", "update", "delete", "patch"]

  # Batch jobs
  - apiGroups: ["batch"]
    resources:
      - jobs
      - jobs/status
      - cronjobs
      - cronjobs/status
    verbs: ["get", "list", "watch", "create", "update", "delete", "patch"]

  # Extensions (for backward compatibility)
  - apiGroups: ["extensions"]
    resources:
      - deployments
      - replicasets
      - ingresses
      - daemonsets
    verbs: ["get", "list", "watch", "create", "update", "delete", "patch"]

  # Policy
  - apiGroups: ["policy"]
    resources:
      - poddisruptionbudgets
    verbs: ["get", "list", "watch", "create", "update", "delete", "patch"]

  # RBAC (if Jenkins needs to manage service accounts)
  - apiGroups: ["rbac.authorization.k8s.io"]
    resources:
      - roles
      - rolebindings
    verbs: ["get", "list", "watch"]
```

### **3. RoleBinding**

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: jenkins-rolebinding
  namespace: threetierapp
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: jenkins-role
subjects:
  - kind: ServiceAccount
    name: jenkins
    namespace: threetierapp
```

### **4. ClusterRole**

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: jenkins-cluster-role
rules:
  # Namespaces
  - apiGroups: [""]
    resources:
      - namespaces
    verbs: ["get", "list", "watch"]

  # Nodes
  - apiGroups: [""]
    resources:
      - nodes
    verbs: ["get", "list", "watch"]

  # PersistentVolumes
  - apiGroups: [""]
    resources:
      - persistentvolumes
    verbs: ["get", "list", "watch"]

  # StorageClasses
  - apiGroups: ["storage.k8s.io"]
    resources:
      - storageclasses
    verbs: ["get", "list", "watch"]

  # ComponentStatuses (for cluster health checks)
  - apiGroups: [""]
    resources:
      - componentstatuses
    verbs: ["get", "list"]
```

### **5. ClusterRoleBinding**

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: jenkins-cluster-rolebinding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: jenkins-cluster-role
subjects:
  - kind: ServiceAccount
    name: jenkins
    namespace: threetierapp
```
### **How to Apply the YAML Files**

1. Save each YAML snippet as a separate file:

   - `serviceaccount.yaml`
   - `role.yaml`
   - `rolebinding.yaml`
   - `clusterrole.yaml`
   - `clusterrolebinding.yaml`

2. Apply them in the following order:

   ```bash
   kubectl apply -f serviceaccount.yaml
   kubectl apply -f role.yaml
   kubectl apply -f rolebinding.yaml
   kubectl apply -f clusterrole.yaml
   kubectl apply -f clusterrolebinding.yaml
   ```

3. Verify the ServiceAccount has the expected permissions:
   ```bash
   kubectl auth can-i create deployment --as=system:serviceaccount:threetierapp:jenkins -n threetierapp
   kubectl auth can-i get nodes --as=system:serviceaccount:threetierapp:jenkins
   ```

### Generate token using service account in the namespace
```yaml
apiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
  name: jenkins-token
  namespace: threetierapp
  annotations:
    kubernetes.io/service-account.name: jenkins

```
Save File as `token.yml`

```bash
kubectl apply -f token.yml
```
Get the Token for Jenkins UI

```bash
kubectl get secret jenkins-token -n threetierapp -o jsonpath={.data.token} | base64 --decode
```
