function ori = calcOrientations(odf,points,varargin)
% draw random orientations from ODF
%
% Syntax
%   ori = calcOrientations(odf,points)
%
% Input
%  odf    - @ODF
%  points - number of orientation to be simualted
%
% Output
%  ori   - @orientation
%
% See also
% ODF_calcPoleFigure, ODF_calcEBSD

ori = discreteSample(odf,points,varargin{:});
