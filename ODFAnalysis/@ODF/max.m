function [m,ori] = max(odf,varargin)
% heuristic to find local modal orientations
%
% Syntax
%
%   [m,ori] = max(odf)
%
%   % find two local maxima
%   [m,ori] = max(odf,'numLocal',2)
%
% Input
%  odf - @ODF 
%
% Output
%  m   - maximum in multiples of the uniform ODF
%  ori - @orientation where the maximum is atained
%
% Options
%  resolution  - search--grid resolution
%  accuracy    - in radians
%  numLocal    - number of local maxima to find
%
% Example
%  %find the local maxima of the <SantaFe.html SantaFe> ODF
%  [m,ori] = max(SantaFe)
%  plotPDF(SantaFe,Miller(0,0,1,ori.CS))
%  annotate(ori)
%
%
% See also
% ODF/calcModes

[ori,m] = calcModes(odf,varargin{:});
