function ebsdNew = interp(ebsd, varargin)
% interpolate at arbitrary points (x,y)
%
% Syntax
%
%   ebsdNew = interp(ebsd,xNew,yNew)
%
%   ebsdNew = interp(ebsd,xNew,yNew,'method','invDist')
%
% Input
%  ebsd - @EBSD
%  xNew, yNew - new x,y coordinates
%
% Output
%  ebsdNew - @EBSD with coordinates (xNew,yNew)
%
% Options
%  method - 'invDist', 'nearest'
%
% See also
%  

ebsdNew = interp(ebsd.gridify,varargin{:});

