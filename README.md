# blender-lts-python-module
This repo builds blender LTS as python module.

## Usage
Please copy the python scripts into the `./data` folder and run it with docker run or mount the desired folder to `/home/blender/data`.

## Example
```
docker run -v $PWD/data:/home/blender/data vo3xel/blender-lts-python-module:2.83.5 test.py
```
