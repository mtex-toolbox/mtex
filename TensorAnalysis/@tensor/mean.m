function [TVoigt, TReuss, THill] = mean(T,varargin)
% mean of a list of tensors
%
% Syntax
%  T = mean(T)     % mean along the first non singleton dimension
%  T = mean(T,dim) % mean along dimension dim
%  [TVoigt, TReus, THill] = mean(T,dim) % Voigt, Reus and Hill averages
%
%  [TVoigt, TReus, THill] = mean(T,ori,'weights',weights)
%  [TVoigt, TReus, THill] = mean(T,odf) % mean 
%
% Input
%  T - @tensor
%  dim - dimension with respect to which the mean is taken 
%  ori - @orientation
%  odf - @ODF 
%  weights - double
%

% for the geometric mean take the matrix logarithm before taking the mean
% this is a strange name for this convention
if check_option(varargin,'geometric'), T = logm(T); end

if nargin > 1 && isa(varargin{1},'rotation')

  rotT = rotate(T,varargin{1});
  
  % extract weights
  weights = get_option(varargin,'weights',1./length(varargin{1}));
  
  % take the mean of the rotated tensors times the weight
  TVoigt = sum(weights .* rotT);
      
elseif nargin > 1 && isa(varargin{1},'ODF')
  
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
if check_option(varargin,'geometricMean'), TVoigt = expm(TVoigt); end

% Reuss average -> the inverse of the mean of the inverses
if nargout > 1, TReuss = inv(mean(inv(T),varargin{:})); end
    
% Hill average
if nargout > 2, THill = 0.5*(TVoigt + TReuss); end
  