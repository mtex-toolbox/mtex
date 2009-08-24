function plotboundaries(ebsd,varargin)
% plot grain boundaries
%
%% Input
%  ebsd   - @EBSD
%
%% Output
%  grains  - @grain
%  ebsd    - connected @EBSD data
%
%% See also
% EBSD/semgment2d grain/grain

segment2d(ebsd,varargin{:},'plot','silent');
