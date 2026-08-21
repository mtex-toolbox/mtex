# syntax=docker/dockerfile:1
# MATLAB container with MTEX installed.
# Unless you know what you are doing, see docker-compose.yaml instead
#
# For additional toolboxes, see: https://github.com/mathworks-ref-arch/matlab-dockerfile/tree/main/alternates
# To build and run the container, you need to provide a license server or license file:
# build:
#   export MLM_LICENSE_FILE=27000@MyServerName
#   docker build --build-arg MLM_LICENSE_FILE=${MLM_LICENSE_FILE} -t mtex-matlab .
# run (cli):
#   docker run -it --rm -e MLM_LICENSE_FILE=${MLM_LICENSE_FILE} mtex-matlab
# run (browser):
#   docker run -it --rm -p 8888:8888 --shm-size=512M -e MLM_LICENSE_FILE=${MLM_LICENSE_FILE} mtex-matlab -browser
#
# The two version arguments are named as docker-compose.yaml, template.env and
# the README name them. They have to stay in step: a build arg the Dockerfile
# does not declare is silently dropped, so a mismatch does not fail the build,
# it just bakes the defaults below into an image tagged as something else.

ARG MATLAB_VERSION=R2026a
FROM mathworks/matlab:$MATLAB_VERSION

ARG MATLAB_VERSION
ARG MTEX_VERSION=7.0.0
ARG MLM_LICENSE_FILE

# Install MTEX following https://mtex-toolbox.github.io/download#installation
RUN wget -q https://github.com/mtex-toolbox/mtex/releases/download/mtex-${MTEX_VERSION}/mtex-${MTEX_VERSION}.zip \
    && unzip mtex-${MTEX_VERSION}.zip -d /home/matlab \
    && rm mtex-${MTEX_VERSION}.zip

WORKDIR /home/matlab/mtex-${MTEX_VERSION}
RUN matlab -batch "install_mtex; mex_install; check_mex; startup_mtex;"

# Python environment (for pyenv integration)
USER root
RUN python3 -m venv /opt/venv
# RUN /opt/venv/bin/pip install ...

# Adding these to the matlabrc.m seems to be the only way to get consistent
# behavior across users and ways of launching MATLAB (cli/-browser)
# python3 rather than a pinned python3.x: the interpreter version follows
# whichever Ubuntu the MATLAB base image is built on and changes under us
RUN cat << EOF >> /opt/matlab/$MATLAB_VERSION/toolbox/local/matlabrc.m
addpath('/mtex-tools');
addpath('/home/matlab/mtex-${MTEX_VERSION}');
pyenv(Version='/opt/venv/bin/python3');
EOF

USER matlab
VOLUME /mtex-tools
WORKDIR /mtex-tools
