function sFs = quadrature(varargin)
%
% Syntax
%  sF = S2FunHarmonicSym.quadrature(nodes,values,'weights',w,CS)
%  sF = S2FunHarmonicSym.quadrature(f,CS)
%  sF = S2FunHarmonicSym.quadrature(f, 'bandwidth', bandwidth,CS)
%
% Input
%  values - double
%  nodes - @vector3d
%  f - function handle in vector3d
%
% Options
%  bandwidth - maximal degree of the spherical harmonic (default: 128)
%

% extract symmetry
sym = getClass(varargin,'symmetry',specimenSymmetry);

% 
sF = S2FunHarmonic.quadrature(varargin{:});

% symmetrise the result
sFs = sF.symmetrise(sym);

end
