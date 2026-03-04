# Miniconda Devcontainer

The remote user of this devcontainer is `devcon`.

## Removed Packages

- **libsm6**: X Window System library for graphical user interfaces (GUIs).
- **libxext6**: X11 extensions library for GUI applications.
- **libxrender1**: X Rendering Extension client library for GUI applications.

## References

* Continuumio [Miniconda3](https://github.com/ContinuumIO/docker-images/blob/main/miniconda3/debian/Dockerfile)
* Docker buildpack deps [base-ubuntu](https://github.com/docker-library/buildpack-deps/blob/master/ubuntu/noble/curl/Dockerfile)
* MS devcontainer [miniconda](https://github.com/devcontainers/images/blob/main/src/miniconda/.devcontainer/Dockerfile)
