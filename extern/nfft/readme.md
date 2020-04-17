
1. Download and install the [FFTW](http://www.fftw.org/)

2. Download the source code of the [NFFT](https://www-user.tu-chemnitz.de/~potts/nfft/download.php)

3. in a terminal do
``` bash
./bootstrap.sh
./configure --with-matlab=MATLAB_DIR --enable-nfsoft --enable-nfsft --enable-portable-binary
make
```

4. copy the files 
```
nfft/matlab/nfsoft/nfsoftmex.mex*
nfft/matlab/nfsft/nfsftmex.mex*
```
into directory ```mtex/extern/nfft```
