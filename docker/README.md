# Dockerized MTEX

This folder contains resources to create and run a Docker image for MATLAB with MTEX installed.

## Setup

1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop) if you haven't already.

2. From a terminal, navigate to this folder and create a `.env` file:

    ```bash
    cp template.env .env
    ```

    Edit the `.env` file to set the following environment variables:
    - `MATLAB_VERSION`, `MTEX_VERSION`: versions of MATLAB and MTEX to use. Note that the MTEX
    version can be different from the state of the repository.
    - `MATLAB_DATA`: will be mounted as the `/data` volume in the container. Think of it as a "shared folder" between your host machine and the container.
    - `MLM_LICENSE_FILE`: path to MATLAB's license file or server. If using a file, it will have to be mounted into and match the path inside the container, e.g. copy it to `$MATLAB_DATA/license.lic`, and set this variable to `/data/license.lic`.

3. Build the Docker image using:

   ```bash
   docker compose build
   ```

## Usage

Once the image is built, you can run the container using:

   ```bash
   docker compose up
   ```

Open your web browser and navigate to `http://localhost:8888`.
