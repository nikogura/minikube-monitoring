{
  // Convert to map for easier overloading, assumes all array elements are maps having "name" field
  toNamedMap(array): { [x.name]: x for x in array },

  // Convert back to array
  toNamedArray(map): [{ name: x } + map[x] for x in std.objectFields(map)],
  addArgs(args, name, containers): std.map(
    function(c)
      if c.name == name then
        c {
          args+: args,
        }
      else c,
    containers,
  ),
  configmap(name, namespace, data): {
    apiVersion: 'v1',
    kind: 'ConfigMap',
    metadata: {
      name: name,
      namespace: namespace,
    },
    data: data,
  },

  pvc(name, namespace, size, storageClass): {
    apiVersion: 'v1',
    kind: 'PersistentVolumeClaim',
    metadata: {
      name: name,
      namespace: namespace,
    },
    spec: {
      storageClassName: storageClass,
      accessModes: [
        "ReadWriteOnce",
      ],
      resources: {
        requests: {
          storage: size + 'Gi',
        },
      },
    },
  },
}