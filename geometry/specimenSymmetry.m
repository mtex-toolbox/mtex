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

% any frame that is not a crystalFrame may be adopted: a crystal frame holds
% a lattice a specimen group knows nothing about
frameAdopted = nargin > 0 && isa(varargin{1},'referenceFrame') && ...
  ~isa(varargin{1},'crystalFrame');

if frameAdopted || nargin == 0 || isa(varargin{1},'plottingConvention')

  id = 1;
  rot = rotation.id;

elseif isa(varargin{1},'quaternion')  % the group given by its elements

  rot = varargin{1};

  if check_option(varargin,'pointId')
    id = get_option(varargin,'pointId');
  else
    id = symmetry.rot2pointId(rot,varargin{:});
  end

else

  id = symmetry.extractPointId(varargin{:});
  rot = symmetry.calcQuat(id,varargin{:});

end

how2plot = getClass(varargin,'plottingConvention');
if frameAdopted && ~isempty(how2plot)
  error('MTEX:specimenSymmetry:frameAndConvention',...
    ['A reference frame carries its own plotting convention - pass '...
    'either a frame or a convention, not both.'])
end
if isempty(how2plot), how2plot = plottingConvention.default; end

if frameAdopted
  sF = varargin{1};
else
  % the session frame carrying that convention, in the group that was asked
  % for - a group of its own means a sibling of it, never the frame itself
  sF = specimenFrame.frameFor(how2plot);
  if id ~= sF.sym.id, sF = sibling(sF,symmetry(id,rot)); end
end

if sF.id > 16
  warning(sF.pointGroup + " is not a suitable specimen symmetry!")
end

end
