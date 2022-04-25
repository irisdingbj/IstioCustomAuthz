kubectl create ns foo
kubectl label ns foo istio-injection=enabled
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.13/samples/httpbin/httpbin.yaml -n foo
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.13/samples/sleep/sleep.yaml -n foo

kubectl exec "$(kubectl get pod -l app=sleep -n foo -o jsonpath={.items..metadata.name})" -c sleep -n foo -- curl http://httpbin.foo:8000/ip -s -o /dev/null -w "%{http_code}\n"

kubectl apply -f ext-authz-oauth2-proxy.yaml 


kubectl edit configmap istio -n istio-system

kubectl apply -f istio-configmap.yaml 
kubectl rollout restart deployment/istiod -n istio-system

kubectl apply -f httpbin-istio-gateway.yaml

kubectl apply -f gateway-virtualservice.yaml

# install oauth2-proxy
helm install \
  --namespace foo \
  --values oauth2-proxy-config.yaml \
  --version 5.0.6 \
  oauth2-proxy oauth2-proxy/oauth2-proxy

# keycloak svc
# keycloak.keycloak.svc.cluster.local:30802

kubectl exec "$(kubectl get pod -l app=sleep -n foo -o jsonpath={.items..metadata.name})" -c sleep -n foo -- curl "http://httpbin.foo:8000/headers" -H "authorization: allow" -s
curl "http://httpbin.foo:8000/headers" -H "authorization: allow" -s

kubectl exec "$(kubectl get pod -l app=sleep -n foo -o jsonpath={.items..metadata.name})" -c sleep -n foo -- curl http://httpbin.foo:8000/ip -s -o /dev/null -w "%{http_code}\n"
curl http://httpbin.foo:8000/ip -H "authorization: allow" -s -o /dev/null -w "%{http_code}\n"
x-forwarded-access-token