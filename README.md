# blender-python-module
This repo builds blender as python module in a docker container.

## Build new Blender image
Run `./build-nightly-precompiled-deps.sh` to build new Blender image.

## Usage
Please copy the python scripts into the `./data` folder and run it with `docker run` or mount the desired folder to `/home/blender/data`.

## Example
```
docker run -v $PWD/data:/home/blender/data vo3xel/blender-python-module:2.93.3 test.py
```
## References
* [Blender](https://www.blender.org/)
* [Python](https://www.python.org/)
* [Docker](https://www.docker.com)

## Acknowledgements
This work was part of the iDev40 project.

The iDev40 project has received funding from the ECSEL Joint Undertaking (JU) under grant agreement No 783163. The JU receives support from the European Union’s Horizon 2020 research and innovation programme. It is co-funded by the consortium members, grants from Austria, Germany, Belgium, Italy, Spain and Romania. The code was developed at Virtual Vehicle Research GmbH in Graz and partially funded within the COMET K2 Competence Centers for Excellent Technologies from the Austrian Federal Ministry for Climate Action (BMK), the Austrian Federal Ministry for Digital and Economic Affairs (BMDW), the Province of Styria (Dept. 12) and the Styrian Business Promotion Agency (SFG). The Austrian Research Promotion Agency (FFG) has been authorised for the programme management.

This repository is released as publication on Zenodo, if this work is used within other projects it is required to cite this work with the following DOI:

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.5167141.svg)](https://doi.org/10.5281/zenodo.5167141)
