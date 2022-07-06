#!/bin/bash

set -e

SCRIPTS_DIRECTORY="$(dirname "${0}")"
PLAN_DIRECTORY="$(dirname "${SCRIPTS_DIRECTORY}")"

bio pkg install --binlink themelio/bats
bio pkg install --binlink core/curl
bio pkg install --binlink core/net-tools

wget -q https://github.com/themeliolabs/artifacts/raw/master/htmlq
chmod +x htmlq
mv htmlq /hab/bin

source "${PLAN_DIRECTORY}/plan.sh"

if [ -n "${SKIP_BUILD}" ]; then
  source "${PLAN_DIRECTORY}/results/last_build.env"

  BIO_SVC_STATUS="$(bio svc status)"
  NO_SERVICES_LOADED="No services loaded."

  if [ "$BIO_SVC_STATUS" == "$NO_SERVICES_LOADED" ]; then
    bio pkg install --binlink --force "${PLAN_DIRECTORY}/results/${pkg_artifact}"
    bio svc load "${pkg_ident}"
  else
    bio svc unload "${pkg_ident}" || true
    bio pkg install --binlink --force "${PLAN_DIRECTORY}/results/${pkg_artifact}"
    sleep 1
    bio svc load "${pkg_ident}"
  fi
else
  pushd "${PLAN_DIRECTORY}"
  build
  popd

  source "${PLAN_DIRECTORY}/results/last_build.env"

  BIO_SVC_STATUS="$(bio svc status)"
  NO_SERVICES_LOADED="No services loaded."

  if [ "$BIO_SVC_STATUS" == "$NO_SERVICES_LOADED" ]; then
    bio pkg install --binlink --force "${PLAN_DIRECTORY}/results/${pkg_artifact}"
    bio svc load "${pkg_ident}"
  else
    bio svc unload "${pkg_ident}" || true
    bio pkg install --binlink --force "${PLAN_DIRECTORY}/results/${pkg_artifact}"
    sleep 1
    bio svc load "${pkg_ident}"
  fi
fi

echo "Sleeping for 10 seconds for the service to start."
sleep 10

if bats --print-output-on-failure "${SCRIPTS_DIRECTORY}/test-local.bats"; then
  rm -rf /hab/bin/htmlq
  bio svc unload "${pkg_ident}"
else
  rm -rf /hab/bin/htmlq
  bio svc unload "${pkg_ident}"
  exit 1
fi