pkg_name=prometheus
pkg_description="Prometheus monitoring"
pkg_upstream_url=http://prometheus.io
pkg_origin=themelio
pkg_version=2.29.2
pkg_maintainer="Meade Kincke <meade@themelio.org>"
pkg_license=('Apache-2.0')
pkg_bin_dirs=(bin)
pkg_source="https://github.com/prometheus/prometheus/archive/v${pkg_version}.tar.gz"
pkg_shasum=8ac87a7d0982750618cb416d07c85aeb17df200e73da28d5e98d4b89476c26b9
prom_pkg_dir="${HAB_CACHE_SRC_PATH}/${pkg_name}-${pkg_version}"
prom_build_dir="${prom_pkg_dir}/src/${pkg_source}"
pkg_build_deps=(
  core/cacerts
  core/gcc
  themelio/go
  core/make
  core/yarn
  core/which
)
pkg_deps=(
  core/coreutils
  core/gettext
)
pkg_exports=(
  [port]=port
)
pkg_exposes=(port)
#pkg_binds_optional=(
#  [targets]="metric-http-port"
#)
pkg_svc_user="root"
pkg_svc_group="$pkg_svc_user"

do_setup_environment() {
  export GOPATH="${HAB_CACHE_SRC_PATH}/${pkg_dirname}"
}

do_unpack() {
  mkdir -p "${prom_pkg_dir}/src/github.com/prometheus/prometheus"
  pushd "${prom_pkg_dir}/src/github.com/prometheus/prometheus" || exit 1
  tar xf "${HAB_CACHE_SRC_PATH}/${pkg_filename}" --strip 1 --no-same-owner
  popd || exit 1
}

do_build() {
  pushd "${prom_pkg_dir}/src/github.com/prometheus/prometheus/web/ui/react-app"
  yarn install
  npm install
  fix_interpreter "node_modules/react-scripts/bin/react-scripts.js" core/coreutils bin/env
  popd


  pushd "${prom_pkg_dir}/src/github.com/prometheus/prometheus" || exit 1
  fix_interpreter "scripts/*" core/coreutils bin/env


  rm -rf /etc/ssl
  mkdir -p /etc/ssl
  ln -s "$(pkg_path_for core/cacerts)/ssl/certs/cacert.pem" /etc/ssl/ca-bundle.pem

  USER="root" PREFIX="${pkg_prefix}/bin" make build
  popd || exit 1

  rm -rf /etc/ssl
}

do_check() {
  pushd "${prom_pkg_dir}/src/github.com/prometheus/prometheus" || exit 1
  make test
  popd || exit 1
}

do_install() {
  return 0
}