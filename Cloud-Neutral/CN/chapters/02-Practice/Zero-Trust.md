graph TD
  subgraph K8s Cluster
    SVC1[Service A (Sidecar+mTLS)]
    SVC2[Service B (Sidecar+mTLS)]
    EGR[Egress Gateway]
  end
  PKI[mTLS/SPIFFE PKI] -.-> SVC1
  PKI -.-> SVC2
  Policy[OPA/ABAC/IAM] -.-> SVC1
  Policy -.-> EGR
  SVC1 -- mTLS --> SVC2
  SVC1 --> EGR --> Internet((Internet))
