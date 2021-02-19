# blender-python-module
This repo builds blender as python module in a docker container.

## Usage
Please copy the python scripts into the `./data` folder and run it with `docker run` or mount the desired folder to `/home/blender/data`.

## Example
```
docker run -v $PWD/data:/home/blender/data vo3xel/blender-python-module:2.93.0-alpha test.py
```
