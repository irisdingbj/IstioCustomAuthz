# steps for multi tanant

## 1.Install keycloack
Install keycloak1 in keycloak namespace, keycloak2 in costom namespce.
```
kubcetl apply -f ./install_configs/keycloak.iris.yaml
```

## Enable auto sidecar injection for namespace foo

## Deploy oauth2-proxy, httpbin under namespace foo

## add host mapping for your ingress gw  /etc/hosts
10.xxxx.xxxx.xxx httpbin.foo.svc.cluster.local

## Keycloak using standard grant flow

## http://httpbin.foo.svc.cluster.local:ingress port/headers

