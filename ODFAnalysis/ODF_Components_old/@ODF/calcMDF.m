function mdf = calcMDF(odf1,varargin)
% calculate the uncorrelated misorientation distribution function (MDF) from one or two ODF
%
% Syntax
%   mdf = calcMDF(odf)
%   mdf = calcMDF(odf1,odf2,'bandwidth',32)
%
% Input
%  odf  - @ODF
%  odf1, odf2 - @ODF
%
% Options
% bandwidth - bandwidth for Fourier coefficients (default -- 32)
%
% Output
%  mdf - @ODF
%
% See also
% EBSD/calcODF

% Kernel method
if check_option(varargin,'kernelMethod') 
  
  mdf = calcMDF(odf1.components{1},varargin{1}.components{1});
  
else % Fourier method
  
  % convert to FourierODF
  odf1 = FourierODF(odf1,varargin{:});
  
  % is second argument also an ODF?
  if nargin > 1 && isa(varargin{1},'ODF')
    odf2 = FourierODF(varargin{1},odf1.components{1}.bandwidth);
    antipodal = false;
  else
    odf2 = odf1;
    antipodal = true;    
  end

  % compute MDF
  mdf = calcMDF(odf1.components{1},odf2.components{1});
  mdf.antipodal = antipodal;
  
end
