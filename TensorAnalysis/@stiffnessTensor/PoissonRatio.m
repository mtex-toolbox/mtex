function varargout = PoissonRatio(C,varargin)
% computes the Poisson ratio of an elasticity tensor
%
% Input
%  C - elastic @stiffnessTensor
%  x - @vector3d
%  y - @vector3d
%
% Output
%  nu - Poisson ratio in directions x and y
%
% Description
% 
% $$\nu = \frac{-S_{ijkl} x_i x_j y_k y_l}{S_{mnop} x_m x_n x_o x_p}$$ 
%

% take formula using complience
[varargout{1:nargout}] = PoissonRatio(inv(C),varargin{:});
