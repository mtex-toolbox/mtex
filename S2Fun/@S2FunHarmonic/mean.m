function value = mean(sF, varargin)
% calculates the mean value of a spherical harmonic
% Syntax
%  value = mean(sF)
%

s = size(sF);
if nargin == 1
  sF = sF.subSet(':');
  value = real(sF.fhat(1, :))/sqrt(4*pi);
  value = reshape(value, s);
else
s = size(sF);
  value = sum(sF, varargin{1})./s(varargin{1});
end

end
