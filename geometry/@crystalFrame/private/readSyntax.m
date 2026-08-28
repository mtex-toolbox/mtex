function [args,post] = readSyntax(argin)
% read the crystal frame syntax into the arguments the frame itself takes
%
% Every way of naming a crystal frame ends here, which is what lets the
% constructor call its superclass exactly once and unconditionally - the
% thing MATLAB does not allow inside a branch.
%
% Output
%  args - what @referenceFrame is constructed with, the axes first
%  post - what has to be applied to the frame afterwards: the group, the
%         identity, and whether a frame is being adopted rather than built

post = struct('adopt',[],'id',1,'rot',[],'args',{{}},'bare',false);

% nothing given - the empty frame clone and the register build on
if isempty(argin)
  args = {}; post.bare = true;
  return
end

% a crystal frame given: the trivial group carrying it
if isa(argin{1},'crystalFrame')
  post.adopt = argin{1};
  argin(1) = [];
  args = {}; post.args = argin;
  return
end

% a specimen frame has no lattice, so it is not one a crystal group can be
% written in - its canonical basis would stand in for the crystal axes
if isa(argin{1},'referenceFrame')
  error('MTEX:wrongFrameClass',...
    ['A crystal frame is written in a lattice, not in a ' class(argin{1}) '.']);
end

if isa(argin{1},'quaternion')

  % the group given by its elements
  post.rot = rotation(argin{1});
  axes = getClass(argin,'vector3d',[xvector,yvector,zvector]);

  if check_option(argin,'pointId')
    post.id = get_option(argin,'pointId');
  else
    post.id = symmetry.rot2pointId(post.rot,axes);
  end

elseif isa(argin{1},'vector3d')

  % the axes themselves
  axes = argin{1}; argin(1) = [];
  post.id = get_option(argin,'pointId',1);

elseif isnumeric(argin{1})

  % lattice parameters, without a point group treated as triclinic
  abc = argin{1}; argin(1) = [];
  post.id = get_option(argin,'pointId',1);
  [angles,argin] = readAngles(argin,post.id);
  axes = calcAxis(post.id,abc,angles,argin{:});

else

  % a point group, named
  [post.id, argin] = symmetry.extractPointId(argin{:});

  abc = [1,1,1];
  if ~isempty(argin) && isnumeric(argin{1})
    abc = argin{1}; argin(1) = [];
  end

  [angles,argin] = readAngles(argin,post.id);
  axes = calcAxis(post.id,abc,angles,argin{:});

  % elements given beside the symbol win over the ones the symbol implies
  post.rot = getClass(argin,'quaternion');

end

args = [{axes},argin];
post.args = argin;

end

% -------------------------------------------------------------------------
function [angles,argin] = readAngles(argin,id)
% the angles between the axes, the ones the lattice implies unless given

angles = symmetry.pointGroups(id).lattice.defaultAngles;

if ~isempty(argin) && isnumeric(argin{1})
  angles = argin{1};
  if any(angles > 2*pi), angles = angles * degree; end
  argin(1) = [];
end

end
