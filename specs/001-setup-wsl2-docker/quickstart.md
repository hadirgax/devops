# Quickstart

To install Docker Engine on WSL2 using this configuration:

1. Open a WSL2 terminal (e.g., Ubuntu).
2. Navigate to the devops workspace.
3. Run the setup script with the `setup_docker` function:

```bash
./setup_devenv/windows/setup-wsl2.sh setup_docker
```

4. You will be prompted for your `sudo` password.
5. Once the script finishes, log out and log back in (or restart your WSL session) to apply the `docker` group membership.
6. Verify the installation:

```bash
docker run hello-world
```
