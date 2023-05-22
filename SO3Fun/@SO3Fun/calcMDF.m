function mdf = calcMDF(SO3F1,varargin)
% calculate the uncorrelated misorientation distribution function (MDF) from one or two ODF
%
% Syntax
%   mdf = calcMDF(SO3F1)
%   mdf = calcMDF(SO3F1,SO3F2,'bandwidth',32)
%
% Input
%  SO3F1, SO3F2 - @SO3Fun
%
% Output
%  mdf - @SO3Fun
%
% Options
% bandwidth - bandwidth for Fourier coefficients (default -- 32)
%
% See also
% EBSD/calcODF

% is second argument also an ODF?
if nargin > 1 && isa(varargin{1},'SO3Fun')
  SO3F2 = varargin{1};
  antipodal = false;
else
  SO3F2 = SO3F1;
  antipodal = true;
end

% the misorientation density function is nothing else then the convolution
mdf = conv(inv(conj(SO3F1)),SO3F2,varargin{:});
mdf.antipodal = antipodal;
  
end
