function check_calcComponents
% SO3Fun/calcComponents - modes, their volumes, and the seed -> mode map
%
% Synthetic throughout: a model ODF with known components is a sharper test
% of whether they are recovered than any measured one.

checkSeededRadius
checkWeightsSumToOne
checkKnownComponents

disp('calcComponents: ok')

end

% -------------------------------------------------------------------------
function checkSeededRadius
% 'seed' together with 'radius' (#1840)
%
% accumarray stops at the largest centerId still inside the radius, so
% without an explicit output size weights comes back shorter than modes -
% every mode the seeds did not come close enough to is missing. The index
% remapping that follows then runs off the end of iid, which is where this
% used to die with "Index exceeds the number of array elements".

odf = twoComponentODF;

rng(0)
seed = orientation.rand(20,odf.CS);

[modes,weights,centerId] = calcComponents(odf,'seed',seed,...
  'resolution',5*degree,'radius',5*degree,'exact','silent');

assert(numel(weights) == length(modes),...
  'calcComponents: %d weights for %d modes - one per mode is expected',...
  numel(weights),length(modes))

assert(all(centerId >= 1 & centerId <= length(modes)),...
  'calcComponents: centerId leaves the range of modes')

% seeds where the ODF vanishes are dropped up front, so centerId covers the
% surviving ones rather than all of them
assert(numel(centerId) <= length(seed) && ~isempty(centerId),...
  'calcComponents: centerId has %d entries for %d seeds',...
  numel(centerId),length(seed))

% a radius so small that next to nothing falls inside is the sharpest form
% of the same thing - the answer stays one weight per mode, all negligible
[m0,w0] = calcComponents(odf,'seed',seed,'resolution',5*degree,...
  'radius',1e-4*degree,'exact','silent');
assert(numel(w0) == length(m0),...
  'calcComponents: %d weights for %d modes at a vanishing radius',...
  numel(w0),length(m0))
assert(sum(w0) < 1e-4,...
  'calcComponents: a vanishing radius should accumulate almost no weight, got %.4g',...
  sum(w0))

end

% -------------------------------------------------------------------------
function checkWeightsSumToOne
% with every seed inside the radius no weight may be dropped

odf = twoComponentODF;

rng(0)
seed = orientation.rand(20,odf.CS);

[~,weights] = calcComponents(odf,'seed',seed,'resolution',5*degree,...
  'radius',180*degree,'exact','silent');

assert(abs(sum(weights) - 1) < 1e-10,...
  'calcComponents: weights sum to %.6f, expected 1',sum(weights))

end

% -------------------------------------------------------------------------
function checkKnownComponents
% the components of a model ODF are what comes back out

cs = crystalSymmetry('m-3m');
c1 = orientation.byEuler(0,0,0,cs);
c2 = orientation.byEuler(30*degree,40*degree,50*degree,cs);
odf = 0.6*unimodalODF(c1,'halfwidth',7*degree) ...
    + 0.4*unimodalODF(c2,'halfwidth',7*degree);

[modes,weights] = calcComponents(odf,'silent');

assert(length(modes) == 2,...
  'calcComponents: found %d components, expected 2',length(modes))

assert(min(angle(modes,c1)) < 1*degree && min(angle(modes,c2)) < 1*degree,...
  'calcComponents: the modes are not at the two component centers')

% weights follow the modes, so sort both the same way before comparing
[weights,ind] = sort(weights,'descend');
modes = modes(ind);
expected = [0.6 0.4];
if min(angle(modes(1),c2)) < 1*degree, expected = [0.4 0.6]; end

assert(max(abs(weights(:).' - expected)) < 0.02,...
  'calcComponents: volumes %s, expected %s',...
  mat2str(round(weights(:).',3)),mat2str(expected))

end

% -------------------------------------------------------------------------
function odf = twoComponentODF
% sharp enough that the gradient ascent finds several spurious modes too -
% which is what makes the seed bookkeeping above worth checking

cs = crystalSymmetry('m-3m');
odf = 0.6*unimodalODF(orientation.byEuler(0,0,0,cs),'halfwidth',6*degree) ...
    + 0.4*unimodalODF(orientation.byEuler(30*degree,40*degree,50*degree,cs),...
      'halfwidth',6*degree);

end
