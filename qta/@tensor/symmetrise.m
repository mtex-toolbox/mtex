function T = symmetrise(T)
% symmetrise a tensor according to its crystal symmetry

T.M(isnan(T.M)) = 1i;
T = rotate(T,T.CS);
%T.M = real(T.M) + 1i*abs(imag(T.M));
T = sum(T);
count = numel(T.CS)-abs(imag(T.M));
T.M(count>0.1) = real(T.M(count>0.1)) ./ count(count>0.1);
T.M(count<0.1) = 0;
T.M = nanmean(T.M,T.rank+1);

