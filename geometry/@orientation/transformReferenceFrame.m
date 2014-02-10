function ori = transformReferenceFrame(ori,cs)

% only applicable for crystal symmetry
if ~isCS(cs), 
  ori.CS = cs;
  return
end
  
% basis transformation into reference frame
M = transformationMatrix(ori.CS,cs);
rot = rotation(ori) * rotation('matrix',M^-1);

ori = orientation(rot,cs,ori.SS);

% this is some testing code
% cs1 = symmetry('triclinic',[1 2 3],[70 80 120]*degree,'Z||a*')
% cs2 = symmetry('triclinic',[1 2 3],[70 80 120]*degree,'Z||b','X||a*')
% o = orientation('Euler',30*degree,50*degree,120*degree,cs1)
% o * Miller(1,0,0,cs1)
% o2 = transformReferenceFrame(o,cs2)
% o2 * Miller(1,0,0,cs2)
