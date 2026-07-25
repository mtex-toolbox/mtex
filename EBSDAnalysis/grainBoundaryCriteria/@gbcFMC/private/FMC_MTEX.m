function [AllPs,AllSals,numClusters,W0,rep] = FMC_MTEX(fmc)
% build the FMC aggregation hierarchy
%
% Output
%  AllPs       - cell, AllPs{s} membership of the scale s-1 aggregates in
%                the scale s ones
%  AllSals     - cell, AllSals{s} the saliency of every scale s aggregate
%  numClusters - number of aggregates at each scale, numClusters(1) = pixels
%  W0          - finest level pixel couplings, WITHOUT the maxDelta cut
%  rep         - what FMC_report prints: .sigma and .nLin, the number of
%                aggregates that adopted a lattice gradient at each scale
%
% See also
% FMC_Coarsen FMC_interpret FMC_report gbcFMC

% setup Wnext
[i,j] = find(fmc.A_D);  % list of cells
N     = size(fmc.A_D,1);

q     = inv(fmc.O(i)).*fmc.O(j);

d     = abs(dot(q,quaternion.id));
checkSym = d < cos(20/2*degree);
if any(checkSym)
  d(checkSym) = max(abs(dot_outer(q(checkSym),fmc.CS.rot)),[],2);
end
del   = 2*real(acosd(d));

% compute all misorientations
% [i,j] = find(fmc.A_D);
% del = angle(fmc.O(i),fmc.O(j));



% Per pixel orientation noise, in degree, taken from the neighbour
% misorientations that were just computed. For isotropic noise of standard
% deviation sigma per tangent component the difference of two neighbours
% has 2*sigma^2 per component, so |del|^2 follows 2*sigma^2 * chi^2 with 3
% degrees of freedom and its MEDIAN is 2*2.366*sigma^2. The median rather
% than the mean, so that the pairs straddling a boundary and the misindexed
% ones - a minority, but arbitrarily large - do not enter the estimate.
%
% Any real orientation gradient inflates this slightly, which only makes
% the model selection in part6InterpWeights more conservative.
% NaN handling is not cosmetic here. A map carrying notIndexed pixels has
% NaN rotations, every misorientation involving one is NaN, median() of a
% vector holding a single NaN is NaN, and max(NaN,1e-3) quietly returns
% 1e-3 - so the noise estimate collapses to its floor, the outlier radius
% in part6InterpWeights degenerates with it, and the map sprouts single
% pixel grains. Only the finite misorientations may enter the estimate.
finiteDel = del(isfinite(del));
if isempty(finiteDel)
  fmc.sigma = 1e-3;
else
  fmc.sigma = max(median(finiteDel)/sqrt(4*2.3659738843), 1e-3);
end

rep.sigma = fmc.sigma;

% largest disorientation the symmetry admits, in degree. Computed once
% here: it is a symmetry group property, not a per level quantity, and
% calling maxAngle inside the coarsening loop cost more than the whole
% rest of part6InterpWeights put together
fmc.maxAng = maxAngle(fmc.CS)/degree;


% Above maxDelta the coupling is not merely small, it is cut. Nothing else
% in the coarsening can put two pixels in one aggregate once the edge
% between them is gone, so this is the only construct here that a boundary
% cannot survive. It is also the only fixed angular scale in the algorithm,
% which is why it is off by default - see the gbcFMC property.
%
% Non-finite misorientations (a notIndexed neighbour) are cut too: they
% would otherwise put NaN into W and poison every level above.
w = exp(-fmc.cmaha0*(del));
w(~isfinite(del)) = 0;

wCut = w;
wCut(del > fmc.maxDelta) = 0;

fmc.W = sparse(i, j, wCut, N, N);

% The UNCUT weights, for FMC_interpret. The cutoff and the interpretation
% want opposite things from this number and must not share it: the cutoff
% exists to stop an aggregate spanning a boundary, while the interpretation
% needs to know which neighbour a stranded pixel is LEAST unlike, and a
% misindexed pixel is by definition unlike all of them.
%
% Sharing one matrix made maxDelta zero every coupling a wild pixel had, so
% the adoption in FMC_interpret found no candidate at all and left it as
% its own grain - which is exactly the cost maxDelta was showing on the
% benchmark, and it was never about the grain boundaries there.
W0 = sparse(i, j, w, N, N);

clear q del

% RunFMC
fmc.W = fmc.W + fmc.W';
% make adjecency matrix symmetric
fmc.A_D = fmc.A_D | fmc.A_D';

W0 = W0 + W0';

%

AllPs = cell(1);
numClusters = size(fmc.W,1);

%v contains the number of data points in each node
fmc.v=ones(numClusters,1);

%Sal is the saliency of each node
fmc.Sal=Inf*ones(numClusters,1);

%
AllSals    = cell(1);
AllSals{1} = fmc.Sal;
fmc.Qvar   = zeros(N,1);

% Initialize the matrix that will hold all the seed for each s level
fmc.sSeeds = [];

%Coarsen repeatedly until the size of W doesn't change
fmc.sizeW = 0;
fmc.sizeWnext = N;

%s is the iteration number
fmc.sLevel = 1;

%storage=[struct('Ps', speye(length(Wnext)))];
fmc.P = speye(N);

% number of aggregates that adopted a lattice gradient, per scale. Level 1
% is the pixels themselves, which have no spread to fit anything to.
rep.nLin = 0;

while ~isequal(fmc.sizeW,fmc.sizeWnext)

  fmc = FMC_Coarsen(fmc);

  fmc.sLevel = fmc.sLevel+1;

  AllPs{fmc.sLevel}       = fmc.P;
  AllSals{fmc.sLevel}     = fmc.Sal;
  numClusters(fmc.sLevel) = size(fmc.W,1);
  rep.nLin(fmc.sLevel)    = fmc.nLin;

end

% AllSals stays a cell, one entry per scale: FMC_interpret compares
% saliencies BETWEEN scales, which a concatenated vector cannot express
% without carrying the per scale offsets around separately

clear W; clear Wnext; clear Sal; clear v;
clear links; clear Aves; clear Varin;





