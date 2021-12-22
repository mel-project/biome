pkg_name=grafana
pkg_origin=themelio
pkg_version=8.3.3
pkg_maintainer="Meade Kincke <meade@themelio.org>"
pkg_license=("Apache-2.0")
pkg_upstream_url=https://grafana.com/
pkg_source="https://dl.grafana.com/oss/release/${pkg_name}-${pkg_version}.linux-amd64.tar.gz"
pkg_filename="${pkg_name}-${pkg_version}.linux-amd64.tar.gz"
pkg_shasum=89428c520e004bcb9faf7618dd4c81ff62496064cbf2ead3e1b9dbcf476c6f18
pkg_deps=(
  core/bash
  core/cacerts
  core/curl
  core/glibc
  core/wget
)
pkg_build_deps=(
  core/patchelf
)
pkg_bin_dirs=(bin)
pkg_description="Grafana graphing app, dynamically finds prometheus data sources"
pkg_exports=(
  [grafana_port]=listening_port
)
pkg_exposes=(grafana_port)
pkg_binds_optional=(
  [prom]="prom_ds_http"
  [loki]="loki_ds_http"
)
pkg_svc_user=root
pkg_svc_group="${pkg_svc_user}"

# we're using prebuilt binaries; no build stage required
do_build() {
  return 0
}

do_install() {
  cp -r conf public scripts plugins-bundled "${pkg_prefix}/"
  cp -r bin/* "${pkg_prefix}/bin/"
  patchelf \
    --interpreter "$(pkg_path_for glibc)/lib/ld-linux-x86-64.so.2" \
    "${pkg_prefix}/bin/grafana-server"
  patchelf \
    --interpreter "$(pkg_path_for glibc)/lib/ld-linux-x86-64.so.2" \
    "${pkg_prefix}/bin/grafana-cli"
}