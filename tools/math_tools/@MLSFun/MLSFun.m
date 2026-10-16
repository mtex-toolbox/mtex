classdef (Abstract) MLSFun
% moving least squares approximation of scattered data on a manifold
%
% MLSFun holds what S2FunMLS and SO3FunMLS have in common. A function is
% stored by its nodes and values and is evaluated by moving least squares:
% at every evaluation point a small weighted least squares problem over a
% local polynomial ansatz space is solved, using only the nodes in a
% compactly supported neighborhood of that point.
%
% A derived class supplies the domain through the hidden hook methods
% declared below - its dimension, the basis, the local coordinates and the
% grids - and inherits everything else. The options are documented in the
% derived classes.
%
% See also
% S2FunMLS SO3FunMLS solve_lsq_book_constsize solve_lsq_book_varsize

properties
  nodes = []                 % points where the function values are known
  values = []                % function values, one row per node
  vor_weights = []           % Voronoi cell sizes of the nodes
  use_vor_weights = true     % multiply the local weights by vor_weights?
  degree = []                % polynomial degree
  oF = []                    % oversampling factor (nn / dim)
  oF_max = []                % upper bound for oF in range search
  delta = []                 % support radius; zero activates KNN search
  use_smooth_delta = true    % use a smooth local support radius?
  candidateFactor = 2        % KNN candidates per center as a multiple of nn
  w = []                     % compactly supported weight function
  monomials = true           % use the monomial basis?
  centered = true            % local coordinates centered at the evaluation point?
  tangent = false            % ignore the radial coordinate of the monomials?
  regularize = true          % use goal-oriented regularization?
  mincond = []               % start threshold for normalized center amplification
  maxcond = []               % full threshold for normalized center amplification
  targetcond = []            % full-strength target; one is the limiting minimum
  detectOutliers = false     % reduce the weight of detected outliers?
  outlierDetectionRange = 10 % neighbors used for outlier detection
  outlierIndicators = []     % bigger numbers (one per node) indicate outliers
  subsample = false          % perform optimal subsampling?
  auxgrid = []               % equispaced grid used only for smooth delta
end

properties (Dependent = true)
  dim                        % dimension of the ansatz space
  nn                         % number of neighbors
  antipodal                  % inherited from the nodes
  isReal                     % = isreal(values)
  fill_distance              % fill distance of the nodes
  separation_distance        % separation distance of the nodes
end

properties (Constant = true, Hidden = true)
  supportMargin = 1.10       % the support reaches slightly beyond the farthest neighbor
  candidateTol = 1e-4        % relative weight from which a KNN candidate counts
end

properties (Abstract = true, Constant = true, Hidden = true)
  domainDim                  % dimension of the domain, 2 on S2 and 3 on SO(3)
end

methods (Abstract = true, Hidden = true)
  vals = evalBasis(F,pts)                         % basis values, one row per point
  [pts,radial] = basisPoints(F,centers,cId,gId)   % neighbors as the basis sees them
  pts = localOrigin(F)                            % the center in local coordinates
  f = ballFraction(F,r)                           % share of the domain in a ball of radius r
  pts = uniformGrid(F,n)                          % about n evenly spread points
  pts = randomPoints(F,n,stream)                  % n uniformly distributed random points
  vw = voronoiWeights(F,nodes)                    % Voronoi cell sizes
  key = symmetryKey(F)                            % what the baseline depends on besides the basis
  name = basisName(F)                             % basis name for display
  h = toHandle(F)                                 % the function as a handle function
  fd = fillDistance(F)                            % fill distance of the nodes
end

methods (Hidden = true)

  function nodes = prepareNodes(~,nodes,varargin)
    % nodes as given to the constructor, overloaded by SO3FunMLS
  end

  function nodes = indexNodes(~,nodes)
    % search structures for the nodes, overloaded by S2FunMLS
  end

  function [F,v] = prepareEval(F,v)
    % evaluation points as eval needs them, overloaded by SO3FunMLS
  end

  function F = init(F,nodes,values,varargin)
    % the part of the constructor all MLS functions share

    isGrid = isa(nodes,'fibonacciS2Grid') || isa(nodes,'SO3Grid');
    nodes = F.prepareNodes(nodes,varargin{:});

    % MLS needs distinct nodes, a grid has them by construction
    if ~isGrid && numel(unique(nodes,'stable','tolerance',.001*degree)) < numel(nodes)
      nodes = nodes(:);
      values = reshape(values,numel(nodes),[]);
      [nodes,values] = uniqueData(nodes,values,'mean','tolerance',.001*degree);
      if ~getMTEXpref('generatingHelpMode')
        warning(['Some duplicate Nodes have been removed. ' ...
          'The remaining nodes have been reshaped into a vector.']);
      end
    end

    % nodes is stored as a column; the remaining dimensions belong to values
    if isrow(nodes), nodes = reshape(nodes,[],1); end
    F.nodes = F.indexNodes(nodes);

    F.use_vor_weights = get_option(varargin,'use_vor_weights',true);
    if F.use_vor_weights
      F.vor_weights = F.voronoiWeights(nodes);
    else
      F.vor_weights = ones(size(nodes));
    end

    % the first dimensions of values belong to the nodes, the others to the function
    sz = size(values);
    id = find(cumprod(sz) == numel(nodes),1);
    F.values = reshape(values,[numel(nodes) sz(id+1:end) 1]);

    % regularization flag and center-amplification parameters
    F.regularize = get_option(varargin,{'regularize','regularization'},true,'logical');
    F.mincond = get_option(varargin, ...
      {'mincond','min cond','min_cond','min amplification'},[]);
    F.maxcond = get_option(varargin, ...
      {'maxcond','max cond','max_cond','max amplification'},[]);
    targetcond = get_option(varargin,{'targetcond','target cond','target_cond', ...
      'target amplification','targetamp'},[]);
    if ~isempty(targetcond), F.targetcond = targetcond; end

    % degree, oversampling factor, and support radius
    F.degree = get_option(varargin,{'degree','deg'},4,'double');
    F.oF = get_option(varargin,{'oF','of','OF','oversamplingfactor', ...
      'oversampling_factor','oversampling factor'},4,'double');
    % half of the domain should already contain sufficiently many nodes
    if F.nn > numel(F.nodes) / 2
      error('Too few data points for the specified degree and oversampling factor.');
    end
    F.oF_max = get_option(varargin,{'ofmax','of max','max of','maxof', ...
      'maximal oversampling factor','max oversampling factor'},2*F.oF,'double');
    F.delta = get_option(varargin,{'delta','range','support radius'},0,'double');

    F.w = get_option(varargin,'weight','wendland',{'string','function_handle','char'});

    % basis options; an odd degree, regularize and tangent need centered coordinates
    F.monomials = get_option(varargin,'monomials',true,'logical');
    F.tangent = get_option(varargin,'tangent',false,'logical');
    F.centered = get_option(varargin,'centered',true,'logical');
    if F.regularize, F.tangent = true; end
    if F.tangent, F.centered = true; end
    if F.centered, F.monomials = true; end

    F.detectOutliers = check_option(varargin, ...
      {'detect outliers','detectoutliers','detect_outliers'});
    F.outlierDetectionRange = round(get_option(varargin, ...
      {'outlierdetectionrange','outlier detection range','odr'}, ...
      F.outlierDetectionRange,'double'));
    if F.detectOutliers, F.outlierIndicators = computeOutlierIndicators(F); end

    % optimal subsampling minimizes the Lebesgue constant
    F.subsample = check_option(varargin,{'subsampling','subsample'});
    if F.subsample, F.centered = true; end

    F.use_smooth_delta = get_option(varargin,{'use_smooth_delta', ...
      'use smooth delta','smooth_delta','smooth delta'},true);
    F.candidateFactor = get_option(varargin,{'candidateFactor', ...
      'candidatefactor','candidate factor','candidate_factor'},2,'double');

    if F.use_smooth_delta && F.delta == 0, F = F.init_auxgrid; end
    if F.regularize && (isempty(F.mincond) || isempty(F.maxcond) || isempty(F.targetcond))
      F = F.init_reg_params;
    end

  end

  function d = distToNodes(F,pts)
    % distance of every point to its nearest node
    [~,d] = F.nodes.find(pts(:),1);
    d = reshape(d,size(pts));
  end

  [values,done] = valueOp(F1,F2,op)
  displayBody(F,name,header,varargin)

end

methods

  function F = set.w(F,weightfun)
    if isa(weightfun,'function_handle')
      F.w = weightfun;
      return
    end

    % Wendland C6 in Horner form, it is evaluated once per center and neighbor
    wendlandC6 = @(t) max(1-t,0).^8 .* (((32*t + 25).*t + 8).*t + 1);

    switch lower(char(weightfun))
      case 'hat'
        F.w = @(t) max(1-t,0);
      case 'squared hat'
        F.w = @(t) max(1-t,0).^2;
      case {'indicator','const'}
        F.w = @(t) t <= 1;
      case 'cos'
        F.w = @(t) (1+cos(pi*t))/2 .* (t <= 1);
      case 'auto'
        % degree dependent localization: Wendland C6 at t^alpha, raised to beta
        alpha = max(1,2 - (F.degree - 1) / 3);
        beta = 1 + max(F.degree - 2,0) / 3;
        if alpha == 1
          F.w = @(t) wendlandC6(t).^beta;
        elseif beta == 1
          F.w = @(t) wendlandC6(t.^alpha);
        else
          F.w = @(t) wendlandC6(t.^alpha).^beta;
        end
      case 'plateau'
        % constant on the inner 60 percent of the support, then a C1 taper to zero
        plateauTaper = @(x) x.^2 .* (3 - 2*x);
        F.w = @(t) 1 - plateauTaper(min(max((t - 0.6)/0.4,0),1));
      case 'c1hat'
        F.w = @(t) max(1-t.^2,0).^2;
      case 'wendland'
        F.w = @(t) max(1-t,0).^4 .* (4*t+1);
      case 'wendlandc6'
        F.w = wendlandC6;
      case 'wendlandsquared'
        F.w = @(t) (max(1-t,0).^4 .* (4*t+1)).^2;
      case 'wendlandc6squared'
        F.w = @(t) wendlandC6(t).^2;
      otherwise
        error('Unknown MLS weight function.');
    end
  end

  function d = get.dim(F)
    d = nchoosek(F.degree + F.domainDim,F.domainDim);
  end

  function nn = get.nn(F)
    nn = ceil(F.dim * F.oF);
  end

  function ap = get.antipodal(F)
    ap = F.nodes.antipodal;
  end

  function F = set.antipodal(F,value)
    F.nodes.antipodal = value;
    F.nodes = F.indexNodes(F.nodes);
  end

  function out = get.isReal(F)
    out = isreal(F.values);
  end

  function F = set.isReal(F,value)
    if value, F.values = real(F.values); end
  end

  function F = set.degree(F,deg)
    firstCall = isempty(F.degree);
    F.degree = deg;
    if deg == 0, F.regularize = false; end
    if mod(deg,2) == 1, F.centered = true; end
    if ~firstCall && ~isempty(F.auxgrid), F = F.update_auxgrid_dn; end
  end

  function F = set.centered(F,value)
    % an odd basis changes sign between q and -q, only centered coordinates fix it
    F.centered = value || (~isempty(F.degree) && mod(F.degree,2) == 1);
  end

  function F = set.tangent(F,value)
    % tangent monomials require centered coordinates
    F.tangent = value;
    if value, F.centered = true; end
  end

  function F = set.subsample(F,value)
    % linprog needs a real sampling matrix, i.e. monomials
    F.subsample = value;
    if value, F.monomials = true; end
  end

  function F = set.detectOutliers(F,value)
    F.detectOutliers = value;
    % at least the dimension of the linear functions the indicators use
    if value
      F.outlierDetectionRange = max(round(F.dim * .7),F.domainDim + 1);
    end
  end

  function F = set.oF(F,value)
    firstCall = isempty(F.oF);
    if value < 1
      warning('Oversampling factor was too small and has been set to 2.');
      value = 2;
    end
    F.oF = value;
    if ~isempty(F.delta) && F.delta > 0
      warning('The support radius delta has been adapted to the new oversampling factor.');
      F.delta = F.compute_delta;
    end
    F.oF_max = 2 * F.oF;
    if ~firstCall && ~isempty(F.auxgrid), F = F.update_auxgrid_dn; end
  end

  function F = set.candidateFactor(F,value)
    if value < 1
      warning(['The candidate buffer cannot be smaller than the ' ...
        'neighborhood and has been set to 1.']);
      value = 1;
    end
    F.candidateFactor = value;
  end

  function F = set.mincond(F,value)
    % assigning mincond also sets the target; assign targetcond afterwards to differ
    F.mincond = value;
    F.targetcond = value;
  end

  function fd = get.fill_distance(F)
    fd = F.fillDistance;
  end

  function sd = get.separation_distance(F)
    [~,d] = F.nodes.find(F.nodes,2);
    sd = min(d(:,2));
  end

  function d = compute_delta(F)
    % support radius that holds nn nodes when the nodes are uniformly distributed
    target = F.nn / numel(F.nodes);
    lower = 0;
    upper = pi;
    for k = 1:60
      middle = (lower + upper) / 2;
      if F.ballFraction(middle) < target
        lower = middle;
      else
        upper = middle;
      end
    end
    d = (lower + upper) / 2;
  end

  function reg_params = show_reg_params(F)
    % the calibrated goal-oriented regularization parameters
    reg_params = struct;
    reg_params.mincond = F.mincond;
    reg_params.maxcond = F.maxcond;
    reg_params.targetcond = F.targetcond;
    reg_params.numericalCondMax = 1e10;
    reg_params.degreeExponent = 1;
    reg_params.degreeLaplaceShift = F.domainDim - 1;
  end

  function F = init_auxgrid(F)
    % the auxiliary grid and the distance to the nn-th node, for smoothing delta
    [nAux,auxInfo] = F.estimate_auxgrid_points;
    F.auxgrid = F.uniformGrid(nAux);

    % diagnostics are stored on the grid itself
    F.auxgrid.opt.requestedPoints = nAux;
    F.auxgrid.opt.denseSupportRadius = auxInfo.denseSupportRadius;
    F.auxgrid.opt.densityContrast = auxInfo.densityContrast;

    F = F.update_auxgrid_dn;
  end

  function [nAux,info] = estimate_auxgrid_points(F)
    % auxiliary grid size from the smallest robust local support
    N = numel(F.nodes);
    nfind = min(F.nn,N - 1);

    % probe at data nodes, the densely sampled regions need the finest resolution
    probeId = unique(round(linspace(1,N,min(N,2000)))).';

    % the first neighbor is the query node itself
    [~,dProbe] = F.nodes.find(F.nodes.subSet(probeId),nfind + 1);

    % a robust dense-region radius instead of the absolute minimum
    denseSupportRadius = getQuantile(dProbe(:,end),.01);
    domainFraction = min(max(F.ballFraction(denseSupportRadius),realmin),1);

    % the degree-zero helper MLS uses oF = 20, resolve about that many
    % auxiliary nodes inside the smallest robust data support
    nAux = ceil(20 / domainFraction);

    % round up for reproducible grid sizes and apply practical bounds
    nAux = 1000 * ceil(nAux / 1000);
    nAux = min(max(nAux,10000),200000);

    info = struct;
    info.denseSupportRadius = denseSupportRadius;
    % density contrast relative to a uniform node set with the same nfind
    info.densityContrast = (nfind / N) / domainFraction;
  end

  function F = update_auxgrid_dn(F)
    if isempty(F.auxgrid), return; end
    [~,dn] = F.nodes.find(F.auxgrid,min(F.nn,numel(F.nodes)));
    F.auxgrid.opt.dn = dn(:,end);
  end

  function chi0 = baseline_amplification(F)
    % the center amplification of a perfectly distributed node cloud, cached

    persistent cache
    if isempty(cache), cache = containers.Map; end

    key = sprintf('%d|%d|%g|%s|%d%d%d|%s',F.domainDim,F.degree,F.oF, ...
      func2str(F.w),F.centered,F.tangent,F.monomials,F.symmetryKey);
    if isKey(cache,key)
      chi0 = cache(key);
      return
    end

    ref = F;
    if ~isscalar(ref), ref = ref.subSet(1); end
    ref.regularize = false;
    ref.subsample = false;
    ref.detectOutliers = false;
    ref.outlierIndicators = [];

    % the baseline does not depend on the nodes, so the reference grid is small
    ref.use_vor_weights = false;
    ref.use_smooth_delta = false;
    ref.delta = 0;
    ref.auxgrid = [];

    refNodes = reshape(F.uniformGrid(max(4000,8*F.nn)),[],1);
    refNodes.antipodal = F.antipodal;
    ref.nodes = F.indexNodes(refNodes);
    ref.values = zeros(numel(refNodes),1);
    ref.vor_weights = ones(numel(refNodes),1);

    % on well-distributed nodes the amplification is almost constant, so a
    % few hundred centers resolve its median well within one percent
    stream = RandStream('mt19937ar','Seed',1741 + 97*F.degree);
    [~,~,info,~] = ref.eval(F.randomPoints(250,stream));

    amp = real(info.centerAmplification(:));
    amp = amp(isfinite(amp) & amp >= 1);
    if isempty(amp)
      chi0 = 1;
    else
      chi0 = max(getQuantile(amp,.5),1);
    end

    cache(key) = chi0;
  end

  function nn = guess_nn(F,varargin)
    % expected number of neighbors in range search
    %
    % Syntax
    %   nn = guess_nn(F)        % mean
    %   nn = guess_nn(F,'min')  % minimum
    %   nn = guess_nn(F,'max')  % maximum

    if F.delta == 0
      nn = F.nn;
      warning(['Calling this function only makes sense if range-search is activated. ' ...
        'You can achieve this for example via F.delta = F.compute_delta. ' ...
        'I just returned F.nn for now.']);
      return
    end

    nns = F.count_neighbors(F.uniformGrid(10000));
    if check_option(varargin,'min')
      nn = full(min(nns));
    elseif check_option(varargin,'max')
      nn = full(max(nns));
    else
      nn = ceil(mean(nns));
    end
  end

  function nns = count_neighbors(F,v)
    % number of nodes within delta of every point, e.g. to find bad regions
    if F.delta == 0
      nns = repmat(F.nn,size(v));
      warning(['Calling this function only makes sense if range-search is activated. ' ...
        'You can achieve this for example via F.delta = F.compute_delta. ' ...
        'I just returned F.nn for now.']);
      return
    end
    nns = full(sum(F.nodes.find(v,F.delta),2));
  end

  function n = numArgumentsFromSubscript(varargin)
    % subsref returns one object
    n = 0;
  end

end

end
