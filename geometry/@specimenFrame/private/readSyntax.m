function [args,post] = readSyntax(argin)
% read the specimen frame syntax into the arguments the frame itself takes
%
% Every way of naming a specimen frame ends here, which is what lets the
% constructor call its superclass exactly once and unconditionally - the
% thing MATLAB does not allow inside a branch.
%
% Output
%  args - what @referenceFrame is constructed with
%  post - what has to be applied afterwards: the group asked for, a frame to
%         carry trivially, and whether a frame is being named or looked up

post = struct('adopt',[],'id',[],'rot',[],'args',{{}},'bare',false);

% nothing given - the empty frame clone and the register build on
if isempty(argin)
  args = {}; post.bare = true;
  return
end

post.args = argin;

% a frame given: the trivial group carrying it
if isa(argin{1},'referenceFrame')

  assert(isa(argin{1},'specimenFrame'),'MTEX:wrongFrameClass',...
    ['A specimen frame carries no lattice, so it cannot stand in for a ' ...
    class(argin{1}) '.']);

  post.adopt = argin{1};
  args = {};
  return

end

if isa(argin{1},'plottingConvention')

  % the session frame drawn that way, claiming no group
  post.id = 1; post.rot = rotation.id;

elseif isa(argin{1},'quaternion')

  % the group given by its elements
  post.rot = argin{1};
  if check_option(argin,'pointId')
    post.id = get_option(argin,'pointId');
  else
    post.id = symmetry.rot2pointId(post.rot,argin{:});
  end

elseif isPointGroupName(argin{1})

  % the session frame in the group asked for
  post.id = symmetry.extractPointId(argin{:});
  post.rot = symmetry.calcQuat(post.id,argin{:});

else

  % a frame of its own, named - the name may lead
  if ischar(argin{1}) || isstring(argin{1})
    argin = [argin(2:end),{'name',char(argin{1})}];
  end
  args = argin;
  return

end

% a group was asked for: the frame comes from the register, not from here
args = {};

end
