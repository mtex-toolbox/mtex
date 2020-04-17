
1. Download the FFTW

2. Download the NFFT

3. in a terminal do
./bootstrap.sh
./configure --with-matlab=MATLAB_DIR --enable-nfsoft --enable-nfsft --enable-portable-binary
make

4. copy the following files into this directory
nfft/matlab/nfsoft/nfsoftmex.mex*
nfft/matlab/nfsft/nfsftmex.mex*
