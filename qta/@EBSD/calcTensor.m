function T = calcTensor(ebsd,T,varargin)
% compute the mean tensor for an EBSD data set
%
%% Syntax
% T = calcTensor(ebsd,T,'voigt')
% T = calcTensor(ebsd,T,'reuss')
% T = calcTensor(ebsd,T,'hill')
%
%% Input
%  ebsd - @EBSD
%  T    - @tensor
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

% Hill tensor is just the avarge of voigt and reuss tensor
if check_option(varargin,'hill')
  T = .5*(calcTensor(ebsd,T,'voigt') + calcTensor(ebsd,T,'reuss'));
  return
end

% for Reuss tensor invert tensor
if check_option(varargin,'reuss'), T = inv(T);end

% extract orientations and wights
SO3 = get(ebsd,'orientations','checkPhase');
weight = get(ebsd,'weight');

% rotate tensor according to the grid
T = rotate(T,SO3);

% take the mean of the tensor according to the weight
T = sum(weight .* T);

% for Reuss tensor invert back
if check_option(varargin,'reuss'), T = inv(T);end
