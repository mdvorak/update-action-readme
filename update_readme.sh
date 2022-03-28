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
    yq e '.inputs | .[] | ["`" + key + "`", .required, .default // "", .description] | "| " + join(" | ") + " |"' "$ACTION_FILE"
    echo
  } >/tmp/TABLE.md

  sed "/<!--(inputs-start)-->/,/<!--(inputs-end)-->/{//!d;}" "$FILE" >/tmp/FILE.md
  awk '$0=="<!--(inputs-start)-->" {print;system("cat /tmp/TABLE.md");next}1' /tmp/FILE.md >"$FILE"
  rm -f /tmp/TABLE.md /tmp/FILE.md
}

render_outputs() {

  {
    echo
    echo "| Name  | Description |"
    echo "| :---: | ----------- |"
    yq e '.outputs | .[] | ["`" + key + "`", .description] | "| " + join(" | ") + " |"' "$ACTION_FILE"
    echo
  } >/tmp/TABLE.md

  sed "/<!--(outputs-start)-->/,/<!--(outputs-end)-->/{//!d;}" "$FILE" >/tmp/FILE.md
  awk '$0=="<!--(outputs-start)-->" {print;system("cat /tmp/TABLE.md");next}1' /tmp/FILE.md >"$FILE"
  rm -f /tmp/TABLE.md /tmp/FILE.md
}

>&2 echo "Updating $FILE according to $ACTION_FILE"
render_inputs
render_outputs
