function fr = loadobj(s)
% a saved crystalSymmetry is the crystal frame it always was
%
% What the file carries depends on the version that wrote it: the lattice as
% the axes themselves, or as the frame the symmetry was attached to once ADR
% 0003 split the two. Either way the point group is the id, and the frame
% goes through the register the way any deserialized frame does - so a
% convention that differs from the session's makes a fork of its own rather
% than moving everybody, which is what referenceFrame/reintern decides.

if isa(s,'crystalFrame'), fr = s; return; end

args = {};
if isfield(s,'mineral') && ~isempty(s.mineral)
  args = [args,{'mineral',s.mineral}];
end
if isfield(s,'color') && ~isempty(s.color)
  args = [args,{'color',s.color}];
end
if isfield(s,'how2plot') && isa(s.how2plot,'plottingConvention')
  args = [args,{s.how2plot}];
end

% the lattice
if isfield(s,'frame') && isa(s.frame,'crystalFrame')
  fr = s.frame;
elseif isfield(s,'axes') && isa(s.axes,'vector3d') && length(s.axes) == 3
  fr = crystalFrame(s.axes,args{:});
else
  fr = crystalFrame('1',args{:});
end

% the point group it was written with
if isfield(s,'id') && s.id > 0 && s.id <= length(symmetry.pointGroups)
  fr = sibling(fr,crystalFrame(symmetry.pointGroups(s.id).Inter).sym);
end

end
