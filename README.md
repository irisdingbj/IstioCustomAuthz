# IstioCustomAuthz
Oauth2 and Keycloak configuration with Istio.

# steps

## Install keycloack under keycloack namespace

## Enable auto sidecar injection for namespace foo

## Deploy oauth2-proxy, httpbin under namespace foo

## add host mapping for your ingress gw  /etc/hosts
10.xxxx.xxxx.xxx httpbin.foo.svc.cluster.local

## Keycloak using standard grant flow

## http://httpbin.foo.svc.cluster.local:ingres port/headers

