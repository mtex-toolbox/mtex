
1. Download the FFTW

2. Download the NFFT

3. in a terminal do
./bootstrap
./configure --with-matlab=MATLAB_DIR --enable-nfsoft --enable-nfsft --enable-openmp --enable-portable-binary 
make

4. copy the following files into this directory
nfft/matlab/nfsoft/nfsoftmex.mex* 
nfft/matlab/nfsoft/nfsftmex.mex* 