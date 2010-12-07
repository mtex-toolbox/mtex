function [TVoigt, TReuss, THill] = calcTensor(odf,T,varargin)
% compute the average tensor for an ODF
%
%% Syntax
% [TVoigt, TReuss, THill] = calcTensor(odf,T)
% THill = calcTensor(odf,T,'Hill')
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
 
% for Reuss tensor invert tensor
Tinv = inv(T);

% init Voigt and Reuss averages
TVoigt = tensor(zeros([repmat(3,1,rank(T)) 1 1]));
TReuss = tensor(zeros([repmat(3,1,rank(T)) 1 1]));

%% use Fourier method
if check_option(varargin,'Fourier') 

 
  % compute Fourier coefficients of the odf
  odf = calcFourier(odf,rank(T));
  
  for l = 0:rank(T)
  
    % calc Fourier coefficient of odf
    odf_hat = Fourier(odf,'order', l)./(2*l+1);
  
    % calc Fourier coefficients of the tensor
    T_hat = Fourier(T,'order',l);
  
    % mean Tensor is the product of both
    TVoigt = TVoigt + EinsteinSum(T_hat,[1:rank(T) -1 -2],odf_hat,[-1 -2]);
    
    % same for Tinv
    T_hat = Fourier(Tinv,'order',l);
    TReuss = TReuss + EinsteinSum(T_hat,[1:rank(T) -1 -2],odf_hat,[-1 -2]);
    
  end
    
%% use numerical integration  
else 
  
  % extract grid and values for numerical integration
  SO3 = extract_SO3grid(odf,varargin{:});
  weight = eval(odf,SO3,varargin{:}); %#ok<EVLC>
  weight = (weight ./ sum(weight(:)));

  % rotate tensor according to the grid
  T = rotate(T,SO3);

  % take the mean of the tensor according to the weight
  TVoigt = sum(weight .* T);
  
  % same for Reuss
  Tinv = rotate(Tinv,SO3);
  TReuss = sum(weight .* Tinv);

end

% for Reuss tensor invert back
TReuss = inv(TReuss);

% Hill tensor is just the avarge of voigt and reuss tensor
THill = 0.5*(TVoigt + TReuss);

% if type is specified only return this type
if check_option(varargin,'Reuss'), TVoigt = TReuss;end
if check_option(varargin,'Hill'), TVoigt = THill;end
