function ori = calcOrientations(odf,points,varargin)
% draw random orientations from ODF
%
% Syntax
%   ori = calcOrientations(odf,points)
%
% Input
%  odf    - @SO3Fun
%  points - number of orientation to be simualted
%
% Output
%  ori   - @orientation
%
% See also
% ODF_calcPoleFigure, ODF_calcEBSD

warning('The command calcOrientations is depreciated! Please use discreteSample instead.')

ori = discreteSample(odf,points,varargin{:});
