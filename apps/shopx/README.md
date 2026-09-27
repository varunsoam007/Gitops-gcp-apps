# LocalShopX GitOps Deployment on GKE (`gitops-gcp-apps`)

Ye directory `LocalShopX` microservices application ko **GKE** par **Kubernetes Gateway API** aur **Istio Ambient Mesh (Sidecar-less)** ke saath deploy karne ke liye configure ki gayi hai.

---

## 🏗️ Architecture Overview

- **Namespace:** `shopx`
- **Mesh Mode:** Istio Ambient Mesh (`istio.io/dataplane-mode: ambient`)
- **L7 Routing & Telemetry:** Ambient Waypoint Proxy (`istio.io/use-waypoint: waypoint`)
- **Ingress / Gateway API:**
  - Gateway: `shopx-gateway` (GatewayClass: `istio`)
  - Integration: `shared-gateway-int` (`gateway-api` namespace, hostname: `shopx.jksoam.in`)
  - HTTPRoutes:
    - `/` ➔ `frontend` (Port 80)
    - `/api/auth` ➔ `auth` (Port 8081)
    - `/api/shops` ➔ `shop` (Port 8082)
    - `/api/products` ➔ `product` (Port 8083)
    - `/api/inventories` ➔ `inventory` (Port 8084)
    - `/api/orders` ➔ `order` (Port 8085)
    - `/api/payments` ➔ `payment` (Port 8087)
    - `/api/notifications` ➔ `notification` (Port 8088)
    - `/api/reviews` ➔ `review` (Port 8086)
    - `/api/users` ➔ `user` (Port 8089)
- **Database:** PostgreSQL (with GKE default `standard-rwo` PVC storage class)
- **Monitoring & Observability:** Baseline repo (`gitops-gcp-bootstrap`) handles cluster observability (Alloy, Prometheus, Grafana, etc.)

---

## 📁 Repository Layout

```
gitops-gcp-apps/
├── apps/
│   └── shopx/
│       ├── base/
│       │   ├── namespace.yaml                # Ambient mesh labels & gateway access
│       │   ├── waypoint.yaml                 # Istio ambient waypoint proxy (HBONE)
│       │   ├── postgres.yaml                 # PostgreSQL with GKE PVC
│       │   ├── auth-service.yaml             # Auth microservice
│       │   ├── shop-service.yaml             # Shop microservice
│       │   ├── product-service.yaml          # Product catalog microservice
│       │   ├── inventory-service.yaml        # Inventory microservice
│       │   ├── order-service.yaml            # Order microservice
│       │   ├── payment-service.yaml          # Payment microservice
│       │   ├── notification-service.yaml     # Notification microservice
│       │   ├── review-service.yaml           # Review microservice
│       │   ├── user-service.yaml             # User microservice
│       │   ├── frontend-service.yaml         # React frontend with Nginx
│       │   └── kustomization.yaml            # Base kustomization
│       └── envs/
│           └── gke-prod-01/
│               ├── gateway.yaml              # Kubernetes Gateway API Gateway
│               ├── httproutes.yaml           # HTTPRoutes for all 10 endpoints
│               └── kustomization.yaml        # Image tags & overlay
├── charts/
│   ├── helm-global-templates/               # Central reusable templates library chart
│   │   ├── charts/global-templates/
│   │   ├── push-to-registry.ps1              # Push helper script for OCI
│   │   └── push-to-registry.sh
│   └── shopx-v1.0.0/                         # Helm chart using oci://registry-1.docker.io/varunsoam/global-templates
└── bootstrap/
    └── gke-prod-01-appset-cluster-apps.yaml # ArgoCD ApplicationSet discovering apps/*/envs/gke-prod-01
```

---

## 🚀 ArgoCD Automatic Deployment

`gitops-gcp-apps/bootstrap/gke-prod-01-appset-cluster-apps.yaml` ArgoCD ApplicationSet automatically matches:
```yaml
directories:
  - path: apps/*/envs/gke-prod-01
```
- App name: `gke-prod-01-shopx`
- Destination namespace: `shopx`

## 📦 Helm Library Chart OCI Push

Agar aapko library chart Docker Hub par dubara push karna ho:
```bash
# 1. Login to Docker Hub registry
helm registry login registry-1.docker.io -u <username>

# 2. Package & Push
cd charts/helm-global-templates
.\push-to-registry.ps1
# Ya manual command:
helm package charts/global-templates
helm push global-templates-1.16.20.tgz oci://registry-1.docker.io/varunsoam
```
