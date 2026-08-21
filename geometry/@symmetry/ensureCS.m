function obj = ensureCS(csNew,obj)
% ensures that an obj has the right crystal symmetry

csOld = obj.CS;

% if equal, everything is ok
if eqTol(csOld,csNew), return; end

% a frame transition is only defined between two crystal symmetries
if ~isa(csOld,'crystalSymmetry') || ~isa(csNew,'crystalSymmetry')
  warning('MTEX:symmetry:missmatch',...
    'The symmetries %s and %s do not match!',char(csNew),char(csOld));
  return
end

% if the frames are compatible transform to the new reference frame
[compatible,M] = isCompatible(csOld.frame,csNew.frame);
if csNew.id == csOld.id && compatible
  if norm(M - eye(3)) > 1e-1
    disp(' ');
    disp('  The involved symmetries have different reference systems');
    disp(['  1: ' char(csOld,'verbose')]);
    disp(['  2: ' char(csNew,'verbose')]);
    disp('  I''m going to transform the data from the first one to the second one');
    disp(' ');
    obj = obj.transformReferenceFrame(csNew);
  else
    obj.CS = csNew;
  end  
  return
end

% trivial symmetry - for the lazy ones
if csOld.id < 3 && isnull(norm(csOld.axes.xyz - eye(3)))
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
