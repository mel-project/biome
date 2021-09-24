#!/bin/bash

set -e

TESTDIR="$(dirname "${0}")"
PLAN_DIRECTORY="$(dirname "${TESTDIR}")"

bio pkg install --binlink core/bats
bio pkg install --binlink core/curl
bio pkg install --binlink core/nmap

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

echo "Sleeping for 5 seconds for the service to start."
sleep 5

if bats "${TESTDIR}/test.bats"; then
  bio svc unload "${pkg_ident}"
else
  bio svc unload "${pkg_ident}"
  exit 1
fi