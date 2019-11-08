% Inverse Haar transform on Healpix
% Y = HealpixInvHaarTransform(X)

function Y = HealpixInvHaarTransform(X)

% nest depth
n = length(X);
m = log2(n / 12) / 2; % = log4(n / 12)

% Haar wavelet basis
A = [ 1  1  1  1;
      1  1 -1 -1;
      1 -1  1 -1;
      1 -1 -1  1 ].' / sqrt(4);
%A = [ 1  1  1  1;
%      1  1 -1 -1;
%      sqrt(2) -sqrt(2)  0  0;
%      0  0  sqrt(2) -sqrt(2) ].' / sqrt(4);

Y = HealpixNestedInvLinearTrans(X, A, m);
