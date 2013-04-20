function obj = ensureCS(csNew,obj)
% ensures that an obj has the right crystal symmetry

obj = obj{1};
csOld = get(obj,'CS');

% if equal, everythink is ok
if csOld == csNew, return;end

% check for compatibility
axesOld = reshape(double(get(csOld,'axes')),3,3);
axesNew = reshape(double(get(csNew,'axes')),3,3);
M = axesOld^(-1) * axesNew;

% if compatible transform to new reference frame
MM = M'*M;%norm(MM - diag(diag(MM))) / norm(MM)
if strcmp(csNew.laueGroup,csOld.laueGroup) && ...
    norm(MM - eye(3)) / norm(MM) < 1*10^-2
  obj = set(obj,'CS',csNew);
  return
end

% trivial symmetry - for the lazy ones
if strcmp(csOld.laueGroup,'-1') && isnull(norm(axesOld - eye(3)))
  obj = set(obj,'CS',csNew,'noTrafo');
  return
end

% otherwise put an error since crystal symmetries are equal
error('Missmatch in crystal symmetries!')
