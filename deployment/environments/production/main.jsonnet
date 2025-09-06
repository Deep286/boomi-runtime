(import '../default/main.jsonnet') + {
  // Production environment overrides
  _config+:: {
    name: 'boomi-molecule-prod',
    namespace: 'boomi-production',
    replicas: 3,
    cpuRequest: '1000m',
    memoryRequest: '8Gi',
    cpuLimit: '2000m',
    memoryLimit: '12Gi',
  },
}
