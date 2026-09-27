httproute example:

```yaml
httproutes:
  - name: pin-qbe-route
    namespace: pin-qbe
    hostnames:
      - pin-qbe.internal.example.com
    rules:
      - matches:
          - path:
              type: PathPrefix
              value: /api
            method: GET
            headers:
              - name: X-Env
                value: dev
            queryParams:
              - name: version
                value: v1
        backendRefs:
          - name: pin-qbe
            port: 80
            weight: 100
        filters:
          - type: RequestHeaderModifier
            requestHeaderModifier:
              add:
                X-Added: added
              set:
                X-Set: new
              remove:
                - X-Remove
          - type: URLRewrite
            urlRewrite:
              path:
                replacePrefixMatch: /
          - type: RequestMirror
            requestMirror:
              backendRef:
                name: pin-qbe
```