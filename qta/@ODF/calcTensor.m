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
 


% init Voigt and Reuss averages
TVoigt = set(T,'M',zeros([repmat(3,1,rank(T)) 1 1]));
TVoigt = set(TVoigt,'CS',symmetry);

% for Reuss tensor invert tensor
if get(T,'rank') ~= 3 && nargout > 1
  Tinv = inv(T);
  TReuss = set(Tinv,'M',zeros([repmat(3,1,rank(T)) 1 1]));  
  TReuss = set(TReuss,'CS',symmetry);
end

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
  
  % force the tensor to have the same reference frame as the ODF
  T = set(T,'CS',odf.CS);
  
  for l = 0:rank(T)
  
    % calc Fourier coefficient of odf
    odf_hat = Fourier(odf,'order', l)./(2*l+1);
  
    % calc Fourier coefficients of the tensor
    T_hat = Fourier(T,'order',l);
  
    % mean Tensor is the product of both
    TVoigt = EinsteinSum(T_hat,[1:rank(T) -1 -2],odf_hat,[-1 -2]) + TVoigt;
    
    % same for Tinv
    if exist('Tinv','var'), 
      T_hat = Fourier(Tinv,'order',l);
      TReuss = EinsteinSum(T_hat,[1:rank(T) -1 -2],odf_hat,[-1 -2]) + TReuss;
      if isreal(double(T)), TReuss = real(TReuss);end
    end
    
    % ensure tensors to be real valued
    if isreal(double(T))
      TVoigt = real(TVoigt);
    end
  end
    
%% use numerical integration  
elseif strcmpi(char(method),'quadrature') 
  
  % evaluate ODF at an equispaced grid
  res = get_option(varargin,'resolution',5*degree);
  S3G = SO3Grid(res,odf.CS,odf.SS);
  %S3G = SO3Grid(res);
  %S3G = set(S3G,'CS',odf.CS);
  weight = eval(odf,S3G,varargin{:}); %#ok<EVLC>
  weight = (weight ./ sum(weight(:)));

  % rotate tensor according to the grid
  T = rotate(T,S3G);

  % take the mean of the tensor according to the weight
  TVoigt = sum(weight .* T);
  
  % same for Reuss
  if exist('Tinv','var')
    Tinv = rotate(Tinv,S3G);
    TReuss = sum(weight .* Tinv);
  end

else 
  
  error('Unknown method!');
  
end

if exist('Tinv','var'), 
  % for Reuss tensor invert back
  TReuss = inv(TReuss);
  
  % Hill tensor is just the avarge of voigt and reuss tensor
  THill = 0.5*(TVoigt + TReuss);
end

% if type is specified only return this type
if check_option(varargin,'Reuss'), TVoigt = TReuss;end
if check_option(varargin,'Hill'), TVoigt = THill;end
