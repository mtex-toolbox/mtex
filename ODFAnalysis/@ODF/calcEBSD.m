function ebsd = calcEBSD(odf,varargin)
% simulate EBSD data from ODF
%
% Syntax
%   ebsd = calcEBSD(odf,points)
%
% Input
%  odf    - @ODF
%  points - number of orientation to be simualted
%
% Output
%  ebsd   - @EBSD
%
% See Also
% ODF_calcPoleFigure, ODF_calcOrientations

ori = calcOrientations(odf,varargin{:});

ebsd = EBSD(ori);
