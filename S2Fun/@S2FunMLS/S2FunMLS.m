classdef S2FunMLS < S2Fun & MLSFun
  % A class representing a function on the 2-sphere S^2.
  %
  % The function is not stored by coefficients, but by nodes and values. It is
  % evaluated by a moving least squares approximation: at every evaluation
  % point a small weighted least squares problem over a local polynomial
  % ansatz space is solved, using only the nodes in a compactly supported
  % neighborhood of that point.
  %
  % Syntax
  %   S2F = S2FunMLS(nodes, values);
  %   S2F = S2FunMLS(nodes, values, 'degree', 3, 'oF', 4);
  %   S2F = S2FunMLS(nodes, values, 'delta', 5*degree, 'weight', @(t)(...));
  %   S2F = S2FunMLS(nodes, values, 'centered', true, 'monomials', true, ...
  %     'subsample', 'tangent', true);
  %   S2F = S2FunMLS(nodes, values, 'detectOutliers', ...
  %     'use_vor_weights', 'use_smooth_delta');
  %
  % Input
  %  nodes  - @vector3d (data points)
  %  values - array of function values assigned to the nodes
  %
  % Output
  %  S2F - @S2FunMLS
  %
  % Options
  %  degree  - polynomial degree used for approximation
  %  oF      - oversampling factor; nn is S2F.dim times this factor
  %  oF_max  - maximal oversampling factor for range search
  %  delta   - support radius of the weight function; delta = 0 uses KNN
  %
  %  monomials - use a monomial basis, otherwise spherical harmonics
  %  centered  - evaluate the basis in local coordinates around the north pole
  %  tangent   - use monomials on the tangent plane (requires centered = true)
  %    (NOTE: an odd degree, regularize and tangent enable centered, and
  %     centered enables the monomial basis)
  %
  %  weight  - @function_handle (weight function)
  %          - predefined choices are 'wendland' (default, Wendland C2), 'auto' (a
  %            degree-dependent Wendland C6 variant), 'C1hat', 'const', 'cos',
  %            'hat', 'indicator', 'plateau', 'squared hat', 'wendlandC6',
  %            'wendlandSquared', and 'wendlandC6Squared'
  %  use_smooth_delta - use a smooth local support radius with about S2F.nn
  %                     neighbors at each center
  %  candidateFactor  - KNN candidates fetched per center as a multiple of nn
  %                     (default 2, only used with use_smooth_delta)
  %  use_vor_weights  - multiply the local weights by Voronoi areas
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
  % The ansatz of degree L consists of the spherical harmonics of the degrees
  % L, L-2, ..., i.e. of one parity. The reference frame of the function is
  % the one of the nodes.
  %
  % See also
  % SO3FunMLS S2FunHarmonic S2FunTri S2FunMLS/eval S2FunMLS/approximate

  properties (Constant = true, Hidden = true)
    domainDim = 2
  end

  methods

    function S2F = S2FunMLS(nodes, values, varargin)

      if nargin == 0, return; end

      % convert arbitrary S2Fun to S2FunMLS
      if isa(nodes,'function_handle') || isa(nodes,'S2Fun')
        if nargin == 1, values = []; end
        S2F = S2FunMLS.approximate(nodes,values,varargin{:});
        return
      end

      S2F = S2F.init(nodes,values,varargin{:});
      S2F.frame = S2F.nodes.frame;
    end

  end

  methods (Hidden = true)

    function vals = evalBasis(S2F,v)
      if S2F.monomials
        vals = evalMonomialsS2(v,S2F.degree,S2F.tangent);
      else
        vals = evalSphericalHarmonics(v,S2F.degree);
      end
    end

    function [v,z] = basisPoints(S2F,centers,centerId,gridId)
      % the neighbors, rotated such that their center is the north pole if centered
      if S2F.centered
        [x,y,z] = localCoordinatesS2(centers,centerId,S2F.nodes,gridId);
        v = vector3d(x,y,z);
      else
        v = S2F.nodes.subSet(gridId);
        z = [];
      end
    end

    function v = localOrigin(~)
      v = vector3d.Z;
    end

    function f = ballFraction(S2F,r)
      % area share of a spherical cap with radius r; an antipodal node covers two
      f = (1 + S2F.antipodal) * ((1 - cos(r)) / 2);
    end

    function v = uniformGrid(S2F,n)
      v = S2F.indexNodes(fibonacciS2Grid(n));
    end

    function v = randomPoints(~,n,stream)
      z = 2 * rand(stream,n,1) - 1;
      phi = 2*pi * rand(stream,n,1);
      r = sqrt(max(1 - z.^2,0));
      v = vector3d(r .* cos(phi),r .* sin(phi),z);
    end

    function vw = voronoiWeights(~,nodes)
      vw = nodes.calcVoronoiArea;
    end

    function nodes = indexNodes(~,nodes)
      % a KD tree for vector3d/find, built on [nodes;-nodes] when antipodal
      xyz = nodes.xyz;
      if nodes.antipodal, xyz = [xyz;-xyz]; end
      if ~isfield(nodes.opt,'searcher') || size(nodes.opt.searcher.X,1) ~= size(xyz,1)
        nodes.opt.searcher = createns(xyz);
      end
    end

    function key = symmetryKey(S2F)
      key = sprintf('%d',S2F.antipodal);
    end

    function name = basisName(S2F)
      if S2F.monomials
        name = 'monomials';
      else
        name = 'spherical harmonics';
      end
    end

    function sF = toHandle(S2F)
      sF = S2FunHandle(@(v) S2F.eval(v),S2F.frame);
    end

    function fd = fillDistance(S2F)
      f = S2FunHandle(@(v) S2F.distToNodes(v));
      fd = max(max(f,'numLocal',20,'maxStepSize',1*degree));
    end

  end

  methods (Static = true)
    S2F = interpolate(varargin);
    S2F = approximate(f, varargin);
    S2F = example(varargin)
  end

end
