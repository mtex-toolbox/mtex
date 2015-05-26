function  oR = fundamentalRegion(cs,varargin)
% get the fundamental sector for a symmetry in the inverse pole figure
%
% Syntax
%   oR = fundamentalRegion(cs)
%   oR = fundamentalRegion(cs1,cs2)
%
% Input
%  cs,cs1,cs2 - @symmetry
%
% Ouput
%  sR - @orientationRegion
%
% Options
%  invSymmetry - wheter mori == inv(mori)
%

q = quaternion(cs);
if nargin == 2 && isa(varargin{1},'symmetry')
  q = q * quaternion(varargin{1});
end

% take +- minimal angles for each axis
q(isnull(q.angle)) = [];
axes = q.axis;

[axes,~,c] = unique(axes,'antipodal');
angles = zeros(size(axes));

for i = 1:length(axes)
  angles(i) = min(q(c==i).angle);
end

N = [axes,-axes];
Nq = axis2quat(N,pi-[angles,angles]/2);

oR = orientationRegion(Nq);

return


% maybe there is nothing to do
if check_option(varargin,'complete')
  oR = orientationRegion(varargin{:});
  return
end

[axes,angle] = getMinAxes(cs);

rot = rotation('axis',[axes(:);-axes(:)],'angle',[angle(:);angle(:)]./2);

h = Rodrigues(rot);

% sort by length
[~,ind] = sort(norm(h));
h = h(ind);

% some may not be active
hh = vector3d;
for i = 1:length(h)
  
  if all(dot(h(i),hh)+1e-5<norm(hh).^2)
    hh = [hh,h(i)]; %#ok<AGROW>
  end
    
end







