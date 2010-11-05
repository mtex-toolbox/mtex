function T = calcTensor(odf,T,varargin)
% compute the mean tensor for an ODF
%
%% Syntax
% T = calcTensor(ebsd,odf,'voigt')
% T = calcTensor(ebsd,odf,'reuss')
% T = calcTensor(ebsd,odf,'hill')
%
%% Input
%  odf - @ODF
%  T   - @tensor
%
%% Output
%  T    - @tensor
%
%% Options
%  voigt - voigt mean
%  reuss - reuss mean
%  hill  - hill mean
%
%% See also
%

% Hill tensor is just the avarge of voigt and reuss tensor
if check_option(varargin,'hill')
  T = .5*(calcTensor(odf,T,'voigt') + calcTensor(odf,T,'reuss'));
  return
end

% for Reuss tensor invert tensor
if check_option(varargin,'reuss'), T = inv(T);end


if check_option(varargin,'Fourier') 
  % use Fourier method
  
  % calc Fourier coefficient of odf  
  odf_hat = Fourier(odf,'order', rank(T));
  
  % calc Fourier coefficients of the tensor
  [F,T_hat] = Fourier(T);
  
  % mean Tensor is the product of both
  T = EinsteinSum(T_hat,[1:rank(T) -1 -2],odf_hat',[-1 -2]);  

else % use numerical integration
  
  % extract grid and values for numerical integration
  SO3 = extract_SO3grid(odf,varargin{:});
  weight = eval(odf,SO3,varargin{:}); %#ok<EVLC>
  weight = (weight ./ sum(weight(:)));

  % rotate tensor according to the grid
  T = rotate(T,SO3);

  % take the mean of the tensor according to the weight
  T = sum(weight .* T);

end
  
% for Reuss tensor invert back
if check_option(varargin,'reuss'), T = inv(T);end
