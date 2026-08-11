# blender-python-module

[![Build](https://github.com/vo3xel/blender-python-module/actions/workflows/build.yml/badge.svg)](https://github.com/vo3xel/blender-python-module/actions/workflows/build.yml)
[![DOI](https://img.shields.io/badge/DOI-10.5281%2Fzenodo.5167140-blue.svg)](https://doi.org/10.5281/zenodo.5167140)

Blender compiled as Python module ([`bpy`](https://docs.blender.org/api/current/info_advanced_blender_as_bpy.html)), packed in a slim Docker image — for every current Blender release and the nightly `main` branch.

## Quick start

Run a Python script that uses `bpy` from a mounted folder (the container's working directory is `/home/blender/data`):

```bash
docker run --rm -v "$PWD/data":/home/blender/data ghcr.io/vo3xel/blender-python-module:4.5.12 test.py
```

Or use it interactively:

```bash
docker run --rm -it ghcr.io/vo3xel/blender-python-module:nightly
```

```pycon
>>> import bpy
>>> bpy.app.version_string
```

Release images are tagged `X.Y.Z` and `X.Y`, the newest release is also tagged `latest`, and nightly images are tagged `nightly` and `nightly-X.Y.Z-cycle`.

## Supported versions

The buildable releases and their bundled Python versions are defined in [versions.json](versions.json), which is kept up to date automatically (see [Updating the version matrix](#updating-the-version-matrix)). At the time of writing:

| Blender | Python |
|---------|--------|
| 4.2.23 (LTS) | 3.11 |
| 4.3.2 | 3.11 |
| 4.4.3 | 3.11 |
| 4.5.12 (LTS) | 3.11 |
| 5.0.1 | 3.11 |
| 5.1.2 | 3.13 |
| 5.2.0 | 3.13 |
| nightly (`main`) | auto-detected |

> **Why nothing older than 4.2?** Versions 2.93–4.1 fetched their precompiled libraries from `svn.blender.org`, which Blender has decommissioned (along with `git.blender.org`). Those versions can no longer be built from source with precompiled libraries. If you need an older release as a Python module, the official wheels are archived at <https://download.blender.org/pypi/bpy/>.

## How it works

A single parameterized, multi-stage [Dockerfile](Dockerfile) covers all versions:

1. **Builder stage** (Ubuntu 24.04): clones [projects.blender.org](https://projects.blender.org/blender/blender) at the requested tag or `main`, fetches the matching precompiled libraries (git-LFS submodule `lib/linux_x64`), compiles with `make bpy`, and packages the module as a wheel using Blender's official `make_bpy_wheel.py`.
2. **Runtime stage** (`python:X-slim`): installs just the wheel plus a handful of shared libraries and runs as a non-root user — the final image carries none of the build tree.

## Building locally

```bash
# list all buildable versions
./build.sh list

# build one release
./build.sh 4.5.12

# build the nightly (version and Python are auto-detected from Blender's main branch)
./build.sh nightly

# build every release + the nightly
./build.sh all
```

Each build finishes with a smoke test ([data/test.py](data/test.py)) that imports `bpy` and saves a `.blend` file.

| Option | Effect |
|--------|--------|
| `--no-test` | skip the smoke test |
| `--push` | push the image after a successful build/test |
| `IMAGE_REPO=...` | override the default `ghcr.io/vo3xel/blender-python-module` repository |

> **Note:** a from-source Blender build needs roughly 40 GB of disk and takes 30–90 minutes per version depending on your machine.

## CI

[.github/workflows/build.yml](.github/workflows/build.yml) builds the full matrix from `versions.json` on every relevant push and builds the nightly image on a daily schedule. Images are pushed to the GitHub Container Registry (`ghcr.io`) using the workflow's built-in `GITHUB_TOKEN` — no extra secrets are needed.

CI uses a registry build cache (`cache-<target>` tags on the same repository), so rebuilds of unchanged versions skip the hour-long compile and finish in minutes. The clone layer is keyed on the upstream commit sha, which keeps release caches immutable while the nightly re-clones whenever Blender's `main` moves. Every build — cached or not — still ends with the smoke test.

## Updating the version matrix

The version matrix updates itself: the daily scheduled run executes [scripts/update_versions.py](scripts/update_versions.py), which compares `versions.json` against Blender's release tags, detects the bundled Python and required GCC for anything new directly from the tag's build files, commits the updated matrix, and builds the new versions in the same run. The nightly build tracks `main` automatically as well.

Manual edits to `versions.json` still work — push one and CI rebuilds the matrix.

## License

The code to build Blender as a Docker image (Dockerfile and scripts) is released under MIT license. To use Blender please follow the license provided by [Blender](https://www.blender.org/about/license).

## References

* [Blender](https://www.blender.org/)
* [Building Blender as a Python module](https://developer.blender.org/docs/handbook/building_blender/python_module/)
* [Python](https://www.python.org/)
* [Docker](https://www.docker.com)

## Acknowledgements

This work was part of the iDev40 project.

The iDev40 project has received funding from the ECSEL Joint Undertaking (JU) under grant agreement No 783163. The JU receives support from the European Union’s Horizon 2020 research and innovation programme. It is co-funded by the consortium members, grants from Austria, Germany, Belgium, Italy, Spain and Romania. The code was developed at Virtual Vehicle Research GmbH in Graz and partially funded within the COMET K2 Competence Centers for Excellent Technologies from the Austrian Federal Ministry for Climate Action (BMK), the Austrian Federal Ministry for Digital and Economic Affairs (BMDW), the Province of Styria (Dept. 12) and the Styrian Business Promotion Agency (SFG). The Austrian Research Promotion Agency (FFG) has been authorised for the programme management.

This repository is released as publication on Zenodo, if this work is used within other projects it is required to cite this work with the following DOI:

[![DOI](https://img.shields.io/badge/DOI-10.5281%2Fzenodo.5167140-blue.svg)](https://doi.org/10.5281/zenodo.5167140)
