function cF = applySyntax(cF,post)
% give a freshly built crystal frame its group, identity and convention
%
% and hand back the session instance of it, since a phase is an entity the
% register owns (ADR 0008 rule 2). An importer that must keep two phases
% apart whatever their names says 'noIntern'.

if post.bare, return; end

argin = post.args;

if isempty(post.adopt)

  % the group is written in these axes, so the frame states it - the
  % elements of a trigonal or monoclinic group depend on where a and c
  % point, which is this frame's business and not the group's
  rot = post.rot;
  if isempty(rot), rot = symmetry.calcQuat(post.id,cF.basis); end
  cF.sym = symmetry(post.id,rot);

  % a frame built from its axes may have been given a name outright, and
  % the mineral is that name - so no mineral means keep it
  mineral = get_option(argin,'mineral',char(cF.name));

else

  % the trivial group carrying that frame - its group-stripped sibling,
  % which donates its name
  cF = stripSym(post.adopt);
  mineral = get_option(argin,'mineral',char(cF.name));

end

% the mineral doubles as the frame identity
cF.mineral = strtrim(regexprep(mineral,char(0),' '));

askedColor = get_option(argin,'color','');
cF.color = askedColor;

if check_option(argin,'density')
  cF.opt.density = get_option(argin,'density','');
end

% the plotting convention, unless an adopted frame carries one
if isempty(post.adopt) || isempty(cF.how2plot)
  if post.id > 11 || post.id == 0
    cF.how2plot = plottingConvention(cF.cAxisRec,cF.aAxis);
  else
    cF.how2plot = plottingConvention(cF.cAxisRec,cF.bAxis);
  end
end

% the session instance of this frame - a file that lists two phases has two
% phases whatever their names and lattices, so an importer says 'noIntern'
if ~check_option(argin,'noIntern')
  registered = referenceFrame.intern(cF);
  % colour is not in the key, and the registered instance keeps the one it
  % was first given: loading a second file must not restyle data already in
  % the workspace. A colour asked for explicitly still wins
  if registered ~= cF && ~isempty(askedColor), registered.color = askedColor; end
  cF = registered;
end

end
