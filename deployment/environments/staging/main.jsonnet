(import '../default/main.jsonnet') + {
  // Staging environment overrides
  _config+:: {
    name: 'boomi-molecule-staging',
    namespace: 'boomi-staging',
    replicas: 2,
    cpuRequest: '500m',
    memoryRequest: '4Gi',
    cpuLimit: '1000m',
    memoryLimit: '6Gi',
  },
}
