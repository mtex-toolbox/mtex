function [M,b,spin] = calcTaylor(eps,sS,varargin)
% compute Taylor factor and strain dependent orientation gradient
%
% Syntax
%   [M,b,W] = calcTaylor(eps,sS)
%
% Input
%  L  - @velocityGradientTensor
%  sS - @slipSystem
%
% Output
%  M - taylor factor
%  b - coefficients for the acive slip systems
%  W - @spinTensor
%
% Example
%
%   % consider uniaxial tension in (100) direction about 30 percent
%   F = deformationGradientTensor.uniaxial(vector3d.X,1.3)
%
%   % the corresponding rate of deformation tensor becomes
%   L = logm(F)
%
%   % define a crystal orientation
%   cs = crystalSymmetry('cubic')
%   ori = orientation.byEuler(0,30*degree,15*degree,cs)
%
%   % define a slip system
%   sS = slipSystem.fcc(cs)
%
%   % compute the Taylor factor
%   [M,b,spin] = calcTaylor(inv(ori)*L,sS.symmetrise)
%
%   % update orientation
%   oriNew = ori .* orientation(-W)


% the antisymmetry part of the strainRateTensor is directly the spin increment
% spin = eps.antiSym;

eps = strainTensor(eps);
[M,b,spin] = calcTaylor(eps,sS,varargin{:});
