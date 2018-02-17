function varargout = velocity(C,varargin)
% computes the elastic wave velocity(km/s) from
% the elastic stiffness Cijkl tensor and density (g/cm3)
%
% Input
%  C   - elasticity @stiffnessTensor Cijkl (UNITS GPa) @tensor
%  x   - list of propagation directions (@vector3d)
%  rho - material density (UNITS g/cm3)
%
% Output
%  vp  - velocity of the p--wave (UNITS km/s)
%  vs1 - velocity of the s1--wave (UNITS km/s)
%  vs2 - velocity of the s2--wave (UNITS km/s)
%  pp  - polarisation of the p--wave (particle movement, vibration direction)
%  ps1 - polarisation of the s1--wave (particle movement, vibration direction)
%  ps2 - polarisation of the s2--wave (particle movement, vibration direction)
%

% take formula using complience
[varargout{1:nargout}] = velocity(inv(C),varargin{:});