function out = isFourier(odf)
% check whether odf is given by Fourier coefficients
%
% Syntax
%   odf.isFourier
%

out = all(cellfun(@(x) isa(x,'FourierComponent'),odf.components));

end