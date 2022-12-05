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
% Options
%  l2-normalization - logical
%  
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

% return only one order
if check_option(varargin,'order')
  
  L = get_option(varargin,'order');
  f_hat = reshape(f_hat(deg2dim(L)+1:deg2dim(L+1)),2*L+1,2*L+1);
  
  if check_option(varargin,'l2-normalization')
    f_hat = f_hat ./ sqrt(2*L+1);
  end
  
else
  L = dim2deg(numel(f_hat));

  if check_option(varargin,'l2-normalization')
    for l = 0:L
      f_hat(deg2dim(l)+1:deg2dim(l+1)) = ...
        f_hat(deg2dim(l)+1:deg2dim(l+1)) ./ sqrt(2*l+1);
    end
  end
end


end
