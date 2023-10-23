function [TVoigt, TReuss, THill] = mode(T,varargin)
% mode of a list of tensors
%
% Syntax
%   T = mode(T)     % mode along the first non singleton dimension
%   T = mode(T,dim) % mode along dimension dim
%   TReuss = mode(T,'Reuss') % Reuss average
%   THill = mode(T,'Hill') % Hill average
%   TGeometric = mode(T,'geometric') % geometric mode
%   [TVoigt, TReus, THill] = mode(T) % Voigt, Reuss and Hill averages
%
%   [TVoigt, TReus, THill] = mode(ori*T,'weights',weights) % mode with respect to orientations
%   [TVoigt, TReus, THill] = mode(T,odf) % mode with respect to ODF
%   [TVoigt, TReus, THill] = mode(ori,'weights',weights) % weighted mode
%
% Input
%  T - @tensor
%  dim - dimension with respect to which the mode is taken 
%  ori - @orientation
%  odf - @SO3Fun
%  weights - double
%

% for the geometric mode take the matrix logarithm before taking the mode
if check_option(varargin,'geometric'), T = logm(T); end

% for the Reuss mode take the inverse
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
  
elseif check_option(varargin,'weights')  % weighted mode
  
  % extract weights
  weights = reshape(get_option(varargin,'weights'),size(T));
  
  % take the mode of the rotated tensors times the weight
  TVoigt = sum(weights .* T);

  if isfield(T.opt,'density') && numel(weights) == numel(T.opt.density)
    TVoigt.opt.density = sum(T.opt.density .* weights);
  end

else % the plain mode

  if nargin > 1 && isnumeric(varargin{1})
    dim = varargin{1};
  else
    dim = 1 + (size(T,1) == 1);
  end
  
  dim = dim + T.rank;
  TVoigt = T;
  TVoigt.M = mode(T.M,dim);
    
end

% for the geometric mode take matrix exponential to go back
if check_option(varargin,'geometric'), TVoigt = expm(TVoigt); end

% for Reuss take the inverse of the tensor to go back
if check_option(varargin,'Reuss'), TVoigt = inv(TVoigt); end

% Reuss average -> the inverse of the mode of the inverses
if nargout > 1 || check_option(varargin,'Hill')
  opt = delete_option(varargin,'Hill');
  TReuss = mode(T,opt{:},'Reuss');
  THill = 0.5*(TVoigt + TReuss);    
end
    
% Hill average
if check_option(varargin,'Hill'), TVoigt = THill; end
