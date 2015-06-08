
# Overseer

This is a reimplementation of my [Overseer](https://github.com/natebrennand/overseer) project in Ocaml.

Overseer is a tool that watches for file changes and calls a provided command every time a file changes.
This is done by walking the filesystem for changes in the `time_modified` attribute of a file.
It is not as efficient as watching for filesystem notifications but that method has proven unreliable on OS X due to spotlight indexing interferences.


## Usage

This example watches all `.ml` files in the directory and calls `make` any time one of them changes.

```bash
overseer *.ml -c make
```




