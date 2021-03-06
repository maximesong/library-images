#!/bin/bash -e

: "${GF_PATHS_HOME:=/grafana}"
: "${GF_PATHS_DATA:=/grafana/data}"
: "${GF_PATHS_LOGS:=/grafana/logs}"
: "${GF_PATHS_PLUGINS:=/grafana/plugins}"
: "${GF_PATHS_CONF:=/grafana/conf}"

if [ ! -z ${GF_PATHS_CONF} ]; then
  cp -r /etc/grafana "$GF_PATHS_CONF"
fi

mkdir -p "$GF_PATHS_DATA" "$GF_PATHS_LOGS" "$GF_PATHS_PLUGINS"
chown -R grafana:grafana "$GF_PATHS_DATA" "$GF_PATHS_LOGS" "$GF_PATHS_CONF"

if [ ! -z ${GF_INSTALL_PLUGINS} ]; then
  OLDIFS=$IFS
  IFS=','
  for plugin in ${GF_INSTALL_PLUGINS}; do
    grafana-cli plugins install ${plugin}
  done
  IFS=$OLDIFS
fi

exec gosu grafana /usr/sbin/grafana-server  \
  --homepath=/usr/share/grafana             \
  --config="$GF_PATHS_CONF"/grafana.ini     \
  cfg:default.paths.data="$GF_PATHS_DATA"   \
  cfg:default.paths.logs="$GF_PATHS_LOGS"   \
  cfg:default.paths.plugins="$GF_PATHS_PLUGINS"
