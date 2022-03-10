#!/usr/bin/env bash

set -e

FILE=${1:-README.md}
ACTION_FILE=${2:-action.yaml}

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

render_inputs
render_outputs
