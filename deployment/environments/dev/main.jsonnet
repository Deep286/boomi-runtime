(import '../default/main.jsonnet') + {
  // Development environment overrides
  _config+:: {
    name: 'boomi-molecule-dev',
    namespace: 'boomi-dev',
    cpuRequest: '250m',
    memoryRequest: '2Gi',
    cpuLimit: '500m',
    memoryLimit: '4Gi',
  },
}
