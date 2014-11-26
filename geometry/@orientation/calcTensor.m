function [TVoigt, TReuss, THill] = calcTensor(ori,T,varargin)
% compute the average tensor for a vector of orientations
%
% Syntax
%   %returns the Voigt--, Reuss-- and Hill-- average @tensor of T
%   [TVoigt, TReuss, THill] = calcTensor(ori,T,'weights',w) - 
%   
%   % returns the specified @tensor, i.e. 'Hill' in this case
%   THill = calcTensor(ori,T,'Hill')
%
%   % uses geometric mean instead of arithmetric one
%   TVoigt = calcTensor(ori,T,'geometricMean')
%
% Input
%  ori     - @orientation
%  T       - @tensor
%  w       - weights for each orientation
%
% Output
%  TVoigt, TReuss, THill - @tensor
%
% Options
%  Voigt - voigt mean
%  Reuss - reuss mean
%  Hill  - hill mean
%
% See also
%

weights = get_option(varargin,'weights',ones(length(ori),1)./length(ori));
  
rotT = rotate(T,ori);
rotInvT = rotate(inv(T),ori);
  
% for the geometric mean take the matrix logarithm before summing up
if check_option(varargin,'geometricMean')    
  rotT = logm(rotT);
  rotInvT = logm(rotInvT);    
end
        
% take the mean of the rotated tensors times the weight
TVoigt = sum(weights .* rotT);

% take the mean of the rotated tensors times the weight
TReuss = inv(sum(weights .* rotInvT));
  
% for the geometric mean take matrix exponential to go back
if check_option(varargin,'geometricMean')
  TVoigt = expm(TVoigt);
  TReuss = expm(TReuss);
end

% Hill is simply the mean of Voigt and Reuss averages
THill = 0.5*(TReuss + TVoigt);

% if type is specified only return this type
if check_option(varargin,'Reuss'), TVoigt = TReuss;end
if check_option(varargin,'Hill'), TVoigt = THill;end
