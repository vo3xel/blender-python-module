# blender-python-module
This repo builds blender as python module in a docker container.

## Build new Blender image
Run `./build-nightly-precompiled-deps.sh` to build new Blender image.

## Usage
Please copy the python scripts into the `./data` folder and run it with `docker run` or mount the desired folder to `/home/blender/data`.

## Example
```
docker run -v $PWD/data:/home/blender/data vo3xel/blender-python-module:2.93.0-alpha test.py
```
## References
* [Blender](https://www.blender.org/)
* [Python](https://www.python.org/)
* [Docker](https://www.docker.com)

## Acknowledgements
