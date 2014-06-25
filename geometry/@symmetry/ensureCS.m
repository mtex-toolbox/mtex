function obj = ensureCS(csNew,obj)
% ensures that an obj has the right crystal symmetry

csOld = obj.CS;

% if equal, everythink is ok
if csOld == csNew, return;end

% check for compatibility
axesOld = reshape(double(csOld.axes),3,3);
axesNew = reshape(double(csNew.axes),3,3);
M = axesOld^(-1) * axesNew;

% if compatible transform to new reference frame
MM = M'*M;%norm(MM - diag(diag(MM))) / norm(MM)
if csNew.id == csOld.id && ...
    norm(MM - eye(3)) / norm(MM) < 1*10^-1
  obj = obj.transformReferenceFrame(csNew);
  return
end

% trivial symmetry - for the lazy ones
if csOld.id < 3 && isnull(norm(axesOld - eye(3)))
  obj.CS = csNew;
  return
end

% otherwise put an error since crystal symmetries are equal
disp(' ')
cs1 = csOld; display(cs1)
cs2 = csNew; display(cs2)
if getMTEXpref('stopOnSymmetryMissmatch',true)
  error('The above two symmetries does not match!')
else
  warning('MTEX:symmetry:missmatch','The above two symmetries does not match!')
end
