function ebsd = subGrid(ebsd,q,epsilon,varargin)
% sub-SO3Grid as epsilon neigborhood of a node
%% Syntax
%  ebsd = subGrid(ebsd,midpoint,radius)
% 
%% Input
%  ebsd     - @EBSD
%  midpoint - @quaternion
%  radius   - double
%
%% Output
%  ebsd - @EBSD
%
%% See also
%  SO3Grid/subGrid SO3Grid/find S2Grid/subGrid


cz = [0 cumsum(sampleSize(ebsd))];
ind = false(cz(end),1);
for k=1:numel(ebsd)
  [ignore ind(cz(k)+1:cz(k+1))] = subGrid(ebsd(k).orientations,q,epsilon,varargin{:});  
end
ebsd = copy(ebsd,ind);
