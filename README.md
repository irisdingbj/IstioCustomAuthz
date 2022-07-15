# Oauth2 and Keycloak configuration new version with Istio IngressGateway.

- [Oauth2 and Keycloak configuration new version with Istio IngressGateway.](#oauth2-and-keycloak-configuration-new-version-with-istio-ingressgateway)
  - [Getting Started](#getting-started)
    - [Prerequests](#prerequests)
    - [Create test namespace](#create-test-namespace)
    - [install Keycloak](#install-keycloak)
    - [install Istio](#install-istio)
  - [Configuration](#configuration)
    - [Configure Auth rules by Keycloak UI interface](#configure-auth-rules-by-keycloak-ui-interface)
    - [Add keycloak realm](#add-keycloak-realm)
    - [install Oauth2-proxy](#install-oauth2-proxy)
    - [Edit Istio ConfigMap](#edit-istio-configmap)
    - [Apply RequestAuthentication](#apply-requestauthentication)
    - [Apply Gateway and VirtualService](#apply-gateway-and-virtualservice)
    - [Apply Custom AuthorizationPolicy](#apply-custom-authorizationpolicy)
  - [Validation](#validation)


## Getting Started

### Prerequests
Prerequisites for this demo:

- Kubernetes cluster
- Istioctl
### Create test namespace
```sh
$ kubectl create ns foo
```
### install Keycloak
Set the `admin` and `password` like this:
```sh
env:
        - name: KEYCLOAK_ADMIN
          value: "admin"
        - name: KEYCLOAK_ADMIN_PASSWORD
          value: "password"
```
And then deploy the keycloak service
```sh
$ kubectl apply -f ./install-configs/keycloak.yaml
```
### install Istio
```sh
$ istioctl install -y
```
## Configuration

### Configure Auth rules by Keycloak UI interface
- Get the Keycloak service port first:
```sh
kubectl get svc | grep keycloak
```
- Open the `$clusterIP:$KeycloakPort` in Web UI

### Add keycloak realm
- Create a realm `Istio`.
- Create a client `oauth2-proxy`,change `access-type` to `confidential`, and copy the client secret to  `clientSecret` field of `oauth2-proxy-config.svc.yaml` file.
### install Oauth2-proxy
- Add oauth2-proxy repo
```sh
helm repo add oauth2-proxy https://oauth2-proxy.github.io/manifests
```
- Helm install oauth2-proxy
```sh
$ helm install \
  --namespace foo \
  --values ./install-configs/oauth2-proxy-config.svc.yaml \
  oauth2-proxy oauth2-proxy/oauth2-proxy
```
### Edit Istio ConfigMap
You can directly apply this yaml file to edit Istio's ConfigMap by this command:
```sh
$ kubectl apply -f istio-configmap.yaml
```
Or you can also manually change the existing Istio ConfigMap by these steps:
1. Edit the mesh config with the following command:
```sh
$ kubectl edit configmap istio -n istio-system
```
2. In the editor, add the extension provider definitions shown below:
```sh
data:
  mesh: |-
    # Add the following content to define the external authorizers.
    extensionProviders:
    - name: oauth2-proxy
      envoyExtAuthzHttp:
        service: oauth2-proxy.foo.svc.cluster.local
        port: 80
        timeout: 1.5s
        includeRequestHeadersInCheck: ["authorization", "cookie"]
        headersToUpstreamOnAllow: ["x-forwarded-access-token", "authorization", "path", "x-auth-request-user", "x-auth-request-email", "x-auth-request-access-token"]
```
3. Restart Istiod to allow the change to take effect with the following command:
```sh
$ kubectl rollout restart deployment/istiod -n istio-system
```
### Apply RequestAuthentication
```sh
$ kubectl apply -f request-auth.yaml
```
### Apply Gateway and VirtualService
```sh
$ kubectl apply -f gateway-vs-oauth-keycloak.yaml
```

### Apply Custom AuthorizationPolicy
```sh
$ kubectl apply -f authorization-policy.yaml
```

## Validation