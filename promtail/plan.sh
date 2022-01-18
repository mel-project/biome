pkg_name=promtail
pkg_origin=themelio
pkg_version="2.4.2"
pkg_maintainer="Meade Kincke <meade@themelio.org>"
pkg_description="Promtail is an agent which ships the contents of local logs to a private Loki instance or Grafana Cloud."
pkg_license=('Apache-2.0')
pkg_upstream_url=https://github.com/grafana/loki
pkg_source="https://github.com/grafana/loki/archive/v${pkg_version}.tar.gz"
pkg_filename="v${pkg_version}.tar.gz"
pkg_shasum="725af867fa3bece6ccd46e0722eb68fe72462b15faa15c8ada609b5b2a476b07"
loki_pkg_dir="${HAB_CACHE_SRC_PATH}/${pkg_name}-${pkg_version}"
loki_build_dir="${loki_pkg_dir}/src/${pkg_source}"
pkg_build_deps=(
  core/bash
  core/busybox-static
  core/gcc
  core/git
  themelio/go
  core/make
  core/patchelf
)
pkg_deps=(
  core/cacerts
  core/coreutils
  core/glibc
  core/libgcrypt
  core/libgpg-error
  core/systemd
  core/tzdata
  core/zstd
)
pkg_bin_dirs=(bin)
pkg_binds_optional=(
  [loki]="http_port"
)
pkg_exports=(
  [http_port]=http_port
  [grpc_port]=grpc_port
)
pkg_exposes=(http_port grpc_port)
pkg_svc_user="root"
pkg_svc_group="$pkg_svc_user"


do_setup_environment() {
  export GOPATH="${HAB_CACHE_SRC_PATH}/${pkg_dirname}"
}

do_unpack() {
  mkdir -p "${loki_pkg_dir}/src/github.com/grafana/loki"
  pushd "${loki_pkg_dir}/src/github.com/grafana/loki" > /dev/null || exit 1
  tar xf "${HAB_CACHE_SRC_PATH}/${pkg_filename}" --strip 1 --no-same-owner
  popd > /dev/null || exit 1
}

do_prepare() {
  BASHBIN="$(pkg_path_for core/busybox-static)/bin/bash"

  pushd "${loki_pkg_dir}/src/github.com/grafana/loki" > /dev/null || exit 1
  sed -i "s,/usr/bin/env bash,${BASHBIN}," Makefile
  popd > /dev/null || exit 1
}

do_build() {
  pushd "${loki_pkg_dir}/src/github.com/grafana/loki" > /dev/null || exit 1


  rm -rf /etc/ssl
  mkdir -p /etc/ssl
  ln -s "$(pkg_path_for core/cacerts)/ssl/certs/cacert.pem" /etc/ssl/ca-bundle.pem

  sed -e "s#SHELL = /usr/bin/env bash#SHELL = $(pkg_path_for core/coreutils)/bin/env bash#" -i Makefile
  fix_interpreter "tools/image-tag" core/coreutils bin/env

#  make touch-protos
#  CGO_CFLAGS="-I$(pkg_path_for core/systemd)/include" make BUILD_IN_CONTAINER=false promtail

  CGO_CFLAGS="-I$(pkg_path_for core/systemd)/include" go build -trimpath -buildmode=pie -mod=readonly -modcacherw -ldflags "-X github.com/grafana/loki/pkg/util/build.Version=$pkg_version -X github.com/grafana/loki/pkg/util/build.BuildDate=$(date -u +'%Y-%m-%dT%H:%M:%SZ') -linkmode external -extldflags \"${LDFLAGS}\"" ./clients/cmd/promtail

  rm -rf /etc/ssl

  popd > /dev/null || exit 1
}

do_install() {
  pushd "${loki_pkg_dir}/src/github.com/grafana/loki" > /dev/null || exit 1
#  install -Dm755 clients/cmd/promtail/promtail "${pkg_prefix}/bin/promtail"
  install -Dm755 promtail "${pkg_prefix}/bin/promtail"
  popd > /dev/null || exit 1
}