function plotboundaries(ebsd,varargin)
% plot grain boundaries
%
%% Input
%  ebsd   - @EBSD
%
%% See also
% EBSD/segment2d grain/grain

segment2d(ebsd,varargin{:},'plot','silent');
