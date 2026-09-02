function sF = applySyntax(sF,post)
% hand back the specimen frame the syntax asked for
%
% A frame named here is a frame of its own and stays unregistered - the
% named factories are what put one in the register. A group or a convention
% asked for is a lookup instead: it names the session frame, in the group
% asked for, and that is an entity the register owns.

% nothing to look up - a bare frame, or one named and built above
if post.bare || (isempty(post.adopt) && isempty(post.id)), return; end

argin = post.args;

how2plot = getClass(argin,'plottingConvention');
if ~isempty(post.adopt) && ~isempty(how2plot)
  error('MTEX:specimenSymmetry:frameAndConvention',...
    ['A reference frame carries its own plotting convention - pass '...
    'either a frame or a convention, not both.'])
end
if isempty(how2plot), how2plot = plottingConvention.default; end

if ~isempty(post.adopt)

  % the trivial group carrying that frame - its group-stripped sibling
  sF = stripSym(post.adopt);

else

  % the session frame carrying that convention, in the group that was asked
  % for - a group of its own means a sibling of it, never the frame itself
  sF = specimenFrame.frameFor(how2plot);
  sF = sibling(sF,symmetry(post.id,post.rot));

end

if sF.id > 16
  warning(sF.pointGroup + " is not a suitable specimen symmetry!")
end

% the session instance of this frame - a file that lists two phases has two
% phases whatever their names and lattices, so an importer says 'noIntern'
if ~check_option(argin,'noIntern'), sF = referenceFrame.intern(sF); end

end
