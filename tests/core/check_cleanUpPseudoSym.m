function check_cleanUpPseudoSym
% check that cleanUpPseudoSym corrects both indexing solutions
%
% A measurement is a fixed representative ori of an orientation, so the
% alternative indexing solution is ori * s * mori for some symmetry element
% s - not simply ori * mori, since only the symmetry acting from the right
% is divided out again. The command used to apply exactly the operators it
% was handed, so a patch that needs the inverse of the given pseudo symmetry
% was merged with its neighbour but never rotated: it kept its colour and
% picked up scattered mis-flipped pixels.
%
% On mtexdata forsterite that was the difference between 237 and 275
% corrected pixels, depending only on whether the caller passed 60 degree
% about [100] or both 60 and 120 degree - which is why the documentation
% used to ask for both. The operator list is now completed internally, so
% any representative of the pseudo symmetry gives the same result.

checkBothSolutions;
checkRepresentativeIndependence;
checkOtherPhaseUntouched;
checkTrueSymmetry;

disp('check_cleanUpPseudoSym: passed');

end

% =========================================================================
function checkBothSolutions
% a patch indexed with either of the two solutions must be corrected

for k = 1:2

  [ebsd,grains,psSym,nPatch,cs] = pseudoSymMap(k);

  [ebsdC,grainsC,numChanged] = cleanUpPseudoSym(ebsd,grains,psSym);

  assert(length(grains(cs.mineral)) == 2 && length(grainsC(cs.mineral)) == 1, ...
    'check_cleanUpPseudoSym: solution %d, expected the two grains to be merged into one, got %d before and %d after',...
    k, length(grains(cs.mineral)), length(grainsC(cs.mineral)))

  assert(numChanged == nPatch, ...
    'check_cleanUpPseudoSym: solution %d, expected %d corrected pixels, got %d',...
    k, nPatch, numChanged)

  % every pixel now describes the same orientation
  ori = ebsdC(cs.mineral).orientations;
  assert(max(angle(ori,ori.subSet(1))) < 1e-3*degree, ...
    'check_cleanUpPseudoSym: solution %d, the map is not uniform after the correction, up to %.2f degree left',...
    k, max(angle(ori,ori.subSet(1)))/degree)

end

end

% -------------------------------------------------------------------------
function checkRepresentativeIndependence
% the result must not depend on which representative of the pseudo symmetry
% the caller happens to pass

for k = 1:2

  [ebsd,grains,psSym,~,cs] = pseudoSymMap(k);

  % the inverse, 120 degree about [100] and both together all describe the
  % same pseudo symmetry
  inverse = inv(psSym); inverse.CS = psSym.CS; inverse.SS = psSym.SS;
  twice = orientation.byAxisAngle(Miller(1,0,0,cs,'uvw'),120*degree,cs,cs);

  ref = cleanUpPseudoSym(ebsd,grains,psSym);
  ref = ref(cs.mineral).orientations;

  variants = {inverse, twice, [psSym,twice]};
  names = {'the inverse','120 degree','60 and 120 degree'};

  for v = 1:numel(variants)
    ori = cleanUpPseudoSym(ebsd,grains,variants{v});
    ori = ori(cs.mineral).orientations;
    assert(max(angle(ori,ref)) < 1e-3*degree, ...
      'check_cleanUpPseudoSym: solution %d, passing %s gives a different map',...
      k, names{v})
  end

end

end

% -------------------------------------------------------------------------
function checkOtherPhaseUntouched
% the phase is selected by the symmetry of the pseudo symmetry, everything
% else has to survive untouched

[ebsd,grains,psSym,~,cs] = pseudoSymMap(1);

other = 'other';
ebsdC = cleanUpPseudoSym(ebsd,grains,psSym);

assert(length(ebsdC(other)) == length(ebsd(other)), ...
  'check_cleanUpPseudoSym: the second phase lost pixels')

assert(max(angle(ebsdC(other).orientations,ebsd(other).orientations)) < 1e-3*degree, ...
  'check_cleanUpPseudoSym: the second phase was rotated')

assert(length(ebsdC(cs.mineral)) == length(ebsd(cs.mineral)), ...
  'check_cleanUpPseudoSym: the corrected phase lost pixels')

end

% -------------------------------------------------------------------------
function checkTrueSymmetry
% a true symmetry has nothing to correct - it must warn instead of silently
% flipping pixels by a symmetry element

[ebsd,grains,~,~,cs] = pseudoSymMap(1);

trueSym = orientation.byAxisAngle(Miller(1,0,0,cs,'uvw'),180*degree,cs,cs);

lastwarn('');
ws = warning('off','cleanUpPseudoSym:TrueSymmetry');
cleanup = onCleanup(@() warning(ws));

[~,~,numChanged] = cleanUpPseudoSym(ebsd,grains,trueSym);

[~,id] = lastwarn;
assert(strcmp(id,'cleanUpPseudoSym:TrueSymmetry'), ...
  'check_cleanUpPseudoSym: a true symmetry did not raise the expected warning')

assert(numChanged == 0, ...
  'check_cleanUpPseudoSym: a true symmetry changed %d pixels', numChanged)

end

% =========================================================================
function [ebsd,grains,psSym,nPatch,cs] = pseudoSymMap(solution)
% a uniform map with one ragged patch indexed with the other solution
%
% solution 1 puts the patch at ori * mori, which needs the inverse operator
% to be corrected - this is the case the command used to get wrong. Solution
% 2 puts it at ori * inv(mori), which it always got right.

cs = crystalSymmetry('mmm',[4.8 10.2 6.0],'mineral','pseudoHex');
csOther = crystalSymmetry('m-3m','mineral','other');

n = 24;
o0 = orientation.byEuler(20*degree,30*degree,10*degree,cs);

% the pseudo symmetry of a hexagonal sublattice stacked along [100]
psSym = orientation.byAxisAngle(Miller(1,0,0,cs,'uvw'),60*degree,cs,cs);

if solution == 1
  oPatch = o0 .* psSym;
else
  oPatch = o0 .* inv(psSym);
end

% a ragged border, which is what the tortuosity criterion keys on
isPatch = false(n,n);
for r = 1:n
  isPatch(r,(14 + mod(r,2)):n) = true;
end
nPatch = nnz(isPatch);

rot = rotation.id(n,n);
rot(~isPatch) = o0;
rot(isPatch) = oPatch;

% phase 1 notIndexed, phase 2 the pseudo symmetric one, phase 3 a bystander
phaseId = 2*ones(n,n);
phaseId(1:4,1:4) = 3;
rot(1:4,1:4) = orientation.byEuler(10*degree,20*degree,30*degree,csOther);

ebsd = EBSDsquare([],rot,phaseId,[0 1 2],{'notIndexed',cs,csOther},'dxy',[1 1]);

[grains,ebsd] = calcGrains(ebsd,'angle',10*degree);

end
