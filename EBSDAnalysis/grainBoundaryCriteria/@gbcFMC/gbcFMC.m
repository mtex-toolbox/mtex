classdef gbcFMC < grainBoundaryCriterion
% gbcFMC  fast multiscale clustering (FMC) grain boundary criterion
%
% Wraps the FMC algorithm (McMahon et al.). Unlike the local criteria this one
% clusters the whole neighbourhood graph at once; doEvaluate therefore builds
% the adjacency from (i,j), runs FMC, and reports for each pair whether both
% endpoints ended up in the same (non-zero) cluster.
%
% Each indexed phase is clustered separately, on its own pixels and with its
% own symmetry, so a pair straddling a phase boundary is always a boundary.
%
% Syntax
%
%   criterion = gbcFMC(cmaha);
%   criterion = gbcFMC('cmaha',3,'quatmax',5);
%   grains = calcGrains(ebsd,'fmc',3.8);
%   grains = calcGrains(ebsd,'fmc',3.8,'verbose');   % report the hierarchy
%   out = criterion.eval(ebsd,i,j);
%
% Output
%   out = 1   same cluster (same grain)
%   out = 0   grain boundary
%
% How it works
%
% FMC is an algebraic multigrid (AMG) coarsening of the pixel neighbourhood
% graph, in the tradition of segmentation by weighted aggregation (Sharon,
% Galun, Brandt, Basri), adapted to EBSD by McMahon et al. Instead of asking
% pixel by pixel "is this pair a boundary", it builds a HIERARCHY of nested
% aggregates and only decides at the end which level of the hierarchy each
% pixel should be read off at.
%
% One coarsening step (FMC_Coarsen) is:
%
%   1 edge dilution     drop edges far weaker than a node's average coupling
%   2 seed selection    pick coarse nodes C so every node is strongly
%                       coupled to C (the classic AMG C/F splitting)
%   3 interpolation P   each fine node gets FRACTIONAL membership in the
%                       seeds it couples to, row normalised - so the
%                       assignment is soft, not a hard partition
%   4 coarse graph      W <- P'*W*P, the Galerkin coarse grid operator
%   5 aggregate stats   each aggregate accumulates a mean orientation, a
%                       centroid, an orientation variance Qvar and, where
%                       it earns its parameters, a lattice gradient
%   6 rebias            coarse couplings are rescaled by a Mahalanobis
%                       factor, see cmaha below
%   7 saliency          Sal = external coupling / internal coupling, low
%                       for a well separated, coherent aggregate
%
% The theoretically interesting part is step 6. The coupling between two
% aggregates is measured against THEIR OWN internal orientation spread
% sqrt(Qvar), not against a fixed misorientation threshold. FMC therefore
% has no threshold angle at all: a 1 degree misorientation is a boundary
% between two very uniform aggregates and is not a boundary inside a
% deformed one.
%
% What gets compared there is the RESIDUAL misorientation. Each aggregate
% predicts, from its own fitted lattice gradient, what its offset to a
% neighbour ought to be, and only what neither of them can explain counts
% against the coupling. Without that, removing the curvature from Qvar
% would make the criterion stricter inside a deformed grain rather than
% more forgiving, since the raw misorientation between two aggregates of
% one deformed grain grows with the distance between them while a
% curvature-free Qvar does not.
%
% The second structurally interesting part is that no merge is ever
% committed during coarsening. FMC_interpret reads every pixel off at the
% scale where its aggregate is most salient relative to that scale, so a
% region that is complete early is not dragged along by a hierarchy that
% keeps coarsening around it.
%
% Options (defaults in brackets)
%   cmaha   - Mahalanobis sharpness of the coarse rebias (3)
%   cmaha0  - decay of the initial edge weight, per degree (0.05)
%   quatmax - ceiling on the outlier radius, degree (5)
%   alpha   - seed selection aggressiveness (0.2)
%   gammaW  - inverse edge dilution strength (10)
%   maxDelta- misorientation above which an edge is CUT, degree (Inf)
%   minPixel- regions below this size are absorbed into a neighbour (1)
%
% Flags
%   verbose - report the coarsening hierarchy, see FMC_report. Off by
%             default; the run itself says nothing.
%
% Measured on tests/EBSDGrainBenchmark, five map realisations per level,
% against the same benchmark run on the pre-2026-07-25 implementation:
%
%   level                    before                    after
%   1 clean       0.9712 +-0.0168, 33 grains   0.9875 +-0.0013, 34 grains
%   2 noisy       0.9696 +-0.0145, 115 grains  0.9720 +-0.0140, 33 grains
%   3 deformed    0.8403 +-0.0372, 115 grains  0.9466 +-0.0239, 31 grains
%
% (adjusted Rand index; 32 grains is the truth). Runtime for 80000 pixels
% fell from about 4.1 s to about 1.5 s.
%
% Notes and remaining limitations
%
%   * cmaha is the one parameter that still behaves like a threshold. On
%     the benchmark 3 to 5 is a plateau - below 2 grains merge and the low
%     angle boundaries are lost, above 5 the map over-segments - but the
%     optimum inside that plateau still drifts with the deformation level
%     (3 is best on level 1, 5 on levels 2 and 3). The default is 3.
%   * cmaha0, by contrast, is measurably irrelevant: sweeping it over
%     0.01 to 0.2 moves the level 1 score by less than 0.008.
%   * Qvar is a SCALAR, i.e. an isotropic spread, and deliberately so. A
%     3x3 tangent covariance was implemented and measured, and it is worse
%     on every level (0.958 / 0.964 / 0.931 against 0.9875 / 0.972 /
%     0.9466), not by tuning but for a reason: it makes the rebias
%     forgiving along whichever tangent direction the aggregate is already
%     spread in, and a boundary whose misorientation axis happens to line
%     up with a grain's own curvature is then read as expected and merged
%     across. Do not re-try this without a way to tell those two apart.
%   * the outlier radius is kappa = 4 standard deviations of the aggregate's
%     own spread, held inside [0.4 quatmax, quatmax]. kappa and the 0.4 are
%     constants fixed in FMC_Coarsen rather than user options; quatmax is
%     what to turn if the band is in the wrong place. On very clean data
%     the floor is what does the work - see the measurements there.
%   * on mtexdata EMSphinx, the austenite phase alone (478k px, noise
%     0.075 degree), FMC at cmaha 0.5 returns 1705 grains, or 1293 with
%     minPixel 5 - which is what minPixel is for, since it takes the grains
%     below 5 pixels from 393 to 1. Lowering cmaha below about 0.5 does
%     little on this data (1204 grains at 0.25), because what limits merging
%     there is the outlier radius, not the rebias.
%   * boundary localisation degrades at low angle: at 1 degree only about
%     38 % of the boundary lands on exactly the right pixel (mean offset
%     1.0 px), while at 5 degree and above it is essentially exact.

properties

  % Mahalanobis sharpness of the coarse level rebias. In part7BiasWeights
  % the coupling between two aggregates is multiplied by
  %
  %   exp(-cmaha*(|misorientation| - sqrt(Qvar))/sqrt(Qvar))
  %
  % so misorientations within one standard deviation of the aggregates'
  % internal spread are left essentially untouched and larger ones are
  % suppressed. cmaha sets how sharply that suppression sets in: larger
  % cmaha means stricter separation and more boundaries.
  cmaha   = 3

  % decay constant of the INITIAL edge weight, w = exp(-cmaha0*delta) with
  % delta the neighbour misorientation in degree. Used at the finest level
  % only, where no variance estimate exists yet, so it is the one place a
  % fixed angular scale enters: 0.05 per degree means the weight has fallen
  % to 1/e at 20 degree.
  %
  % Deriving this from the measured noise instead - a decay length of so
  % many sigma - was tried and is NOT better: it splits twins on ebsd2
  % (12 unsplit boundary lines down to 6) but costs the synthetic benchmark
  % (level 3 from 0.945 to 0.914), because a short decay makes the weights
  % inside a grain vary and the low angle boundaries harder to see. Diluting
  % harder, see gammaW, buys the same thing for free.
  cmaha0  = 0.05

  % CEILING on the outlier radius, in degree. A fine node is only folded
  % into an aggregate's statistics if it lies within that aggregate's
  % outlier radius of its mean; otherwise its interpolation weight is set
  % to zero, which is what keeps a misindexed pixel from corrupting Qvar
  % and hence the rebias.
  %
  % The radius itself is not this number: it is 4 standard deviations of
  % the aggregate's own spread, floored at twice the estimated noise and
  % capped here. A fixed radius put a fixed angular scale back into an
  % otherwise scale free algorithm and, worse, left the result on a knife
  % edge - see the kappa comment in FMC_Coarsen for the measurements.
  %
  % It also sets the FLOOR, at 0.4 of itself, so widening quatmax widens
  % the whole band the adaptive radius lives in.
  quatmax = 5

  % seed selection aggressiveness, in part1CoarseSeeds. A node becomes a
  % coarse seed unless its accumulated weight to the seeds already chosen
  % reaches alpha times its total weight to all neighbours. Larger alpha
  % makes it harder to be represented by existing seeds, so more seeds are
  % created, the hierarchy coarsens more slowly and has more levels.
  alpha   = 0.2

  % smallest region FMC will leave standing. Regions below it are eaten
  % from the rim inwards by whichever full sized neighbour touches them,
  % in FMC_interpret. Single pixel regions are always absorbed, since
  % those are misindexed pixels and putting them back in the grain around
  % them is what keeps FMC free of single pixel grains, so 1 and 2 mean
  % the same thing.
  %
  % Note that this ABSORBS, where calcGrains' own minPixel option DELETES:
  % that one runs a whole extra segmentation pass to find undersized
  % grains and then marks their pixels notIndexed, throwing away their
  % orientations. Since gbcFMC answers true to handlesMinPixel, calcGrains
  % skips that pass entirely and hands the value here instead, so
  %
  %   calcGrains(ebsd,'fmc',3.8,'minPixel',5)
  %   calcGrains(ebsd,gbcFMC(3.8),'minPixel',5)
  %   calcGrains(ebsd,gbcFMC(3.8,'minPixel',5))
  %
  % all mean the same thing and all run the clustering exactly once.
  minPixel = 1

  % HARD CEILING on the misorientation an edge may carry, in degree. Above
  % it the coupling is set to zero rather than merely reduced, so the
  % neighbourhood graph is disconnected there and no aggregate can ever
  % span it. Inf (the default) disables it.
  %
  % This is the one place a fixed angular scale can enter the algorithm,
  % which is why it is off unless asked for. What it is for is twins and
  % other high angle boundaries: exp(-cmaha0*60) = 0.0498 is a small
  % coupling but not a zero one, and on ebsd2 that was enough for
  % aggregates to coarsen straight through Sigma3 twin boundaries.
  %
  % Measured on ebsd2 ('A1', minPixel 1, cmaha 0.25), against benchmark
  % level 2 over five realisations:
  %
  %   maxDelta                Inf    30    20    15    10
  %   internal steps >10 deg  166   145    94    98   126
  %   of those >40 deg         83    68    41    44    62
  %   unsplit boundary lines   10    11     5     6    10
  %   benchmark L2 ARI      .9916 .9863 .9854 .9866 .9867
  %   benchmark L2 minDet     1.0   1.2   1.4   1.2   1.2
  %
  % Note it is NOT monotone - 10 is no better than no ceiling at all -
  % because a tighter one strands more pixels, which then have to be
  % adopted somewhere. 15 to 20 degree, the usual high angle boundary
  % convention, measures best.
  %
  % The cost is on the low angle boundaries, which is exactly what this
  % criterion exists to find: level 2 stops detecting all the 1 degree
  % boundaries. Real maps gain grains too - forsterite 2372 -> 2464,
  % EMSphinx 2211 -> 2410 (that pair with all phases in one graph, i.e.
  % before doEvaluate split them). Worth it on twinned material, not in
  % general, hence the default.
  %
  % Of what remains at 15 degree, most is not a failure at all: for 5 of
  % the 9 affected grains, cutting EVERY edge above 15 degree inside them
  % still leaves one connected piece, because the sharp boundary does not
  % fully cross the grain and the two sides join around its end. No
  % segmentation can split those.
  maxDelta = inf

  % INVERSE edge dilution strength, in part0EdgeDilution. An edge is deleted
  % when its weight falls below the node's mean neighbour weight divided by
  % gammaW, at both of its endpoints. Note the direction: a LARGER gammaW
  % lowers that threshold and therefore dilutes LESS.
  %
  % Lowered from 25 to 10 on 2026-07-25. At 25 the threshold sat at about
  % 0.04 of a typical intra-grain weight, and a 60 degree twin boundary
  % carries exp(-0.05*60) = 0.0498 - just above it. Twins therefore survived
  % dilution and aggregates coarsened straight through them, which is how a
  % grain came to contain 60 degree internal steps. Measured over five
  % benchmark realisations per level:
  %
  %   gammaW                    25       10        5
  %   benchmark level 1     0.9923   0.9922   0.9799
  %   benchmark level 2     0.9761   0.9916   0.9873
  %   benchmark level 3     0.9449   0.9559   0.9715
  %   level 1/2 minDetected 1.0/1.6  1.0/1.0  1.6/1.2
  %   ebsd2 unsplit lines       12       10        6
  %   forsterite grains       2102     2372     2814
  %
  % 10 is better than 25 on every benchmark level at once and detects the
  % 1 degree boundaries on level 2 that 25 missed. 5 splits more twins still
  % but starts losing the 1 degree boundaries on level 1, which is the
  % capability this criterion exists for - use it when twins matter more.
  gammaW  = 10

  % report the coarsening hierarchy - one line per scale, plus what the
  % interpretation made of it - once the run has finished, see FMC_report.
  % Off by default: calcGrains is silent for every other criterion, and a
  % criterion that narrates itself is unusable inside anything that calls it
  % repeatedly, e.g. a parameter sweep or the benchmark.
  verbose = false

end

methods

  function obj = gbcFMC(varargin)
    if nargin >= 1 && isnumeric(varargin{1}) && ~isempty(varargin{1})
      obj.cmaha = varargin{1}(1);
    else
      obj.cmaha = get_option(varargin,{'fmc','cmaha'},obj.cmaha,'double');
    end
    obj.cmaha0  = get_option(varargin,{'cmaha0'}, obj.cmaha0, 'double');
    obj.quatmax = get_option(varargin,{'quatmax'},obj.quatmax,'double');
    obj.gammaW  = get_option(varargin,{'gammaW'}, obj.gammaW, 'double');
    obj.maxDelta= get_option(varargin,{'maxDelta'},obj.maxDelta,'double');
    obj.minPixel= get_option(varargin,{'minPixel'},obj.minPixel,'double');
    obj.alpha   = get_option(varargin,{'alpha'},  obj.alpha,  'double');
    obj.verbose = check_option(varargin,'verbose');
  end

  function tf = handlesMinPixel(obj) %#ok<MANU>
    % FMC absorbs undersized regions itself, in FMC_interpret, so
    % calcGrains must not also run its own minPixel pass - that pass is a
    % second complete FMC run, and it would find nothing left to remove.
    tf = true;
  end

  function obj = setMinPixel(obj,minPixel)
    obj.minPixel = minPixel;
  end

end

methods (Access = protected)

  function out = doEvaluate(obj,ebsd,i,j)

    % One clustering per indexed phase, on the pixels of that phase alone.
    %
    % A phase boundary is a grain boundary whatever the orientations on
    % either side happen to be, and the misorientation between them is not
    % even defined - the two lie in different symmetry groups. gbcAngle has
    % always compared within a phase for exactly that reason; FMC threw
    % every pixel into one graph and read the whole map with the symmetry of
    % the first indexed phase, so on a multi phase map it could grow one
    % aggregate across a phase boundary.
    %
    % Clustering the phases separately, rather than merely cutting the
    % edges between them, is what gets the symmetry right - and it costs
    % nothing, since the phases partition the pixels.

    out   = zeros(size(i));
    phase = ebsd.phaseId;

    for p = ebsd.indexedPhasesId

      pair = phase(i) == p & phase(j) == p;
      if ~any(pair), continue; end

      isP = phase == p;

      % pixel id -> position within this phase
      loc = zeros(length(ebsd),1);
      loc(isP) = 1:nnz(isP);

      ip = loc(i(pair));
      jp = loc(j(pair));

      label = obj.clusterPhase(ebsd,isP,ip,jp,ebsd.CSList(p));

      out(pair) = double(label(ip) == label(jp) & label(ip) > 0);

    end

    out = reshape(out,size(i));
  end

  function label = clusterPhase(obj,ebsd,isP,i,j,CS)
    % run FMC on the pixels isP of one phase, over the pair list (i,j)

    % Cast to double once, here. Several interfaces store rotations and
    % coordinates in SINGLE - mtexdata martensite does - and single spreads:
    % quaternion/double only stacks the components, it does not convert them,
    % so the misorientations, the edge weights and the moment sums all stay
    % single. sparse() then rejects its value vector outright, which is where
    % this used to die, and accumarray would be next. Converting at the entry
    % is the only place the fix belongs; doing it per call site inside the
    % coarsening leaves the next single-valued expression to be found by the
    % next user.
    q = ebsd.rotations(isP);
    q = quaternion(double(q.a),double(q.b),double(q.c),double(q.d));
    N = length(q);

    A_D = sparse(double(i),double(j),true,N,N);

    fmc.CS = CS;
    fmc.O  = q;

    % pixel positions, so the aggregate statistics can tell a smoothly
    % deformed grain from a noisy one. Without usable coordinates the
    % linear model degenerates to the constant one, which is the old
    % behaviour, so this stays optional rather than being a requirement.
    pos = double([reshape(ebsd.x(isP),[],1) reshape(ebsd.y(isP),[],1)]);
    if numel(pos) ~= 2*N || ~all(isfinite(pos(:)))
      pos = zeros(N,2);
    end
    fmc.pos = pos;

    % per aggregate moment sums [Sxx Sxy Syy Sxv(3) Syv(3) Stt], carried up
    % the hierarchy so that a linear orientation field can be fitted to
    % every pixel underneath an aggregate rather than to its handful of
    % direct members, and the gradient fitted from them. A single pixel has
    % no spread, so both start at zero.
    fmc.M = zeros(N,10);
    fmc.QvarTot = zeros(N,1);
    fmc.G = zeros(N,6);

    fmc.cmaha    = obj.cmaha;
    fmc.cmaha0   = obj.cmaha0;
    fmc.quatmax  = obj.quatmax;
    fmc.quatmax2 = cos(obj.quatmax/2*degree);
    fmc.gammaW   = obj.gammaW;
    fmc.maxDelta = obj.maxDelta;
    fmc.alpha    = obj.alpha;
    fmc.A_D      = A_D;

    [AllPs,AllSals,numClusters,W0,rep] = FMC_MTEX(fmc);
    [assignments,rep2] = FMC_interpret(AllSals, numClusters, AllPs, A_D, obj.minPixel, W0);

    if obj.verbose, FMC_report(obj,CS.mineral,numClusters,rep,rep2); end

    label = assignments(:,1);
  end

end

end