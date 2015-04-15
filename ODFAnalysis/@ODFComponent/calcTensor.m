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
    
  % rotate tensor according to the grid and
  % take the mean of the tensor according to the weight
  TVoigt = sum(f .* rotate(T,S3G));
 
end

if check_option(varargin,{'Reuss','Hill'})

  % for Reuss tensor invert tensor  
  TReuss = inv(sum(f .* rotate(inv(T),S3G)));
    
end
