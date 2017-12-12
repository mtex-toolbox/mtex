function sFs = symmetrise(sF, varargin)
% symmetrises a function by s
% Syntax
%  sF = sF.symmetrise(s)
%  sF = sF.symmetrise(s, 'm', M)
%
% Input
%  sF - spherical function
%  s  - symmetrie
%
% Options
%  M - minimal degree of the spherical harmonic
%

s = varargin{1};
M = get_option(varargin, 'm', min(sF.M, 500));

sFtmp = sphFunHarmonic(0);
for j = 1:length(s)
	sFtmp = sFtmp+sF.rotate(s(j));
end
sFtmp = sFtmp./length(s);
sFs = sphFunHarmonicS(sFtmp.fhat, s);

end
