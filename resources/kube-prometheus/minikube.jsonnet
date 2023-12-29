local utils = import './utils.libsonnet';

local defaultStorageClass = '';

local kp =
  (import 'kube-prometheus/main.libsonnet') +
  // Uncomment the following imports to enable its patches
  // (import 'kube-prometheus/addons/anti-affinity.libsonnet') +
  // (import 'kube-prometheus/addons/managed-cluster.libsonnet') +
  // (import 'kube-prometheus/addons/node-ports.libsonnet') +
  // (import 'kube-prometheus/addons/static-etcd.libsonnet') +
  // (import 'kube-prometheus/addons/custom-metrics.libsonnet') +
  // (import 'kube-prometheus/addons/external-metrics.libsonnet') +
  // (import 'kube-prometheus/addons/pyrra.libsonnet') +
  {
    alertmanager+: {
      alertmanager+: {
        spec+: {
          replicas: 1,
//            configMaps: ['alert-templates'],
        },
      },
    },
    configmap+:: {
      'alert-templates': utils.configmap( 'alert-templates', 'monitoring', {'alertmanager-alert-template.tmpl': importstr 'alertmanager-alert-template.tmpl'}),
    },
//    grafana+:: {
//      serviceAccount+: {
//        metadata+: {
//          annotations: {
//            'eks.amazonaws.com/role-arn': 'grafana-role-arn',
//          },
//        },
//      },
//      deployment+: {
//        spec+: {
//            template+: {
//                spec+: {
//                    volumes: utils.toNamedArray(utils.toNamedMap(super.volumes) + utils.toNamedMap([
//                      {
//                        name: 'grafana-storage',
//                        persistentVolumeClaim: {
//                          claimName: 'grafana-storage',
//                        },
//                      },
//                    ]))
//                },
//            },
//        },
//      },
//    },
    prometheus+:: {
//      serviceAccount+: {
//        metadata+: {
//          annotations: {
//            'eks.amazonaws.com/role-arn': 'thanos-role-arn',
//          },
//        },
//      },
      clusterRole+: {
        rules+: [
          {
            apiGroups: [
              '',
            ],
            resources: [
              'services',
              'pods',
              'endpoints',
            ],
            verbs: [
              'get',
              'list',
              'watch',
            ],
          },
        ],
      },
      prometheus+: {
        spec+: {
          replicas: 1,
          retention: '12h',
          disableCompaction: true,
          storage: {
            volumeClaimTemplate: {
              apiVersion: 'v1',
              kind: 'PersistentVolumeClaim',
              spec: {
                accessModes: ['ReadWriteOnce'],
                resources: { requests: { storage: '10Gi' } },
                storageClassName: 'standard',
              },
            },
          },
        },
      },
    },
    kubeStateMetrics+:: {
      deployment+: {
        spec+: {
          template+: {
            spec+: {
              containers: utils.addArgs(['--metric-labels-allowlist=pods=[*]'], 'kube-state-metrics', super.containers),
            },
          },
        },
      },
    },
    values+:: {
      common+: {
        namespace: 'default',
      },
      grafana+:: {
        config: {
          sections: {
            'auth.anonymous': {
              enabled: true
            },
            'users': {
              allow_sign_up: false,
              auto_assign_org: true,
              auto_assign_org_role: 'Admin',
              viewers_can_edit: true,
            },
          },
        },
        folderDashboards+:: {
          Loki: {
            'loki-chunks.json': (import 'loki-chunks.json'),
            'loki-deletions.json': (import 'loki-deletions.json'),
            'loki-logs.json': (import 'loki-logs.json'),
            'loki-mixin-recording-rules.json': (import 'loki-mixin-recording-rules.json'),
            'loki-operational.json': (import 'loki-operational.json'),
            'loki-reads.json': (import 'loki-reads.json'),
            'loki-reads-resources.json': (import 'loki-reads-resources.json'),
            'loki-retention.json': (import 'loki-retention.json'),
            'loki-writes.json': (import 'loki-writes.json'),
            'loki-writes-resources.json': (import 'loki-writes-resources.json'),

          },

          K8S: {
            'k8s-views-namespaces.json': (import 'k8s-views-namespaces.json'),
            'k8s-views-pods.json': (import 'k8s-views-pods.json'),
            'k8s-hpa.json': (import 'k8s-hpa.json'),
          },

          Ingress: {
            'ingress-nginx.json': (import 'ingress-nginx-dashboard.json'),
          },
        },
//        rawDashboards+:: {
//          'ingress-nginx.json': (importstr 'ingress-nginx-dashboard.json'),
//        },
      },
    },
  };

{ 'setup/0namespace-namespace': kp.kubePrometheus.namespace } +
{
  ['setup/prometheus-operator-' + name]: kp.prometheusOperator[name]
  for name in std.filter((function(name) name != 'serviceMonitor' && name != 'prometheusRule'), std.objectFields(kp.prometheusOperator))
} +
// { 'setup/pyrra-slo-CustomResourceDefinition': kp.pyrra.crd } +
// serviceMonitor and prometheusRule are separated so that they can be created after the CRDs are ready
{ 'prometheus-operator-serviceMonitor': kp.prometheusOperator.serviceMonitor } +
{ 'prometheus-operator-prometheusRule': kp.prometheusOperator.prometheusRule } +
{ 'kube-prometheus-prometheusRule': kp.kubePrometheus.prometheusRule } +
{ ['alertmanager-' + name]: kp.alertmanager[name] for name in std.objectFields(kp.alertmanager) } +
{ ['blackbox-exporter-' + name]: kp.blackboxExporter[name] for name in std.objectFields(kp.blackboxExporter) } +
{ ['grafana-' + name]: kp.grafana[name] for name in std.objectFields(kp.grafana) } +
// { ['pyrra-' + name]: kp.pyrra[name] for name in std.objectFields(kp.pyrra) if name != 'crd' } +
{ ['kube-state-metrics-' + name]: kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) } +
{ ['kubernetes-' + name]: kp.kubernetesControlPlane[name] for name in std.objectFields(kp.kubernetesControlPlane) }
{ ['node-exporter-' + name]: kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter) } +
{ ['prometheus-' + name]: kp.prometheus[name] for name in std.objectFields(kp.prometheus) } +
{ ['prometheus-adapter-' + name]: kp.prometheusAdapter[name] for name in std.objectFields(kp.prometheusAdapter) }
