#!/usr/bin/env bash

set -euo pipefail

FILE=${1:-README.md}
ACTION_FILE=${2}

# Smart action file name default
if [ -z "$ACTION_FILE" ]; then
  if [ -f action.yaml ]; then
    ACTION_FILE="action.yaml"
  else
    ACTION_FILE="action.yml"
  fi
fi

render_inputs() {
  {
    echo
    echo "| Name  | Required | Default | Description |"
    echo "| :---: | :------: | :-----: | ----------- |"
    # shellcheck disable=SC2016
    yq e '.inputs | .[] | ["`" + key + "`", .required, .default // "", .description | sub("\s+$", "") | sub("\n", "<br>")] | "| " + join(" | ") + " |"' "$ACTION_FILE"
    echo
  } >/tmp/TABLE.md

  sed "/<!--(inputs-start)-->/,/<!--(inputs-end)-->/{//!d;}" "$FILE" >/tmp/FILE.md
  awk '$0=="<!--(inputs-start)-->" {print;system("cat /tmp/TABLE.md");next}1' /tmp/FILE.md >"$FILE"
  rm -f /tmp/TABLE.md /tmp/FILE.md
}

render_outputs() {
  if [[ "$(yq e '.outputs' action.yml)" != "null" ]]; then
    {
      echo
      echo "| Name  | Description |"
      echo "| :---: | ----------- |"
      # shellcheck disable=SC2016
      yq e '.outputs | .[] | ["`" + key + "`", .description | sub("\s+$", "") | sub("\n", "<br>")] | "| " + join(" | ") + " |"' "$ACTION_FILE"
      echo
    } >/tmp/TABLE.md
  else
    echo "None" >/tmp/TABLE.md
  fi

  sed "/<!--(outputs-start)-->/,/<!--(outputs-end)-->/{//!d;}" "$FILE" >/tmp/FILE.md
  awk '$0=="<!--(outputs-start)-->" {print;system("cat /tmp/TABLE.md");next}1' /tmp/FILE.md >"$FILE"
  rm -f /tmp/TABLE.md /tmp/FILE.md
}

echo >&2 "Updating $FILE according to $ACTION_FILE"
render_inputs
render_outputs
