# GitLab CLI

GitLab's unofficial command line tool

[![Hex.pm version](https://img.shields.io/hexpm/v/gitlab_cli.svg)](https://hex.pm/packages/gitlab_cli)

## Demo

- source repository: [https://gitlab.com/ThaddeusJiang/gitlab_cli](https://gitlab.com/ThaddeusJiang/gitlab_cli)
- target repository: [https://gitlab.com/ThaddeusJiang/gitlab_cli_deploy](https://gitlab.com/ThaddeusJiang/gitlab_cli_deploy)

## Usage

Used in `gitlab-ci.yml`:

```yaml
run:
  image: elixir:latest
  script:
    - mix local.hex --force
    - mix local.rebar --force
    - mix escript.install hex gitlab_cli --force
    - export PATH=$PATH:/root/.mix/escripts
    - gitlab_cli --project-id 54958131 \
      --source-branch "deploy-main" --target-branch "main" \
      --file-path "src/dev.yml" --pattern "charge-backend:.*" --content "charge-backend:${CI_COMMIT_SHA}"
```

Environment variables

- `GITLAB_PRIVATE_TOKEN` - The GitLab private token. (required)

Parameters

- `--project-id` - The GitLab project id. (required)
- `--source-branch` - The source branch. (required)
- `--target-branch` - The target branch. (required)
- `--file-path` - The file path. (required)
- `--pattern` - The pattern to search for. (required) syntax: `prefix:.*`
- `--content` - The content to replace with. (required) syntax: `prefix:new-value`

## Development

```bash
mix deps.get

iex -S mix
```

### Test

```bash
mix test
```

### Build

```bash
mix escript.build
```

### Publish

```bash
mix test
mix docs

mix hex.publish
```
