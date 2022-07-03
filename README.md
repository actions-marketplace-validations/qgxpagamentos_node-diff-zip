# Github Action for Node JS

Essa Action gera um arquivo ZIP de um projeto `node` ele confere se ocorreu diferença em arquivos `.js` controlando com checksum.

## Uso

`.github/workflows/push.yml`

```yaml
on: push
name: deploy
jobs:
  deploy:
    name: deploy to cluster
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v2

      - name: Build node diff checksum
        uses: qgxpagamentos/node-diff-zip
        with:
          destination: deployment/terraform
          zipfile: lambda.zip
```