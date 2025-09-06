// Default Boomi Molecule Deployment Configuration
{
  // Configuration variables
  _config:: {
    name: 'boomi-molecule',
    namespace: 'boomi-runtime',
    imageVersion: 'latest',
    replicas: 1,
    cpuRequest: '500m',
    memoryRequest: '4Gi',
    cpuLimit: '1000m',
    memoryLimit: '6Gi',
  },

  // Persistent Volume Claim for Boomi data
  pvc: {
    apiVersion: 'v1',
    kind: 'PersistentVolumeClaim',
    metadata: {
      name: 'boomi-storage',
      namespace: $._config.namespace,
      labels: {
        'app.kubernetes.io/name': $._config.name,
        'app.kubernetes.io/component': 'storage',
      },
    },
    spec: {
      accessModes: ['ReadWriteOnce'],
      resources: {
        requests: {
          storage: '10Gi',
        },
      },
    },
  },

  // Service Account
  serviceAccount: {
    apiVersion: 'v1',
    kind: 'ServiceAccount',
    metadata: {
      name: $._config.name + '-sa',
      namespace: $._config.namespace,
      labels: {
        'app.kubernetes.io/name': $._config.name,
        'app.kubernetes.io/component': 'serviceaccount',
      },
    },
  },

  // Deployment
  deployment: {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: $._config.name,
      namespace: $._config.namespace,
      labels: {
        'app.kubernetes.io/name': $._config.name,
        'app.kubernetes.io/component': 'runtime',
      },
    },
    spec: {
      replicas: $._config.replicas,
      selector: {
        matchLabels: {
          'app.kubernetes.io/name': $._config.name,
        },
      },
      template: {
        metadata: {
          labels: {
            'app.kubernetes.io/name': $._config.name,
            'app.kubernetes.io/component': 'runtime',
          },
        },
        spec: {
          serviceAccountName: $._config.name + '-sa',
          containers: [
            {
              name: 'boomi-molecule',
              image: 'boomi/molecule:' + $._config.imageVersion,
              ports: [
                { containerPort: 9090, name: 'http' },
                { containerPort: 8080, name: 'web' },
                { containerPort: 1099, name: 'jmx' },
              ],
              env: [
                {
                  name: 'ATOM_LOCALHOSTID',
                  valueFrom: { fieldRef: { fieldPath: 'spec.nodeName' } },
                },
                {
                  name: 'JAVA_TOOL_OPTIONS',
                  value: '-javaagent:/tmp/jmx_prometheus_javaagent-0.20.0.jar=1099:/tmp/jmx-config.yaml',
                },
                {
                  name: 'BOOMI_ATOMNAME',
                  valueFrom: { secretKeyRef: { name: 'boomi-secrets', key: 'BOOMI_ATOMNAME' } },
                },
                {
                  name: 'BOOMI_ACCOUNTID',
                  valueFrom: { secretKeyRef: { name: 'boomi-secrets', key: 'BOOMI_ACCOUNTID' } },
                },
                {
                  name: 'INSTALL_TOKEN',
                  valueFrom: { secretKeyRef: { name: 'boomi-secrets', key: 'INSTALL_TOKEN' } },
                },
              ],
              resources: {
                requests: {
                  cpu: $._config.cpuRequest,
                  memory: $._config.memoryRequest,
                },
                limits: {
                  cpu: $._config.cpuLimit,
                  memory: $._config.memoryLimit,
                },
              },
              volumeMounts: [
                {
                  name: 'boomi-data',
                  mountPath: '/mnt/boomi',
                },
              ],
              livenessProbe: {
                httpGet: {
                  path: '/_admin/liveness',
                  port: 9090,
                },
                initialDelaySeconds: 300,
                periodSeconds: 30,
                timeoutSeconds: 10,
              },
              readinessProbe: {
                httpGet: {
                  path: '/_admin/readiness',
                  port: 9090,
                },
                initialDelaySeconds: 120,
                periodSeconds: 10,
                timeoutSeconds: 5,
              },
              lifecycle: {
                preStop: {
                  exec: {
                    command: ['/bin/sh', '/opt/scripts/node_offboard.sh'],
                  },
                },
              },
            },
          ],
          volumes: [
            {
              name: 'boomi-data',
              persistentVolumeClaim: {
                claimName: 'boomi-storage',
              },
            },
          ],
          terminationGracePeriodSeconds: 300,
        },
      },
    },
  },

  // Service
  service: {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: $._config.name,
      namespace: $._config.namespace,
      labels: {
        'app.kubernetes.io/name': $._config.name,
        'app.kubernetes.io/component': 'service',
      },
    },
    spec: {
      selector: {
        'app.kubernetes.io/name': $._config.name,
      },
      ports: [
        { port: 80, targetPort: 9090, name: 'http' },
        { port: 8080, targetPort: 8080, name: 'web' },
        { port: 1099, targetPort: 1099, name: 'jmx' },
      ],
      type: 'ClusterIP',
    },
  },
}
