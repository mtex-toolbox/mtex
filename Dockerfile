# MATLAB container with MTEX installed.
# For additional toolboxes, see: https://github.com/mathworks-ref-arch/matlab-dockerfile/tree/main/alternates
# To build and run the container, you need to provide a license server or license file:
# build:
#   export MLM_LICENSE_FILE=27000@MyServerName
#   docker build --build-arg MLM_LICENSE_FILE=${MLM_LICENSE_FILE} -t mtex-matlab .
# run (cli):
#   docker run -it --rm -e MLM_LICENSE_FILE=${MLM_LICENSE_FILE} mtex-matlab
# run (browser):
#   docker run -it --rm -p 8888:8888 --shm-size=512M -e MLM_LICENSE_FILE=${MLM_LICENSE_FILE} mtex-matlab -browser

ARG MATLAB_RELEASE=R2025a
FROM mathworks/matlab:$MATLAB_RELEASE

ARG MTEX_RELEASE=6.2.beta.3
ARG MLM_LICENSE_FILE

# Install MTEX following https://mtex-toolbox.github.io/download#installation
RUN wget -q https://github.com/mtex-toolbox/mtex/releases/download/mtex-${MTEX_RELEASE}/mtex-${MTEX_RELEASE}.zip \
    && unzip mtex-${MTEX_RELEASE}.zip -d /home/matlab \
    && rm mtex-${MTEX_RELEASE}.zip

WORKDIR /home/matlab/mtex-${MTEX_RELEASE}
RUN matlab -batch "startup_mtex"

# Not sure if this is necessary, got the warning:
# "Not all mex files are running. You might want to call mex_install('force') to compile the mex files yourself."
RUN matlab -batch 'mex_install("force")'
RUN matlab -batch 'savepath'
