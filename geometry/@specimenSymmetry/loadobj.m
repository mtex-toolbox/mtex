function fr = loadobj(s)
% a saved specimenSymmetry is the specimen frame it always was
%
% A specimen frame has no lattice, so the point group and the convention are
% all there is to carry over. Asking specimenFrame for a group returns the
% session frame in it, which is what the register would have done anyway.

if isa(s,'specimenFrame'), fr = s; return; end

args = {};
if isfield(s,'how2plot') && isa(s.how2plot,'plottingConvention')
  args = [args,{s.how2plot}];
end

if isfield(s,'id') && s.id > 0 && s.id <= length(symmetry.pointGroups)
  fr = specimenFrame(symmetry.pointGroups(s.id).Inter,args{:});
else
  fr = specimenFrame('1',args{:});
end

end
