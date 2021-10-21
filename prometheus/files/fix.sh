#!/bin/bash

for t in node_modules/.bin/*; do
  t="$(readlink --canonicalize --no-newline "${t}")"
  sed -e "s#\#\!${INTERPRETER_OLD}#\#\!${INTERPRETER_NEW}#" -i "${t}"
done