function [modes, values] = calcModes(SO3F,varargin)
% heuristic to find modal orientations
%
% Syntax
%   [modes, values] = calcModes(odf,'numLocal',n)
%
% Input
%  odf - @SO3Fun 
%  n   - number of modes
%
% Output
%  modes - modal @orientation
%  values - values of the ODF at the modal @orientation
%
% Options
%  resolution  - search--grid resolution
%  accuracy    - in radians
%
% Example
%
%   %find the local maxima of the <SantaFe.html SantaFe> ODF
%   mode = calcModes(SantaFe)
%   plotPDF(SantaFe,Miller(0,0,1,mode.CS))
%   annotate(mode)
%
% See also
% SO3Fun/max

warning('mtex:obsolete',...
  ['calcModes is depreciated. Please use instead \n' ...
  ' [value,ori] = max(odf) '])

[values,modes] = max(SO3F,varargin{:});