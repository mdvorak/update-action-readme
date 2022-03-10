# Update README Inputs/Outputs Action

Renders Markdown tables for inputs and outputs from `actions.yaml` file.

## Usage

Add following lines to Markdown file:

<pre>
&lt;!--(inputs&#45;start)-->
&lt;!--(inputs&#45;end)-->

&lt;!--(outputs&#45;start)-->
&lt;!--(outputs&#45;end)-->
</pre>

This action will always replace contents between start/end tags. Only one pair might be used.

The script [update_readme.sh](./update_readme.sh) is also usable on its own:

```bash
update_readme.sh [target file = README.md] [action definition = action.yaml]
```

### Example Workflow

```yaml
name: Update README.md
on:
  push:
    branches: [ "**" ]
    paths:
      - action.yaml
  workflow_dispatch:

jobs:
  generate:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
    steps:
      - name: Checkout
        uses: actions/checkout@v2

      - name: Update README.md
        uses: csas-actions/update-action-readme@v1

      - name: Create Pull Request
        uses: peter-evans/create-pull-request@v3
        with:
          title: "Update README.md tables"
          commit-message: "docs(readme): updated README.md inputs table"
          body: "Updated README.md inputs/outputs tables, according to action.yaml file"
          branch: bot/update-readme
          delete-branch: true
          labels: bot,docs
```

### Inputs

<!--(inputs-start)-->
<!--(inputs-end)-->

### Requirements

Action internally uses `sed`, `awk` and `yq`.
