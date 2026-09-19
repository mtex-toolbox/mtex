function w = calcVoronoiVolume(rot,V,C,varargin)
% compute the the volume of the Voronoi cells which are constructed by the
% Voronoi decomposition for unit quaternions
%
% Input
%  q    - @quaternion
%  V, C - the 'struct' output of quaternion/calcVoronoi
%
% Output
%  w - Volume of the Voronoi cells as a column vector
%
% See also
% quaternion\calcVoronoi voronoin vector3d/calcVoronoiArea

if isa(rot,'orientation')
  rot = rot.project2FundamentalRegion;
end

% maybe voronoi decomposition has already been computed
if nargin < 3, [V,C] = calcVoronoi(rot,'struct'); end

% project everything to the tangential space
q = reshape(quaternion(rot.subSet(C.center)),[],1);
Vk = log(V.subSet(C.vertices),q);
Vk = Vk.xyz;

% compute the volume in the tangential space
w = zeros(length(rot),1);
last = [0;find(diff(C.center));length(C.center)];
% TODO: Speed up this loop

cP = progressCounter(length(last)-1);
for k=1:length(last)-1

  ndx = last(k)+1:last(k+1);
  [~,w(C.center(ndx(1)))] = convhull(Vk(ndx,:));
  
  cP.show(k); 
  
end

% generators that are one and the same rotation share a cell and its volume
w = w ./ C.mult;

end
