function varargout = calcTensor(ori,T,varargin)
% compute the average tensor for a vector of orientations
%
% Syntax
%   %returns the Voigt--, Reuss-- and Hill-- average @tensor of T
%   [TVoigt, TReuss, THill] = calcTensor(ori,T,'weights',w)
%   
%   % returns the specified @tensor, i.e. 'Hill' in this case
%   THill = calcTensor(ori,T,'Hill')
%
%   % uses geometric mean instead of arithmetric one
%   TGeom = calcTensor(ori,T,'geometric')
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
%  Voigt     - Voigt mean
%  Reuss     - Reuss mean
%  Hill      - Hill mean
%  geometric - geometric mean
%
% See also
% tensor/mean ODF/calcTensor EBSD/calcTensor

[varargout{1:nargout}] = mean(ori .* T,varargin{:});
