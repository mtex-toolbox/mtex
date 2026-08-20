function check_fundamentalRegion
% project2FundamentalRegion must reproduce the misorientation angle
%
% For o1 with symmetry CS1 and o2 with CS2, the rotation angle of
% project2FundamentalRegion(inv(q1).*q2, CS2, CS1) has to equal
% angle(o1,o2) - the disorientation angle, i.e. the smallest angle over all
% symmetrically equivalent representations.
%
% This file used to loop over crystalSymmetry(1) .. crystalSymmetry(11).
% That numeric point group id constructor no longer exists, so the file
% failed on develop with "First argument must be text" and had silently
% stopped testing anything at all. Ids 1 to 11 were in any case only the
% triclinic and monoclinic groups - everything of order at most 4, per
% geometry/@symmetry/private/pointGroupList.m, where 222 is id 12 - so
% cubic, hexagonal, trigonal and tetragonal were never covered. That is why
% it was cheap.
%
% It now runs over all 11 Laue classes. The bulk is same-symmetry
% misorientations, which is both the common case and the one where the
% higher symmetries make the projection actually hard. A handful of
% cross-symmetry pairs cover the two-symmetry branch, i.e. a phase boundary.
%
% See also
% quaternion/project2FundamentalRegion orientation/angle

rng(0)

% the 11 Laue classes
laue = {'-1','2/m','mmm','4/m','4/mmm','-3','-3m','6/m','6/mmm','m-3','m-3m'};

N = 500;
tol = 1e-10;

% -- same symmetry, all 11 classes ----------------------------------------
for k = 1:numel(laue)
  cs = crystalSymmetry(laue{k});
  checkPair(cs,cs,N,tol,laue{k});
end

% -- two different symmetries, i.e. a phase boundary ----------------------
% the branch that takes CS2 and CS1 separately; kept to a few representative
% pairs because angle() on mismatched symmetries prints both of them
cross = {'m-3m','-3m'; '6/mmm','2/m'; '4/mmm','-1'; 'mmm','m-3'};

for k = 1:size(cross,1)
  cs1 = crystalSymmetry(cross{k,1});
  cs2 = crystalSymmetry(cross{k,2});
  checkPair(cs1,cs2,N,tol,[cross{k,1} ' x ' cross{k,2}]);
end

checkMemo;

disp('check_fundamentalRegion: passed')

end

% =========================================================================
function checkMemo
% symmetry/fundamentalRegion remembers the regions it computed - the memo
% has to hand back what the computation would, and must never confuse two
% symmetries that differ
%
% The key is built from the rotations, the lattice, the plotting convention
% and the name, never from the point group id: two symmetries of the same
% id can be aligned differently or sit on a different lattice, which is
% exactly how the inverse pole figure color key cache went stale. Anything
% dropped from that key shows up here as one of the two regions below
% coming back for the other.

pg = {'-1','mmm','4/mmm','-3m','6/mmm','m-3m','321','23'};
opt = { {}, {'antipodal'}, {'pointGroup'}, {'axisAngle','Sections',6} };

for i = 1:numel(pg)
  for k = 1:numel(opt)

    cs = crystalSymmetry(pg{i},'mineral','A');

    clear fundamentalRegion % cold
    [oR1,dcs1,n1] = fundamentalRegion(cs,cs,opt{k}{:});
    [oR2,dcs2,n2] = fundamentalRegion(cs,cs,opt{k}{:}); % from the memo

    % eqTol, not == : phaseItem seals eq to handle identity, so two equal
    % symmetries are never == unless they are the same object
    lbl = [pg{i} ' ' strjoin(cellfun(@num2str,opt{k},'uniformOutput',false),' ')];
    assert(isequal(fpRegion(oR1),fpRegion(oR2)) && n1 == n2 && eqTol(dcs1,dcs2), ...
      'check_fundamentalRegion: the memo changed the region for %s',lbl);

    % the single symmetry syntax, and the pair with a specimen symmetry -
    % the latter has no lattice, which a key hashing one crashes on
    clear fundamentalRegion
    a = fpRegion(fundamentalRegion(cs,opt{k}{:}));
    assert(isequal(a,fpRegion(fundamentalRegion(cs,opt{k}{:}))), ...
      'check_fundamentalRegion: the memo changed the region for %s, one symmetry',lbl);

    clear fundamentalRegion
    b = fpRegion(fundamentalRegion(cs,specimenSymmetry,opt{k}{:}));
    assert(isequal(b,fpRegion(fundamentalRegion(cs,specimenSymmetry,opt{k}{:}))), ...
      'check_fundamentalRegion: the memo changed the region for %s, specimen symmetry',lbl);
  end
end

% symmetries that differ must not share an entry - each region has to equal
% the one computed for it alone
variants = {crystalSymmetry('321',[1 1 2],'mineral','Quartz'), ...
  crystalSymmetry('321',[1 1 2],'X||a','mineral','Quartz'), ...
  crystalSymmetry('321',[1 1 2],'mineral','Other'), ...
  crystalSymmetry('321',[1 1 3],'mineral','Quartz'), ...
  crystalSymmetry('622',[1 1 2],'mineral','Quartz')};

clear fundamentalRegion
shared = cellfun(@(cs) {fpRegion(fundamentalRegion(cs,cs))},variants);

for k = 1:numel(variants)
  clear fundamentalRegion
  alone = fpRegion(fundamentalRegion(variants{k},variants{k}));
  assert(isequal(shared{k},alone), ...
    'check_fundamentalRegion: the memo confused the symmetry variant %d',k);
end

% and the region has to carry the symmetry it was asked for, not the one of
% whatever entry happened to be there first
clear fundamentalRegion
fundamentalRegion(variants{1},variants{1});
oR = fundamentalRegion(variants{3},variants{3});
assert(strcmp(char(oR.CS1.mineral),'Other'), ...
  'check_fundamentalRegion: the memo returned a region of the wrong symmetry');

end

% -------------------------------------------------------------------------
function f = fpRegion(oR)
% everything a fundamental region is - the bounding quaternions, the
% vertices and the faces, in a form that isequal can compare

f = {sortrows(round([oR.N.a(:),oR.N.b(:),oR.N.c(:),oR.N.d(:)],9)), ...
  sortrows(round([oR.V.a(:),oR.V.b(:),oR.V.c(:),oR.V.d(:)],9)), ...
  sort(cellfun(@numel,oR.F)), oR.antipodal};

end

% =========================================================================
function checkPair(cs1,cs2,N,tol,lbl)

q1 = quaternion.rand(N);
q2 = quaternion.rand(N);

o1 = orientation(q1,cs1,specimenSymmetry);
o2 = orientation(q2,cs2,specimenSymmetry);

% NB @quaternion/project2FundamentalRegion returns ONE output. Its help
% block still documents a second one, omega, and the previous version of
% this test asked for it - so the file would have failed here too, even had
% the numeric symmetry constructor still existed. The angle is taken from
% the returned quaternion instead.
q = project2FundamentalRegion(inv(q1).*q2,cs2,cs1);
omega = angle(q,quaternion.id);

% it must be the disorientation angle
omega2 = angle(o1,o2);
err = max(abs(omega(:) - omega2(:)));
assert(err < tol, ...
  ['check_fundamentalRegion: %s - project2FundamentalRegion and angle ' ...
   'disagree by up to %.3g degree'], lbl, err/degree)

% the disorientation is the smallest of the equivalents, so it can never
% exceed the plain rotation angle
wPlain = angle(inv(q1).*q2,quaternion.id);
assert(all(omega(:) <= wPlain(:) + tol), ...
  'check_fundamentalRegion: %s - the projected angle exceeds the unprojected one', lbl)

% and for anything past triclinic it has to actually reduce some of them,
% otherwise the two assertions above would also hold for a projection that
% did nothing at all
if length(cs1.properGroup.rot) * length(cs2.properGroup.rot) > 1
  assert(any(omega(:) < wPlain(:) - 1e-6), ...
    ['check_fundamentalRegion: %s - the projection changed no angle at all, ' ...
     'so this case proves nothing'], lbl)
end

end
