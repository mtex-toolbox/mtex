function [ebsd,filter] = smooth(ebsd,varargin)
% smooth spatial EBSD 
%
% Syntax
%
%   ebsd = smooth(ebsd)
%
%   F = halfQuadraticFilter
%   F.alpha = 2;
%   ebsd = smooth(ebsd, F, 'fill', grains)
%
% Input
%  ebsd   - @EBSD
%  F      - @EBSDFilters
%  grains - @grain2d if provided pixels at the boundary between grains are not filled
%
% Options
%  fill        - fill missing values (this is different then not indexed values!)
%  extrapolate - extrapolate up the the outer boundaries
%

error('not yet implemented')

