function G = union(varargin)
% union of two SO3Grids
%% Input
%  G1, G2 - @SO3Grid
%% Output
%  "points" - @SO3Grid

if length(varargin) == 1 && length(varargin{1})==1
  G = varargin{1};
  return;
end

OG = [varargin{:}];

% check symmetries
if numel(OG) > 1 && ( ~equal([OG.CS],2) || ~equal([OG.SS],2))
  warning('MTEX:SO3GridUnion','Processing orientations with different symmetries!');
end


G.alphabeta = [];
G.gamma    = [];
G.resolution = min([OG.resolution]);
G.options = {};
G.CS      = OG(1).CS;
G.SS      = OG(1).SS;
G.center  = [];
G.Grid    = quaternion(OG);

G = class(G,'SO3Grid');
