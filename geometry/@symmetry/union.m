function s = union(s1,s2)
% returns the union of two symmetry groups
%
% 

if isa(s1,'symmetry')
  rot = s1.rot;
else
  rot = s1;
end

if isa(s2,'symmetry'), s2 = s2.rot; end

rot = unique(rot * s2);

% find a symmetry that exactly contains s
for i=1:45 % check all Laue groups
  
  s = crystalSymmetry('pointId',i);
  
  if numSym(s) == length(rot) && all(any(isappr(abs(dot_outer(rot,s.rot)),1)))   
    
    try %#ok<TRYNC>
      s.axes = s1.axes;       % coordinate system
      s.mineral = s1.mineral; % mineral name
      s.color  = s1.color;    % color used for EBSD / grain plotting
    end
    return
  end
  
end

s = crystalSymmetry(rot);

try %#ok<TRYNC>
  s.axes = s1.axes;       % coordinate system
  s.mineral = s1.mineral; % mineral name
  s.color  = s1.color;    % color used for EBSD / grain plotting
end