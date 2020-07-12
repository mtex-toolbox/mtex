% Authors:
%  Igor Gilitschenski, Gerhard Kurz, Simon J. Julier, Uwe D. Hanebeck,
%  Efficient Bingham Filtering based on Saddlepoint Approximations
%  Proceedings of the 2014 IEEE International Conference on Multisensor Fusion 
%  and Information Integration (MFI 2014), Beijing, China, September 2014.
%  see: https://github.com/libDirectional/libDirectional

if ispc
    % enable AVX if the CPU and OS support it
    % optimflags = 'OPTIMFLAGS=$OPTIMFLAGS /openmp /Ox /arch:AVX';
    % otherwise disable AVX
    optimflags = 'OPTIMFLAGS=$OPTIMFLAGS /openmp /Ox';
    options = {optimflags};
    
elseif ismac
    options = {};
else
    cxxFlags = '-std=c++0x -Wall -Wfatal-errors -march=native -fopenmp';
    ldFlags = '-fopenmp';
    options  = { ['CXXFLAGS=$CXXFLAGS ' cxxFlags], ...
                     ['LDFLAGS=$LDFLAGS ' ldFlags] };
end   

mex(options{:},'numericalSaddlepointWithDerivatives.cpp','binghamNormalizationConstant.cpp')

