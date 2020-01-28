function s = union(s1,s2)
% returns the union of two symmetry groups
%
% 

if isa(s2,'symmetry')
  axes = s2.axes;
  s2 = s2.rot;   
else
  s2 = [rotation.id; s2(:)];
end
if isa(s1,'symmetry')
  rot = s1.rot;
  axes = s1.axes;
else
  rot = [rotation.id;s1(:)]; 
  axes = s1.axes;
end

rot = unique(rot * s2);

s = crystalSymmetry(rot,axes);

try %#ok<TRYNC>
  s.mineral = s1.mineral; % mineral name
  s.color  = s1.color;    % color used for EBSD / grain plotting
end
