local kp =
  (import 'kube-prometheus/kube-prometheus.libsonnet') + 
  {
    _config+:: {
      namespace: 'monitoring',
      versions+:: {
        prometheus: "v2.9.2",
      },
    },

    prometheus+:: {
      prometheus+: {
        spec+: {
          replicas: 1,
          remoteWrite: [
            {
              url: 'https://demo.t.orangesys.io/api/v1/receive',
            },
          ],
        },
      },
    },
  };

{ ['00namespace-' + name]: kp.kubePrometheus[name] for name in std.objectFields(kp.kubePrometheus) } +
{ ['0prometheus-operator-' + name]: kp.prometheusOperator[name] for name in std.objectFields(kp.prometheusOperator) } +
{ ['node-exporter-' + name]: kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter) } +
{ ['kube-state-metrics-' + name]: kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) } +
{ ['prometheus-' + name]: kp.prometheus[name] for name in std.objectFields(kp.prometheus) } +
{ ['prometheus-adapter-' + name]: kp.prometheusAdapter[name] for name in std.objectFields(kp.prometheusAdapter) }
