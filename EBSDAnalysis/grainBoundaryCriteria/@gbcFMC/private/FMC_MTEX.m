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



% per pixel orientation noise in degree, from the neighbour misorientations:
% |del|^2 is 2 sigma^2 chi^2_3, whose median is 2*2.366*sigma^2 - the median,
% so that boundary pairs do not enter, and only over the finite ones, since a
% single NaN would collapse the estimate to its floor
finiteDel = del(isfinite(del));
if isempty(finiteDel)
  fmc.sigma = 1e-3;
else
  fmc.sigma = max(median(finiteDel)/sqrt(4*2.3659738843), 1e-3);
end

rep.sigma = fmc.sigma;

% largest disorientation the symmetry admits, in degree - a group property, so once
fmc.maxAng = maxAngle(fmc.CS)/degree;


% above maxDelta the coupling is cut, and so is a non finite misorientation
w = exp(-fmc.cmaha0*(del));
w(~isfinite(del)) = 0;

wCut = w;
wCut(del > fmc.maxDelta) = 0;

fmc.W = sparse(i, j, wCut, N, N);

% the uncut weights, FMC_interpret needs a candidate for every stranded pixel
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

% one entry per scale, FMC_interpret compares saliencies between scales

clear W; clear Wnext; clear Sal; clear v;
clear links; clear Aves; clear Varin;





