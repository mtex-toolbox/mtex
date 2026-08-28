function ori = fit(varargin)
% define a (mis)orientation by fitting pairs of vectors
%
% Description
% Define an orientation that maps the directions u onto the directions v
%
% Syntax
%   ori = orientation.fit(u,v)
%
% Input
%  u, v - @vector3d @Miller
%  CS - @crystalSymmetry
%  SS - @specimenSymmetry
%
% Output
%  ori - @orientation
%
% See also
% orientation/orientation orientation/byMiller orientation/byAxisAngle
% orientation/byEuler orientation.map

% find and remove symmetries
args  = cellfun(@(s) isa(s,'referenceFrame'),varargin,'uniformoutput',true);
sym = varargin(args);
varargin(args) = [];
   
ori = orientation(rotation.fit(varargin{:}));
        
if isCrystalDirection(varargin{1})
  ori.CS = varargin{1}.CS; 
  if ~isempty(sym), ori.SS = sym{1}; end
else
  if ~isempty(sym), ori.CS = sym{1}; end
end

if isCrystalDirection(varargin{2}), ori.SS = varargin{2}.CS; end

if length(sym) == 2
  ori.CS = sym{1};
  ori.SS = sym{2};
end
    
end
