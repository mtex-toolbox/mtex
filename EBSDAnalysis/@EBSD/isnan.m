function out = isnan(ebsd)
% check for nan rotation is ebsd
%
% Syntax
%   out = isnan(ebsd)
%
% Input
%  ebsd - @EBSD
%
% Output
%  out - logical

out = isnan(ebsd.rotations);

