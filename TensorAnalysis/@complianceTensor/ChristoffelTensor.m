function varargout = ChristoffelTensor(S,varargin)
% Christoffel tensor of an elasticity tensor for a given direction
%
% Formula: E_jk = C_ijkl n_j n_l
%
% Input
%  S - elatic compliance @tensor
%  x - list of @vector3d
%
% Output
%  E - Christoffel @tensor
%
% See also
% tensor/directionalMagnitude tensor/rotate

% take formula using stiffness
[varargout{1:nargout}] = ChristoffelTensor(inv(S),varargin{:});
