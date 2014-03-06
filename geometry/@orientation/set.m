function obj = set(obj,vname,value,varargin)
% set object variable to value

if isa(vname,'CS') && ...
    check_option(varargin,'keepEuler')
    
  %%TODO
  
  [a,b,g] = get(obj,'Euler');

  obj.CS =  value;
  
  obj.quaternion = euler2quat(a,b,g,value);
  
elseif strcmpi(vname,'CS') 
  
  axes = get(obj.CS,'axes');
  
  if ~all(axes == [xvector,yvector,zvector]) && ~check_option(varargin,'noTrafo')
  
    % warning('Changing the crystal symmetry changes the Euler angles!')
  
    M = transformationMatrix(obj.CS,value);
    obj.rotation = obj.rotation * rotation('matrix',M^-1);
  end
  
  obj.CS = value;
  
else
  if iscell(value), value = value{1}; end
  obj.(vname) = value;
end

% this is some testing code
% cs1 = symmetry('triclinic',[1 2 3],[70 80 120]*degree,'Z||a*')
% cs2 = symmetry('triclinic',[1 2 3],[70 80 120]*degree,'Z||b','X||a*')
% o = orientation('Euler',30*degree,50*degree,120*degree,cs1)
% o * Miller(1,0,0,cs1)
% o2 = set(o,'CS',cs2)
% o2 * Miller(1,0,0,cs2)
