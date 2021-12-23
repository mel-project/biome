#!/bin/bash

set -ex

SCRIPTS_DIRECTORY="$(dirname "${0}")"
PLAN_DIRECTORY="$(dirname "${SCRIPTS_DIRECTORY}")"

sudo bio pkg install --binlink core/bats
sudo bio pkg install --binlink core/curl
sudo bio pkg install --binlink core/net-tools

wget -q https://github.com/themeliolabs/artifacts/raw/master/htmlq
chmod +x htmlq
sudo mv htmlq /hab/bin

source "${PLAN_DIRECTORY}/plan.sh"

sudo bio sup run &

bio pkg build "${pkg_name}"

source results/last_build.env

sudo bio pkg install --binlink --force "results/${pkg_artifact}"

sudo useradd hab -s /bin/bash -p '*'

sudo bio svc load "${pkg_ident}"

echo "Sleeping for 5 seconds for the service to start."
sleep 5

if bats "${SCRIPTS_DIRECTORY}/test.bats"; then
  sudo rm -rf /hab/bin/htmlq
  sudo bio svc unload "${pkg_ident}"
else
  sudo rm -rf /hab/bin/htmlq
  sudo bio svc unload "${pkg_ident}"
  exit 1
fi