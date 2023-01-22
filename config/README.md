## Important Note

1. `core.yaml` file is required by the CLI but we are not customizing the file directly as we pass the required environment variables to the docker container directly.
2. `orderer.yaml` file is required by the CLI but we are not customizing the file directly as we pass the required environment variables to the docker container directly.
3. `configtx.yaml` present in this directory is not used by the fabric, instead we use one defined in configtx folder, this is required to maintain the format of the config folder.

These files are required by `FABRIC_CFG_PATH` but in out script we manually use other files and  config defined in docker manifest.