# Compiling the NFFT #

The [NFFT](https://www-user.tu-chemnitz.de/~potts/nfft/index.php) is a C-library that provides fast Fourier transforms on the 
sphere and the rotation group is at the very core of MTEX. MTEX comes with precompiled binaries for Windows, Mac OSX and Linux. 
In case these binaries do not run on your system, or if you want to gain the last bit of optimization, it might be necessary
to compile the binaries yourself.

## Download and Install the FFTW ##
The [FFTW](http://www.fftw.org/) is a standard Fast Fourier Transform package that is available precompiled for all plattforms. 

## Download the NFFT ##
Download the source code of the NFFT from https://www-user.tu-chemnitz.de/~potts/nfft/download.php. 
This download site also hosts binaries. The Matlab interfaces are exactly the binaries that are shiped with MTEX. 

## Compile the NFFT ##
The compilation of the NFFT is described in detail at https://www-user.tu-chemnitz.de/~potts/nfft/installation.php
For MTEX we need the nfsoft, the nfsft and the Matlab bindings. You need to do something like

``` bash
./bootstrap.sh 
./configure --with-matlab=MATLAB_DIR --enable-nfsoft --enable-nfsft --enable-openmp --enable-portable-binary 
make
```
For Mac OSX related issues have a look at https://mtex-toolbox.github.io/installation

## Copy the NFFT Binaries into MTEX ##
Copy the following files into this directory `mtex/extern/nfft_openMP`
```
nfft/matlab/nfsoft/nfsoftmex.mex* 
nfft/matlab/nfsft/nfsftmex.mex* 
```
