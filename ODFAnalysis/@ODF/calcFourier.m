function f_hat = calcFourier(odf,varargin)
% compute Fourier coefficients of an ODF
%
% Syntax  
%   f_hat = calcFourier(odf,L)
%
% Input
%  odf  - @ODF
%  L    - order up to which Fourier coefficients are calculated
%
% Output
%  f_hat - vector of Fourier coefficients order as [fh000 fh1-1-1 ... fh111 fh2-2-2 fh222 ...]
%
% See also
% ODF/plotFourier ODF/Fourier wignerD FourierODF ODF/textureindex ODF/entropy ODF/eval 
%

if nargin > 1 && isnumeric(varargin{1})
  L = varargin{1};
else
  L = get_option(varargin,'bandwidth',min(odf.bandwidth,getMTEXpref('maxBandwidth')));
end

f_hat = zeros(deg2dim(L+1),1);

for i = 1:numel(odf.components)
  
  hat = calcFourier(odf.components{i},L,varargin{:});
  
  f_hat(1:numel(hat)) = f_hat(1:numel(hat)) + odf.weights(i) * hat;
    
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
