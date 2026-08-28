function sF = specimenSymmetry(varargin)
% the specimen reference frame, carrying its point group
%
% Since <specimenFrame.specimenFrame.html |specimenFrame|> carries the point
% group (ADR 0008), a specimen symmetry *is* a specimen frame - this is the
% constructor that names it the way texture analysis does. It returns a
% @specimenFrame.
%
% Usually specimen symmetry is either triclinic or orthorhombic - the latter
% for a rolled sheet, symmetric about the rolling and transverse direction.
%
% A frame given as the first argument is adopted, and the result is that
% frame with the trivial group in it - which is how a plotting convention
% enters an @orientation.
%
% Syntax
%   specimenSymmetry
%   specimenSymmetry('mmm')
%   specimenSymmetry('orthorhombic')
%   specimenSymmetry(pC)
%   specimenSymmetry(frame)
%
% Input
%  name  - Schoenflies or International notation of the point group
%  pC    - @plottingConvention
%  frame - @referenceFrame to be carried by the trivial group
%
% Output
%  sF - @specimenFrame
%
% See also
% specimenFrame crystalSymmetry symmetry

% every way of naming a specimen frame lives in the constructor of
% <specimenFrame.specimenFrame.html |specimenFrame|> now
if nargin == 0
  sF = specimenFrame('1');
else
  sF = specimenFrame(varargin{:});
end

end
