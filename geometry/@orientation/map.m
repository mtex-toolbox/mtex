function ori = map(varargin)
% define orientations by pairs of vectors
%
% Syntax
%
%   h = Miller({1,0,0},{0,0,1},cs) % two crystal directions
%   r = [xvector, yvector]         % two specimen directions
%   ori = orientation.map(h(1),r(1),h(2),r(2))
%
% defines an orientation |ori| that appears
% 
%  * in the |(100)| pole figure at position |z| and in the |(001)| pole
%  figure at position |y|.
%  * in the |z| inverse pole figure at position |(100)| and in the |y|
%  inverse pole figure at position |(001)|.
%
%   nAlpha = Miller({1,0,0},csAlpha,'hkl')
%   nBeta  = Miller({0,1,1},csBeta, 'hkl')
%   dAlpha = Miller({1,1,1},csAlpha,'uvw')
%   dBeta  = Miller({0,1,-1},csBeta, 'uvw')
%   mori = orientation.map(nAlpha,nBeta,dAlpha,dBeta)
%
% defines an misorientation that aligns the lattice plane |(1,0,0)| of the
% alpha phase with the lattice plane |(011)| of the beta phase and the
% lattice direction |[111]| of the alpha phase with the lattice direction
% |[01-1]| of the beta phase.
%
% Input
%  h - @Miller 
%  r - @vector3d
%  nAlpha, nBeta - @Miller
%  dAlpha, dBeta - @Miller
%
% Output
%  ori - @orientation
%
% See also
% DefinitionAsCoordinateTransform orientation/byMiller orientation/byAxisAngle
% orientation/byEuler

% find and remove symmetries
args  = cellfun(@(s) isa(s,'referenceFrame'),varargin,'uniformoutput',true);
sym = varargin(args);
varargin(args) = [];
   
ori = orientation(rotation.map(varargin{:}));
        
% a direction naming one plane is written group-free, and the orientation it
% defines still belongs to the phase - ask the register for the group back
if isCrystalDirection(varargin{1})
  ori.CS = fullSym(varargin{1}.CS);
  if ~isempty(sym), ori.SS = sym{1}; end
else
  if ~isempty(sym)
    ori.CS = sym{1};
  else
    % reuse the default only while it carries this convention, see specimenSymmetryFor
    ori.CS = specimenSymmetryFor(getFrame(varargin{1}));
  end
end

if isCrystalDirection(varargin{2})
  ori.SS = fullSym(varargin{2}.CS);
elseif isa(varargin{2}.frame,'specimenFrame')
  % the input states a specimen frame - the result is expressed in it, in
  % the group the orientation already claims
  ori.SS = sibling(varargin{2}.frame,ori.SS.sym);
elseif ori.SS.how2plot ~= varargin{2}.how2plot
  % the input follows a different convention - take the frame that carries
  % it rather than writing the convention through a shared handle
  ori.SS = sibling(specimenFrame.frameFor(varargin{2}.how2plot),ori.SS.sym);
end

if length(sym) == 2
  ori.CS = sym{1};
  ori.SS = sym{2};
end
    
end
