# Oauth2 and Keycloak configuration new version with Istio IngressGateway.

- [Oauth2 and Keycloak configuration new version with Istio IngressGateway.](#oauth2-and-keycloak-configuration-new-version-with-istio-ingressgateway)
  - [Getting Started](#getting-started)
    - [Prerequests](#prerequests)
    - [Create test namespace](#create-test-namespace)
    - [install Keycloak](#install-keycloak)
    - [install Istio](#install-istio)
    - [install Oauth2-proxy](#install-oauth2-proxy)
  - [Configuration](#configuration)
    - [Edit Istio ConfigMap](#edit-istio-configmap)
    - [Apply RequestAuthentication](#apply-requestauthentication)
    - [Apply Gateway and VirtualService](#apply-gateway-and-virtualservice)
    - [Configure Auth rules by Keycloak UI interface](#configure-auth-rules-by-keycloak-ui-interface)
    - [Apply Custom AuthorizationPolicy](#apply-custom-authorizationpolicy)
    - [Config Oauth2-proxy service](#config-oauth2-proxy-service)
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
```sh
$ kubectl apply -f ./install-configs/keycloak.yaml
```
### install Istio
```sh
$ istioctl install -y
```
### install Oauth2-proxy
```sh
$ helm install \
  --namespace foo \
  --values ./install-configs/oauth2-proxy-config.svc.yaml \
  --version 5.0.6 \
  oauth2-proxy oauth2-proxy/oauth2-proxy
```
## Configuration

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
$ kubectl apply -f hello-iris-gateway-oauth-keycloak.night.yaml
```
### Configure Auth rules by Keycloak UI interface

### Apply Custom AuthorizationPolicy
```sh
$ kubectl apply -f authorization-policy-iris.yaml
```
### Config Oauth2-proxy service
```sh
$ kubectl apply -f oauth2-proxy-config.svc.yaml
```

## Validation