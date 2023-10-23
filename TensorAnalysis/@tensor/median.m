function [TVoigt, TReuss, THill] = median(T,varargin)
% median of a list of tensors
%
% Syntax
%   T = median(T)     % median along the first non singleton dimension
%   T = median(T,dim) % median along dimension dim
%   TReuss = median(T,'Reuss') % Reuss average
%   THill = median(T,'Hill') % Hill average
%   TGeometric = median(T,'geometric') % geometric median
%   [TVoigt, TReus, THill] = median(T) % Voigt, Reuss and Hill averages
%
%   [TVoigt, TReus, THill] = median(ori*T,'weights',weights) % median with respect to orientations
%   [TVoigt, TReus, THill] = median(T,odf) % median with respect to ODF
%   [TVoigt, TReus, THill] = median(ori,'weights',weights) % weighted median
%
% Input
%  T - @tensor
%  dim - dimension with respect to which the median is taken 
%  ori - @orientation
%  odf - @SO3Fun
%  weights - double
%

% for the geometric median take the matrix logarithm before taking the median
if check_option(varargin,'geometric'), T = logm(T); end

% for the Reuss median take the inverse
if check_option(varargin,'Reuss'), T = inv(T); end

if check_option(varargin,'iso') && T.rank==4
  
  % explicit formula for averaging over orientation domain
  alpha = EinsteinSum(T,[-1 -1 -2 -2]);
  beta = EinsteinSum(T,[-1 -2 -1 -2]);

  gamma = (2*alpha - beta) / 15;
  delta = (3*beta - alpha) / 30;
  
  TVoigt = 2 * delta * T.eye + gamma * dyad(tensor.eye,tensor.eye);
     
elseif nargin > 1 && isa(varargin{1},'SO3Fun') % use an ODF as input

  SO3F = SO3FunHarmonic(varargin{1},'bandwidth',T.rank);
  TFun = Fourier(T);

  TVoigt = 0*T;
  TVoigt.CS = SO3F.SS; 

  TVoigt.M = cor(SO3F,TFun);
  
elseif check_option(varargin,'weights')  % weighted median
  
  % extract weights
  weights = reshape(get_option(varargin,'weights'),size(T));
  
  % take the median of the rotated tensors times the weight
  TVoigt = sum(weights .* T);

  if isfield(T.opt,'density') && numel(weights) == numel(T.opt.density)
    TVoigt.opt.density = sum(T.opt.density .* weights);
  end

else % the plain median

  if nargin > 1 && isnumeric(varargin{1})
    dim = varargin{1};
  else
    dim = 1 + (size(T,1) == 1);
  end
  
  dim = dim + T.rank;
  TVoigt = T;
  TVoigt.M = median(T.M,dim);
    
end

% for the geometric median take matrix exponential to go back
if check_option(varargin,'geometric'), TVoigt = expm(TVoigt); end

% for Reuss take the inverse of the tensor to go back
if check_option(varargin,'Reuss'), TVoigt = inv(TVoigt); end

% Reuss average -> the inverse of the median of the inverses
if nargout > 1 || check_option(varargin,'Hill')
  opt = delete_option(varargin,'Hill');
  TReuss = median(T,opt{:},'Reuss');
  THill = 0.5*(TVoigt + TReuss);    
end
    
% Hill average
if check_option(varargin,'Hill'), TVoigt = THill; end
