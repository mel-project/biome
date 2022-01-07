#!/bin/bash

set -ex

SCRIPTS_DIRECTORY="$(dirname "${0}")"
PLAN_DIRECTORY="$(dirname "${SCRIPTS_DIRECTORY}")"

sudo bio pkg install --binlink core/bats
sudo bio pkg install --binlink core/curl
sudo bio pkg install --binlink core/net-tools --force

wget -q https://github.com/themeliolabs/artifacts/raw/master/htmlq
chmod +x htmlq
sudo mv htmlq /bin

#cp "${PLAN_DIRECTORY}/plan-debug.sh" "${PLAN_DIRECTORY}/plan.sh"

source "${PLAN_DIRECTORY}/plan.sh"

sudo bio sup run &

bio pkg build "${pkg_name}"

source results/last_build.env

sudo bio pkg install --binlink --force "results/${pkg_artifact}"

sudo useradd hab -s /bin/bash -p '*'

#export DISABLE_HEALTH_CHECK=true

sudo bio svc load "${pkg_ident}"

echo "Sleeping for 7 seconds for the service to start."
sleep 7

if bats "${SCRIPTS_DIRECTORY}/test.bats"; then
  sudo rm -rf /bin/htmlq
  sudo bio svc unload "${pkg_ident}"
else
  sudo rm -rf /bin/htmlq
  sudo bio svc unload "${pkg_ident}"
  exit 1
fi