function [S3G,weightsG,id] = gridify(ori,varargin)
% approximate a list of vectors with vectors on a grid
%
% Syntax
%   [S3G, weightsG, id] = gridify(ori)
%   [S3G, weightsG, id] = gridify(ori,'weights',weights)
%
% Input
%  vec - @vector3d
%
% Output
%  S3G      - @SO3Grid
%  weightsG - double
%  id       - ids of 
%
% Options
%  weights    - 
%  resolution -
%  

% define a indexed grid
if ori.antipodal, aP = {'antipodal'}; else aP = {}; end
S3G = equispacedSO3Grid(ori.CS,ori.SS,aP{:},varargin{:});

% find correspondence between vectors and grid
id = find(S3G,ori);

% compute weights
weights = get_option(varargin,'weights',ones(size(ori)));
weightsG = accumarray(id,weights,[length(S3G) 1]);

% eliminate spare orientations from the grid
id = weightsG > 0;
S3G = S3G.subGrid(id);
weightsG = weightsG(id);
