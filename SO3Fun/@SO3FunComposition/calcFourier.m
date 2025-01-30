function f_hat = calcFourier(SO3F,varargin)
% compute Fourier coefficients of an ODF
%
% Syntax  
%   f_hat = calcFourier(odf,'bandwidth',L)
%
% Input
%  odf  - @SO3Fun
%  L    - order up to which Fourier coefficients are calculated
%
% Output
%  f_hat - vector of Fourier coefficients order as [fh000 fh1-1-1 ... fh111 fh2-2-2 fh222 ...]
%
% See also
% SO3Fun/plotSpektra SO3Fun/Fourier wignerD FourierODF SO3Fun/textureindex SO3Fun/entropy SO3Fun/eval 
%

L = get_option(varargin,'bandwidth',min(SO3F.bandwidth,getMTEXpref('maxSO3Bandwidth')));


f_hat = zeros(deg2dim(L+1),1);

for i = 1:numel(SO3F.components)
  
  hat = calcFourier(SO3F.components{i},varargin{:},'bandwidth',L);
  f_hat(1:numel(hat)) = f_hat(1:numel(hat)) + hat;
    
end

end