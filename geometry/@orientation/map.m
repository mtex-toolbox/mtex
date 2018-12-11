function ori = map(varargin)
% define orientations by pairs of vectors
%
% Description
% Define an orientation that maps |u1| onto |v1| and |u2| onto |v2|
%
% Syntax
%   ori = orientation.map(u1,v1)
%   ori = orientation.map(u1,v1,u2,v2)
%
% Input
%  u1, v1, u2, v2 - @vector3d @Miller
%  CS - @crystalSymmetry
%
% Output
%  ori - @orientation
%
% See also
% orientation_index orientation/byMiller orientation/byAxisAngle
% orientation/byEuler


ori = orientation(oriation.map(varargin{:}));
        
if isa(varargin{1},'Miller'), ori.CS = varargin{1}.CS; end
if isa(varargin{2},'Miller'), ori.SS = varargin{2}.CS; end
    
end
