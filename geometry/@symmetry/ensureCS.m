function obj = ensureCS(csNew,obj)
% ensures that an obj has the right crystal symmetry

csOld = obj.CS;

% if equal, everythink is ok
if eq(csOld,csNew,'laue'), return;end

% check for compatibility
try
  axesOld = reshape(double(csOld.axes),3,3);
  axesNew = reshape(double(csNew.axes),3,3);
catch
  warning('MTEX:symmetry:missmatch',...
    'The symmetries %s and %s do not match!',char(csNew),char(csOld));
  return
end
M = axesOld^(-1) * axesNew;

% if compatible transform to new reference frame
MM = M'*M;%norm(MM - diag(diag(MM))) / norm(MM)
if csNew.id == csOld.id && ...
    norm(MM - eye(3)) / norm(MM) < 1*10^-1
  if norm(M - eye(3)) > 1e-4
    disp(' ');
    disp('  The involved symmetries have different reference systems');
    disp(['  1: ' char(csOld,'verbose')]);
    disp(['  2: ' char(csNew,'verbose')]);
    disp('  I''m going to transform the data from the first one to the second one');
    disp(' ');
  end
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
if csOld.id ~= csNew.id
  cs1 = csOld; display(cs1)
  cs2 = csNew; display(cs2)
elseif ~all(isappr(norm(csOld.axes),norm(csNew.axes)))
  disp([' symmetry 1 axes length: ', num2str(norm(csOld.axes))]);
  disp([' symmetry 2 axes length: ', num2str(norm(csNew.axes))]);
else
  disp([' symmetry 1 axes angles: ', num2str([csOld.alpha,csOld.beta,csOld.gamma])]);
  disp([' symmetry 2 axes angles: ', num2str([csNew.alpha,csNew.beta,csNew.gamma])]);
end
if getMTEXpref('stopOnSymmetryMissmatch',true)
  error('The above two symmetries does not match!')
else
  warning('MTEX:symmetry:missmatch','The above two symmetries does not match!')
end
