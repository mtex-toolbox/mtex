function [vecG,weightsG,id] = gridify(vec,varargin)
% approximate a list of vectors with vectors on a grid
%
% Syntax
%   [vecG, weightsG, id] = gridify(vec)
%   [vecG, weightsG, id] = gridify(vec,'weights',weights)
%
% Input
%  vec - @vector3d
%
% Output
%  vGrid   - @S2Grid
%  weightsG - double
%  id    - 
%
% Options
%  weights    - 
%  resolution -
%  

weights = get_option(varargin,'weights',ones(size(vec)));

% under a group the directions are gridded inside the sector the group
% reduces the sphere to, so each of them is represented once
if hasSymmetry(vec)
  varargin = [{vec.frame.fundamentalSector},varargin];
  vec = project2FundamentalRegion(vec);
end

% generate grid of vectors
if vec.antipodal, aP = {'antipodal'}; else, aP = {}; end
vecG = equispacedS2Grid(aP{:},varargin{:});

% find correspondence between vectors and grid
id = find(vecG,vec);

% compute weights
weightsG = accumarray(id,weights,[length(vecG) 1]);

% eliminate spare vectors in the grid
id = weightsG > 0;
vecG = vecG.subGrid(id);
weightsG = weightsG(id);

% the grid is written in the frame and the indices the directions came in
if ~isempty(vec.frame)
  vecG.framePrivate = vec.framePrivate;
  vecG.dispStyle = vec.dispStyle;
end
