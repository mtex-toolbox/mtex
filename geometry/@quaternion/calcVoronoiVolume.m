function w = calcVoronoiVolume(rot,V,C,varargin)
% compute the the volume of the Voronoi cells which are constructed by the
% Voronoi decomposition for unit quaternions
%
% Input
%  q - @quaternion
%
% Output
%  w - Volume of the Voronoi cells
%
% See also
% quaternion\calcVoronoi voronoin vector3d/calcVoronoiArea

rot = rot.project2FundamentalRegion;

% maybe voronoi decomposition has already been computed
if nargin == 1, [V,C] = calcVoronoi(rot,'struct'); end

% project everything to the tangential space
q = reshape(quaternion(rot.subSet(C.center)),[],1);
Vk = log(V.subSet(C.vertices),q);
Vk = Vk.xyz;

% compute the volume in the tangential space
w = zeros(size(rot));
last = [0;find(diff(C.center));length(C.center)];
% TODO: Speed up this loop
for k=1:length(last)-1
  ndx = last(k)+1:last(k+1);
  [~,w(C.center(ndx(1)))] = convhull(Vk(ndx,:));
  if ~check_option(varargin,'silent') && length(last)>5e4
    progress(k,length(last)); 
  end
end

end