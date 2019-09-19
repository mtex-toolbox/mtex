function [TVoigt, TReuss, THill] = mean(T,varargin)
% mean of a list of tensors
%
% Syntax
%  T = mean(T)     % mean along the first non singleton dimension
%  T = mean(T,dim) % mean along dimension dim
%  TReuss = mean(T,'Reuss') % Reuss average
%  TGeometric = mean(T,'geometric') % geometric mean
%  [TVoigt, TReus, THill] = mean(T) % Voigt, Reuss and Hill averages
%
%  [TVoigt, TReus, THill] = mean(T,ori,'weights',weights) % mean with respect to orientations
%  [TVoigt, TReus, THill] = mean(T,odf) % mean with respect to ODF
%
% Input
%  T - @tensor
%  dim - dimension with respect to which the mean is taken 
%  ori - @orientation
%  odf - @ODF 
%  weights - double
%

% for the geometric mean take the matrix logarithm before taking the mean
if check_option(varargin,'geometric'), T = logm(T); end

% for the Reuss mean take the inverse
if check_option(varargin,'Reuss'), T = inv(T); end

if check_option(varargin,'iso') && T.rank==4
  
  % explicit formula for averaging over orientation domain
  alpha = EinsteinSum(T,[-1 -1 -2 -2]);
  beta = EinsteinSum(T,[-1 -2 -1 -2]);

  gamma = (2*alpha - beta) / 15;
  delta = (3*beta - alpha) / 30;
  
  TVoigt = 2 * delta * T.eye + gamma * dyad(tensor.eye,tensor.eye);

elseif nargin > 1 && isa(varargin{1},'rotation')

  rotT = rotate(T,varargin{1});
  
  % extract weights
  weights = get_option(varargin,'weights',1./length(varargin{1}));
  
  % take the mean of the rotated tensors times the weight
  TVoigt = sum(weights .* rotT);
      
elseif nargin > 1 && isa(varargin{1},'ODF')
  
  % this needs to be replaced
  TVoigt = calcTensor(varargin{1},T,varargin{2:end});
  
else % the plain mean

  if nargin > 1
    dim = varargin{1};
  else
    dim = 1 + (size(T,1) == 1);
  end
      
  dim = dim + T.rank;
  TVoigt = T;
  TVoigt.M = mean(T.M,dim);
    
end

% for the geometric mean take matrix exponential to go back
if check_option(varargin,'geometric'), TVoigt = expm(TVoigt); end

% for Reuss take the inverse of the tensor to go back
if check_option(varargin,'Reuss'), TVoigt = inv(TVoigt); end

% Reuss average -> the inverse of the mean of the inverses
if nargout > 1, TReuss = inv(mean(inv(T),varargin{:})); end
    
% Hill average
if nargout > 2, THill = 0.5*(TVoigt + TReuss); end
  