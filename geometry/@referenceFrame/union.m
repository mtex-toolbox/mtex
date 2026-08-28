function s = union(s1,s2)
% returns the union of two symmetry groups
%
% 

if ~isa(s2,'referenceFrame')
  
  s = crystalFrame(unique(s1.rot * [rotation.id; s2(:)]),s1.axes);
  
elseif ~isa(s1,'referenceFrame')

  s = crystalFrame(unique([rotation.id;s1(:)] * s2.rot),s2.axes);
   
elseif s1.sym == s2.sym
  
  s = s1;
  
elseif s1 >= s2
    
  s = crystalFrame(s1.rot,s1.axes);
  
elseif s2 >= s1

  s = crystalFrame(s2.rot,s2.axes);
  
else
  
  s = crystalFrame(unique(s1.rot * s2.rot),s1.axes);
  
end
