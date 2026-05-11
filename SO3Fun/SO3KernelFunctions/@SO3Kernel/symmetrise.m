function psi = symmetrise(psi, varargin)
% symmetries a kernel function with respect to given symmetries
%
% Syntax
%   psi = symmetrise(psi,'CS',cs,'SS',ss)
%   psi = symmetrise(psi,'antipodal')
%
% Input
%  psi - @SO3Kernel
%  cs  - @crystalSymmetry, @specimenSymmetry
%
% Output
%  psi - @SO3Kernel
%

psi = SO3FunHarmonic(psi);
psi = symmetrise(psi,varargin{:});

end