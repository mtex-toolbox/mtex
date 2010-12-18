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

% determine method for average calculation

method = extract_option(varargin,{'fourier','quadrature'});
if isempty_cell(method)
  if all(~strcmp(get(odf,'options'),'Bingham'))
    method = 'fourier';
  else
    method = 'quadrature';
  end
end


%% use Fourier method
if strcmpi(char(method),'fourier')

 
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
elseif strcmpi(char(method),'quadrature') 
  
  % extract grid and values for numerical integration
  %SO3 = extract_SO3grid(odf,varargin{:});
  S3G = SO3Grid(5*degree);
  weight = eval(odf,S3G,varargin{:}); %#ok<EVLC>
  weight = (weight ./ sum(weight(:)));

  % rotate tensor according to the grid
  T = rotate(T,S3G);

  % take the mean of the tensor according to the weight
  TVoigt = sum(weight .* T);
  
  % same for Reuss
  Tinv = rotate(Tinv,S3G);
  TReuss = sum(weight .* Tinv);

else 
  
  error('Unknown method!');
  
end

% for Reuss tensor invert back
TReuss = inv(TReuss);

% Hill tensor is just the avarge of voigt and reuss tensor
THill = 0.5*(TVoigt + TReuss);

% if type is specified only return this type
if check_option(varargin,'Reuss'), TVoigt = TReuss;end
if check_option(varargin,'Hill'), TVoigt = THill;end
