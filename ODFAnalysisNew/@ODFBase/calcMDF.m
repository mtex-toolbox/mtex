function mdf = calcMDF(odf1,varargin)
% calculate the uncorrelated misorientation distribution function (MDF) from one or two ODF
%
% Syntax
%   mdf = calcMDF(odf)
%   mdf = calcMDF(odf1,odf2,'bandwidth',32)
%
% Input
%  odf, odf1, odf2 - @ODF
%
% Options
% bandwidth - bandwidth for Fourier coefficients (default -- 32)
%
% Output
%  mdf - @ODF
%
% See also
% EBSD/calcODF

% is second argument also an ODF?
if nargin > 1 && isa(varargin{1},'ODFBase')
  odf2 = FourierODF(varargin{1},odf1.components{1}.bandwidth);
  antipodal = false;
else
  odf2 = odf1;
  antipodal = true;
end

% the misorietation density function is nothing else then the convolution s
mdf = conv(odf1,odf2,varargin{:});
mdf.antipodal = antipodal;
  
end
