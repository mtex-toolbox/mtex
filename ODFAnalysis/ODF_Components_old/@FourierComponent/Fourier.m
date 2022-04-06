function f_hat = Fourier(component,varargin)
% get Fourier coefficients of and ODF
%
% Returns the Fourier coefficients of an ODF. If no option is specified all
% allready precomputed Fourier coefficients are returned. If the option
% 'order' is specified only Fourier coefficients of this specific order are
% returned. If the option 'bandwidth' is specified all Fourier coefficients
% up to this bandwidth are returned.
%
% Syntax  
%   f_hat = Fourier(odf,'order',L)
%   f_hat = Fourier(odf,'bandwidth',B)
%
% Input
%  odf  - @ODF
%  L    - order of Fourier coefficients to be returned
%  B    - maximum order of Fourier coefficients to be returned
%
% Options
%  l2--normalization - used L^2 normalization
%
% Output
%  f_hat - Fourier coefficient -- complex (2L+1)x(2L+1) matrix
%  
% See also
% ODF/plotFourier wignerD ODF/calcFourier FourierODF ODF/textureindex ODF/entropy ODF/eval
%

% return only one order
if check_option(varargin,'order')
  
  L = get_option(varargin,'order');
  f_hat = reshape(component.f_hat(deg2dim(L)+1:deg2dim(L+1)),2*L+1,2*L+1);
  
  if check_option(varargin,'l2-normalization')
    f_hat = f_hat ./ sqrt(2*L+1);
  end
  
  return
end

f_hat = component.f_hat;
L = dim2deg(numel(f_hat));

if check_option(varargin,'l2-normalization')
  for l = 0:L
    f_hat(deg2dim(l)+1:deg2dim(l+1)) = ...
      f_hat(deg2dim(l)+1:deg2dim(l+1)) ./ sqrt(2*l+1);    
  end
end
  
if check_option(varargin,'weighted')
  w = get_option(varargin,'weighted');
  for l = 0:L
    f_hat(deg2dim(l)+1:deg2dim(l+1)) = ...
      f_hat(deg2dim(l)+1:deg2dim(l+1)) .* w(l+1);
  end
end
