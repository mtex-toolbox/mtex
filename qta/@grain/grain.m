function [gr id] = grain(id,ply)
% constructor
%
% *grain* is the low level constructor for an *grain* object representing
% grains. Grains are derived from the segmentation of @EBSD data.
%
%% Syntax
%  [grain ebsd] = grain(ebsd, ... )
%
%% Input
%  ebsd    - @EBSD
%
%% See also
% EBSD/segment2d


superiorto('EBSD');
gr = class(id,'grain',ply);

