function [TVoigt, TReuss] = calcTensor(component,T,varargin)
% compute the average tensor for an ODF

% evaluate ODF at an equispaced grid
res = get_option(varargin,'resolution',5*degree);
S3G = equispacedSO3Grid(component.CS,component.SS,'resolution',res/4);
f = eval(component,S3G,varargin{:}); %#ok<EVLC>
f = (f ./ sum(f(:)));

% some default output
TVoigt = T; TReuss = T;

% Voigt mean
if check_option(varargin,{'Voigt','Hill'})

  % rotate tensor according to the grid
  T = rotate(T,S3G);

  % take the mean of the tensor according to the weight
  TVoigt = sum(f .* T);
 
end

if check_option(varargin,{'Reuss','Hill'})

  % for Reuss tensor invert tensor
  Tinv = inv(T);
  Tinv = rotate(Tinv,S3G);
  TReuss = inv(sum(f .* Tinv));
    
end
