pkg_name=bats
pkg_origin=themelio
pkg_version=1.5.0
pkg_maintainer="Meade Kincke <meade@themelio.org>"
pkg_description="\
Bats is a TAP-compliant testing framework for Bash. It provides a simple way \
to verify that the UNIX programs you write behave as expected.\
"
pkg_upstream_url="https://github.com/bats-core/bats-core"
pkg_dirname="bats-core-${pkg_version}"
pkg_license=('MIT')
pkg_source="https://github.com/bats-core/bats-core/archive/refs/tags/v$pkg_version.zip"
pkg_shasum="435fd37f8933856d96f24c4b6440e5fe39b38d08cff0fae0de92359e784e403a"
pkg_deps=(
  core/bash
  core/coreutils
  core/sed
)
pkg_bin_dirs=(bin)

do_build() {
  fix_interpreter 'install.sh' core/coreutils bin/env
  fix_interpreter 'bin/bats' core/coreutils bin/env
  fix_interpreter 'libexec/*' core/coreutils bin/env

  # Rename the bats-core/ folder to bats/
  sed -i 's/BATS_ROOT\/libexec\/bats-core\/bats/BATS_ROOT\/lib\/bats\/bats/g' bin/bats

  # Rename the bats-core/ folder to bats/
  sed -i 's/BATS_ROOT\/lib\/bats-core\//BATS_ROOT\/lib\/bats\//g' libexec/bats-core/*
}

do_check() {
  cp -R lib/bats-core/ lib/bats
  cp -R libexec/bats-core/* lib/bats/
  fix_interpreter 'lib/bats/*' core/coreutils bin/env
  fix_interpreter '*' core/coreutils bin/env

  ./bin/bats --print-output-on-failure --tap test
}

do_install() {
  mkdir -p "$pkg_prefix/lib"

  for fn in libexec/bats-core/*; do
    install -Dm755 ${fn} "${pkg_prefix}/lib/bats/$(basename ${fn})"
  done

  install -Dm755 bin/bats "${pkg_prefix}/bin/bats"

  install -Dm755 lib/bats-core/* -t "${pkg_prefix}/lib/bats"

  fix_interpreter "${pkg_prefix}/lib/bats/*" core/coreutils bin/env
}