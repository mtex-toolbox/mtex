function [m, kappa, v] = mean(odf,varargin)
% expected value of an ODF
%
% Syntax
%
%   [m, kappa, v] = mean(odf)
%
% Input
%  odf       - @ODF
%
% Output
%  m      - @orientation
%  lambda - principle moments of inertia
%  V      - principle axes of inertia (@orientation)
%
% See also
% orientation/calcBinghamODF

S3G = extract_SO3grid(odf,varargin);

[m, ~, kappa, v] = mean(S3G,'weights',eval(odf,S3G)); %#ok<EVLC>

m = orientation(m);
