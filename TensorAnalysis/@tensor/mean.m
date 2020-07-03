function [TVoigt, TReuss, THill] = mean(T,varargin)
% mean of a list of tensors
%
% Syntax
%   T = mean(T)     % mean along the first non singleton dimension
%   T = mean(T,dim) % mean along dimension dim
%   TReuss = mean(T,'Reuss') % Reuss average
%   THill = mean(T,'Hill') % Hill average
%   TGeometric = mean(T,'geometric') % geometric mean
%   [TVoigt, TReus, THill] = mean(T) % Voigt, Reuss and Hill averages
%
%   [TVoigt, TReus, THill] = mean(ori*T,'weights',weights) % mean with respect to orientations
%   [TVoigt, TReus, THill] = mean(T,odf) % mean with respect to ODF
%   [TVoigt, TReus, THill] = mean(ori,'weights',weights) % weighted mean
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
     
elseif nargin > 1 && isa(varargin{1},'ODF') % use an ODF as input

  TVoigt = 0*T;
  
  odf = varargin{1};
  fhat = calcFourier(odf,min(T.rank,odf.bandwidth));
  
  for l = 0:min(T.rank,odf.bandwidth)
  
    % calc Fourier coefficient of odf
    ind = deg2dim(l)+(1:(2*l+1)^2);
    fhat_l = reshape(fhat(ind),2*l+1,2*l+1)./(2*l+1);
      
    % calc Fourier coefficients of the tensor
    T_hat = Fourier(T,'order',l);
  
    % mean Tensor is the product of both
    TVoigt = TVoigt + real(EinsteinSum(T_hat,[1:T.rank -1 -2],fhat_l,[-2 -1]));
        
  end
  
elseif check_option(varargin,'weights')  % weighted mean
  
  % extract weights
  weights = reshape(get_option(varargin,'weights'),size(T));
  
  % take the mean of the rotated tensors times the weight
  TVoigt = sum(weights .* T);
  
else % the plain mean

  if nargin > 1 && isnumeric(varargin{1})
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
if nargout > 1 || check_option(varargin,'Hill')
  opt = delete_option(varargin,'Hill');
  TReuss = mean(T,opt{:},'Reuss');
  THill = 0.5*(TVoigt + TReuss);    
end
    
% Hill average
if check_option(varargin,'Hill'), TVoigt = THill; end
