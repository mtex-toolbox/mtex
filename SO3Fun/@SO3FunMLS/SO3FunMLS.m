classdef SO3FunMLS < SO3Fun & MLSFun
  % A class representing a function on the rotation group SO(3).
  %
  % The function is not stored by coefficients, but by nodes and values. It is
  % evaluated by a moving least squares approximation: at every evaluation
  % point a small weighted least squares problem over a local polynomial
  % ansatz space is solved, using only the nodes in a compactly supported
  % neighborhood of that point.
  %
  % Syntax
  %   SO3F = SO3FunMLS(nodes, values);
  %   SO3F = SO3FunMLS(nodes, values, CS, SS);
  %   SO3F = SO3FunMLS(nodes, values, 'degree', 3, 'oF', 4);
  %   SO3F = SO3FunMLS(nodes, values, 'delta', 5*degree, 'weight', @(t)(...));
  %   SO3F = SO3FunMLS(nodes, values, 'centered', true, ...
  %     'subsample', 'tangent', true);
  %   SO3F = SO3FunMLS(nodes, values, 'detectOutliers', ...
  %     'use_vor_weights', 'use_smooth_delta');
  %
  % Input
  %  nodes  - @orientation, @rotation (data points)
  %  values - array of function values assigned to the nodes
  %  CS, SS - @crystalSymmetry, @specimenSymmetry, replace those of the nodes
  %
  % Output
  %  SO3F - @SO3FunMLS
  %
  % Options
  %  SRight, SLeft - symmetries that replace those of the nodes
  %
  %  degree  - polynomial degree used for approximation
  %  oF      - oversampling factor; nn is SO3F.dim times this factor
  %  oF_max  - maximal oversampling factor for range search
  %  delta   - support radius of the weight function; delta = 0 uses KNN
  %
  %  centered  - evaluate the basis in local coordinates around the identity
  %  tangent   - use monomials on the tangent space (requires centered = true)
  %    (NOTE: an odd degree, regularize and tangent enable centered; tangent
  %     ignores the local a-coordinate of the neighbors)
  %
  %  weight  - @function_handle (weight function)
  %          - predefined choices are 'wendland' (default, Wendland C2), 'auto' (a
  %            degree-dependent Wendland C6 variant), 'C1hat', 'const', 'cos',
  %            'hat', 'indicator', 'plateau', 'squared hat', 'wendlandC6',
  %            'wendlandSquared', and 'wendlandC6Squared'
  %  use_smooth_delta - use a smooth local support radius with about SO3F.nn
  %                     neighbors at each center
  %  candidateFactor  - KNN candidates fetched per center as a multiple of nn
  %                     (default 2, only used with use_smooth_delta)
  %  use_vor_weights  - multiply the local weights by Voronoi volumes,
  %                     as in 'Stable Moving Least Squares Approximation'
  %
  %  regularize - use goal-oriented regularization of the local systems
  %               automatically enables tangent monomials for every degree
  %  mincond    - center-amplification threshold where regularization starts
  %  maxcond    - center-amplification threshold where full correction is used
  %  targetcond - inverse-amplification bound at full correction;
  %               one is the minimum-norm constant-preserving limit
  %    (mincond, maxcond and targetcond bound the center amplification, not
  %     the condition number of the Gram matrix)
  %
  %  outlierDetectionRange - number of neighbors used for outlier detection
  %
  % Flags
  %  detectOutliers - detect local outliers and reduce their MLS weights
  %  subsample      - select a subset that minimizes the Lebesgue constant
  %
  % Description
  % The ansatz of degree L consists of the monomials of the degrees L, L-2,
  % ... on the unit quaternions, i.e. of one parity. The monomial basis is
  % the only one on SO(3).
  %
  % See also
  % S2FunMLS SO3FunHarmonic SO3FunRBF SO3FunMLS/eval SO3FunMLS/approximate

  properties
    bandwidth = getMTEXpref('maxSO3Bandwidth')
  end

  properties (Dependent = true)
    SLeft                 % left symmetry of the nodes
    SRight                % right symmetry of the nodes
  end

  properties (Constant = true, Hidden = true)
    domainDim = 3
  end

  methods

    function SO3F = SO3FunMLS(nodes, values, varargin)

      if nargin == 0, return; end

      % convert arbitrary SO3Fun to SO3FunMLS
      if isa(nodes,'function_handle') || isa(nodes,'SO3Fun')
        if nargin == 1, values = []; end
        SO3F = SO3FunMLS.approximate(nodes,values,varargin{:});
        return
      end

      SO3F = SO3F.init(nodes,values,varargin{:});
    end

    function SO3F = set.SRight(SO3F,S)
      SO3F.nodes.CS = S;
    end

    function S = get.SRight(SO3F)
      S = SO3F.nodes.CS;
    end

    function SO3F = set.SLeft(SO3F,S)
      SO3F.nodes.SS = S;
    end

    function S = get.SLeft(SO3F)
      S = SO3F.nodes.SS;
    end

  end

  methods (Hidden = true)

    function ori = prepareNodes(~,ori,varargin)
      % orientations with the symmetries given to the constructor
      if isa(ori,'rotation'), ori = orientation(ori); end

      names = {{'SRight','rightSymmetry','right symmetry','cs'}, ...
        {'SLeft','leftSymmetry','left symmetry','ss'}};
      right = get_option(varargin,names{1},[]);
      left = get_option(varargin,names{2},[]);
      [CS,SS] = extractSym(delete_option(varargin,[names{:}],1),'empty');
      if isempty(right), right = CS; end
      if isempty(left), left = SS; end

      if ~isempty(right), ori.CS = right; end
      if ~isempty(left), ori.SS = left; end
    end

    function [SO3F,ori] = prepareEval(SO3F,ori)
      % orientations with proper symmetry groups, at most one of them
      % nontrivial, and no antipodal flag; what is dropped becomes copies of
      % the nodes
      if ~isa(ori,'orientation'), ori = orientation(ori,SO3F.CS,SO3F.SS); end

      SO3F.CS = SO3F.CS.properGroup;
      SO3F.SS = SO3F.SS.properGroup;
      ori.CS = ori.CS.properGroup;
      ori.SS = ori.SS.properGroup;

      % the projection to the center knows no inversion, so add the inverted nodes
      if SO3F.antipodal
        nodes = SO3F.nodes(:);
        inverted = inv(nodes);
        inverted.CS = nodes.CS;
        inverted.SS = nodes.SS;
        SO3F.nodes = [nodes; inverted];
        SO3F.antipodal = false;
        SO3F.values = [SO3F.values; SO3F.values];
        SO3F.vor_weights = [SO3F.vor_weights(:); SO3F.vor_weights(:)];
        SO3F.outlierIndicators = [SO3F.outlierIndicators; SO3F.outlierIndicators];
        ori.antipodal = false;
      end

      % fold the smaller of two nontrivial symmetries into the nodes
      cs = ori.CS;
      ss = ori.SS;
      if cs.id == 1 || ss.id == 1, return; end

      if length(cs.rot) >= length(ss.rot)
        SO3F.nodes = ss * SO3F.nodes;
        expand = @(x) kron(x,ones(numSym(ss),1));
        SO3F.SS = specimenSymmetry.default;
        ori.SS = specimenSymmetry.default;
      else
        SO3F.nodes = SO3F.nodes * cs;
        expand = @(x) repmat(x,numSym(cs),1);
        SO3F.CS = specimenSymmetry.default;
        ori.CS = specimenSymmetry.default;
      end
      SO3F.values = expand(SO3F.values);
      SO3F.vor_weights = expand(SO3F.vor_weights);
      if ~isempty(SO3F.outlierIndicators)
        SO3F.outlierIndicators = expand(SO3F.outlierIndicators);
      end

      if SO3F.use_smooth_delta && SO3F.delta == 0
        SO3F = SO3F.init_auxgrid;
      end
    end

    function vals = evalBasis(SO3F,ori)
      vals = evalMonomialsSO3(ori,SO3F.degree,SO3F.tangent);
    end

    function [ori,a] = basisPoints(SO3F,centers,centerId,gridId)
      % the neighbors next to their center, multiplied by its inverse if centered
      ori = project2FundamentalRegion(SO3F.nodes.subSet(gridId),centers.subSet(centerId));
      a = [];
      if SO3F.centered
        invCenters = inv(centers);
        ori = reshape(invCenters.subSet(centerId),size(ori)) .* ori;
        a = ori.a;
      end
    end

    function ori = localOrigin(~)
      ori = orientation.id;
    end

    function f = ballFraction(SO3F,r)
      % volume share of a ball of rotation angle r in the fundamental region
      phi = r / 2;
      f = numProper(SO3F.SLeft) * numProper(SO3F.SRight) * ...
        (2 / pi * (phi - sin(phi) * cos(phi)));
    end

    function ori = uniformGrid(SO3F,n)
      ori = equispacedSO3Grid(SO3F.CS,SO3F.SS,'points',n);
    end

    function ori = randomPoints(SO3F,n,stream)
      % normalized Gaussians are uniformly distributed on S^3
      q = randn(stream,n,4);
      q = q ./ sqrt(sum(q.^2,2));
      ori = orientation(q(:,1),q(:,2),q(:,3),q(:,4),SO3F.SRight,SO3F.SLeft);
    end

    function vw = voronoiWeights(~,nodes)
      vw = nodes.calcVoronoiVolume;
    end

    function key = symmetryKey(SO3F)
      key = sprintf('%d|%d|%d',SO3F.SLeft.id,SO3F.SRight.id,SO3F.antipodal);
    end

    function name = basisName(~)
      name = 'monomials';
    end

    function SO3F = toHandle(SO3F)
      SO3F = SO3FunHandle(SO3F);
    end

    function fd = fillDistance(SO3F)
      f = SO3FunHandle(@(r) SO3F.distToNodes(r),SO3F.CS,SO3F.SS);
      fd = max(max(f,'accuracy',0.25*degree,'numLocal',20,'resolution',3*degree));
    end

  end

  methods (Static = true)
    SO3F = interpolate(varargin);
    SO3F = approximate(f, varargin);
    SO3F = example(varargin)
  end

end
