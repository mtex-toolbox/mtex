function [gnd,rho] = calcGND(ebsd,dS,varargin)
% compute the geometrically necessary dislocation
%
% Formulae are taken from the paper:
%
% Pantleon, Resolving the geometrically necessary dislocation content by
% conventional electron backscattering diffraction, Scripta Materialia,
% 2008
%
% Syntax
%   gnd = calcGND(ebsd,dS)
%
% Input
%  ebsd - @EBSDsquare
%  dS   - @dislocationSystem 
%
% Output
%  gnd  - dislocation energy
%  rho  - dislocation density per dislocation system
%
% See also
% GND_demo

% compute curvature tensors
kappa = ebsd.curvature;

% rotate dislocation systems according into specimen coordinates
dSRot = ebsd.orientations * dS;

% fit dislocation to curvature tensor
[rho,factor] = fitDislocationSystems(kappa,dSRot);

% compute dislocation energy
gnd = factor*sum(abs(rho .* dSRot.u),2);
