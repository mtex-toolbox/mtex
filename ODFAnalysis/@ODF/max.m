function [m,ori]= max(odf,varargin)
% heuristic to find local modal orientations
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
