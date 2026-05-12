# pytorch-ci-image-scripts

Personal customizations to the upstream PyTorch CI image
(`ghcr.io/pytorch/ci-image:pytorch-linux-noble-rocm-n-py3-<HASH>`): unwinds the
sccache clang wrappers, installs a few utilities, drops in my dotfiles, clones
PyTorch, and runs the default build so the resulting image is ready to develop
in.

## Usage

```sh
./build.sh
```

Produces `jeffdaily/pytorch:noble-rocm-7.2-py3-<YYYYMMDD>`. The base image
`HASH` is the tree SHA of `.ci/docker` on `pytorch/pytorch@main` (equivalent to
`git rev-parse HEAD:.ci/docker`), fetched live from the GitHub API — no local
PyTorch checkout required.

## Files

- `Dockerfile` — image recipe; takes `--build-arg HASH` for the upstream tag
- `build.sh` — resolves `HASH` + today's date, then builds
- `bootstrap.sh` — copied into the image at `~/bootstrap.sh` for one-time
  container setup (from
  [jeffdaily/claude-shared-public](https://github.com/jeffdaily/claude-shared-public))
- `.vimrc` — copied into the image at `~/.vimrc`
