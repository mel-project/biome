#!/bin/bash

set -ex

export SCRIPTS_DIRECTORY="$(dirname "${0}")"
PLAN_DIRECTORY="$(dirname "${SCRIPTS_DIRECTORY}")"

source "${PLAN_DIRECTORY}/plan.sh"


bio pkg build "biome/${pkg_name}"

source results/last_build.env

hart_file="results/${pkg_artifact}"


echo "Publishing artifact to the stable channel"

bio pkg upload --auth "${HABITAT_AUTH_TOKEN}" --url "${HAB_BLDR_URL}" "${hart_file}" -c stable

# Uploading to the biome builder is currently broken.
#This can be uncommented when this bug report is remedied: https://github.com/biome-sh/biome/issues/14
#bio pkg upload --auth "${BIOME_AUTH_TOKEN}" --url "${BIOME_BLDR_URL}" "${hart_file}" -c stable


echo "Exporting docker image"
sudo bio pkg export container "${hart_file}"

source results/last_container_export.env

for tag in ${tags//,/ }; do
  local_tag="ghcr.io/themeliolabs/grafana:${tag}"

  docker tag "${name}:${tag}" "${local_tag}"

	docker push "${local_tag}"
done