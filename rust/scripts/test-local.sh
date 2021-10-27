#!/bin/bash

set -e

SCRIPTS_DIRECTORY="$(dirname "${0}")"
PLAN_DIRECTORY="$(dirname "${SCRIPTS_DIRECTORY}")"

bio pkg install --binlink core/bats

source "${PLAN_DIRECTORY}/plan.sh"

if [ -n "${SKIP_BUILD}" ]; then
  source "${PLAN_DIRECTORY}/results/last_build.env"

  bio pkg install --binlink --force "${PLAN_DIRECTORY}/results/${pkg_artifact}"
else
  pushd "${PLAN_DIRECTORY}"
  build
  popd

  source "${PLAN_DIRECTORY}/results/last_build.env"

  bio pkg install --binlink --force "${PLAN_DIRECTORY}/results/${pkg_artifact}"
fi

bats "${SCRIPTS_DIRECTORY}/test-local.bats"