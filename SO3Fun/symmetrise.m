function SO3F = symmetrise(SO3F,varargin)
% Symmetrise the harmonic coefficients of an SO3FunHarmonic w.r.t. its 
% symmetries or a center orientation.
% 
% Therefore we compute the harmonic coefficients of the SO3FunHarmonic 
% by using symmetry properties.
%
% Syntax
%   SO3Fs = symmetrise(SO3F)
%   SO3Fs = symmetrise(SO3F,'CS',cs,'SS',ss)
%
% Input
%  SO3F - @SO3Fun
%  cs,ss - @crystalSymmetry, @specimenSymmetry
%  ori - @orientation (center)
%
%
% Output
%  SO3Fs - @SO3FunHarmonic
%

% symmetrisation is only implemented for SO3FunHarmonic
SO3F = SO3F.symmetrise(SO3FunHarmonic(SO3F),varargin{:});