function [TVoigt, TReuss] = calcTensor(component,T,varargin)
% compute the average tensor for an ODF

% init Voigt and Reuss averages
TVoigt = T;
TVoigt.M = zeros([repmat(3,1,T.rank) 1 1]);
TVoigt.CS = symmetry;

% for Reuss tensor invert tensor
Tinv = inv(T);
TReuss = Tinv;
TReuss.M = zeros([repmat(3,1,T.rank) 1 1]);
TReuss.CS = symmetry;
  
for l = 0:T.rank
  
  % calc Fourier coefficient of odf
  odf_hat = Fourier(component,'order', l)./(2*l+1);
  
  % Voigt mean
  if check_option(varargin,{'Voigt','Hill'})
    
    % calc Fourier coefficients of the tensor
    T_hat = Fourier(T,'order',l);
  
    % mean Tensor is the product of both
    TVoigt = EinsteinSum(T_hat,[1:T.rank -1 -2],odf_hat,[-1 -2]) + TVoigt;
        
  end
  
  % Reuss mean
  if check_option(varargin,{'Reuss','Hill'})
    
    % calc Fourier coefficients of the inverse tensor
    T_hat = Fourier(Tinv,'order',l);
    
    % mean Tensor is the product of both
    TReuss = EinsteinSum(T_hat,[1:T.rank -1 -2],odf_hat,[-1 -2]) + TReuss;
        
  end
end

% ensure tensors to be real valued
if isreal(double(T)),
  TVoigt = real(TVoigt); 
  TReuss = real(TReuss); 
end

% invert Reuss back
TReuss = inv(TReuss);
