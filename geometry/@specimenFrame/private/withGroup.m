function sF = withGroup(sF,argin)
% this named frame in the point group asked for
%
% The named factories take a group where the constructor takes one, so this
% is the constructor's group branch on a named frame instead of on the
% session frame: a group of its own means a sibling of the frame, never the
% frame itself.

if isempty(argin), return; end

if isa(argin{1},'quaternion')

  % the group given by its elements
  rot = argin{1};
  if check_option(argin,'pointId')
    id = get_option(argin,'pointId');
  else
    id = symmetry.rot2pointId(rot,argin{:});
  end

else

  if (ischar(argin{1}) || isstring(argin{1})) && ~isPointGroupName(argin{1})
    error('MTEX:specimenFrame:notAGroup',...
      ['A named specimen frame takes the point group it carries - '...
      '''%s'' does not name one. Write specimenFrame(''%s'') to name a '...
      'frame of its own.'],char(argin{1}),char(argin{1}));
  end

  id = symmetry.extractPointId(argin{:});
  rot = symmetry.calcQuat(id,argin{:});

end

sF = sibling(sF,symmetry(id,rot));

if sF.id > 16
  warning(sF.pointGroup + " is not a suitable specimen symmetry!")
end

end
