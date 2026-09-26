classdef l1TVFilter < EBSDFilter
  % total variation denoising of orientation maps
  %
  % The filter minimises the distance to the measured orientations plus
  % alpha times the total variation, the sum of the misorientations between
  % neighbouring pixels. The absolute values keep sharp steps, so a subgrain
  % boundary survives the smoothing instead of being blurred away. The
  % default method is half-quadratic minimisation on manifolds:
  % R. Bergmann, R. H. Chan, R. Hielscher, J. Persch, G. Steidl,
  % Restoration of Manifold-Valued Images by Half-Quadratic Minimization,
  % Inverse Problems and Imaging 10 (2016). The method 'proximal' is a
  % cyclic proximal point algorithm for the same functional; it ignores the
  % threshold and the quality of the pixels.
  %
  % Syntax
  %   F = l1TVFilter
  %   F = l1TVFilter(smoothingLength)
  %   F.method = 'proximal';
  %   ebsd = smooth(ebsd,F)
  %
  % Input
  %  smoothingLength - the wavelength damped to half its amplitude, in the
  %  units of the map; four pixel distances when empty
  %
  % Class Properties
  %  smoothingLength - the wavelength damped to half its amplitude
  %  alpha     - regularization parameter, larger means smoother; empty
  %              means the one of the smoothing length
  %  method    - 'halfQuadratic' or 'proximal'
  %  l1DataFit - use the l1 norm for data fitting, else the l2 norm
  %  l1TV      - use the l1 norm for regularization, else the l2 norm
  %  iterMax   - maximum number of iterations
  %  tol       - stopping criterion of the half-quadratic iteration
  %  eps       - l1 relaxation parameter
  %  threshold - threshold for subgrain boundaries
  %  lambda    - step sizes of the proximal point iteration
  %  isHex     - is the map on a hexagonal grid
  %
  % See also
  % EBSDFilter EBSD/smooth splineFilter infimalConvolutionFilter
  %

  properties
    smoothingLength = []  % wavelength damped to half, in map units
    alpha = [];           % regularization parameter
    method = 'halfQuadratic' % or 'proximal'
    l1DataFit = true      % use l^1 norm for data fitting
    l1TV      = true      % use l^1 norm for regularization
    iterMax   = 1000;     % maximum number of iterations
    tol   = 0.001*degree  % stopping criteria for the gradient descent
    eps   = 1e-3;         % l^1 relaxation parameter
    threshold = 15*degree % threshold for subgrain boundaries
    lambda = 2.8*(1:10000).^(-1.2) % step sizes of the proximal point iteration
  end

  methods

    function F = l1TVFilter(smoothingLength)
      if nargin > 0, F.smoothingLength = smoothingLength; end
    end

    function ori = smooth(F,ori,quality)

      if nargin == 2, quality = ones(size(ori)); end
      quality = quality ./ max(quality(:));

      % the regularization parameter: the gain 1/(1+alpha*lambda) is one half at the
      % smoothing length, lambda the eigenvalue of the grid's Laplacian at that wavelength
      alpha = F.alpha;
      if isempty(alpha)
        L = F.smoothingLength;
        if isempty(L), L = 4*F.dx; end
        alpha = 1 / graphEigenvalue(F.isHex, max(L/F.dx,2));
      end

      % project around center, as n x m x 1 x 4 unit quaternions: past this the
      % neighbours of a grain need no symmetry
      [~,ori] = mean(ori);
      q = cat(4,ori.a,ori.b,ori.c,ori.d);

      if strcmpi(F.method,'proximal')
        u = proximal(F,q,alpha);
      else
        u = halfQuadratic(F,q,quality,alpha);
      end

      ori.a = u(:,:,1,1);
      ori.b = u(:,:,1,2);
      ori.c = u(:,:,1,3);
      ori.d = u(:,:,1,4);
    end

  end

  methods (Access = private)

    function u = halfQuadratic(F,q,quality,alpha)

      % precompute neighbor ids
      if F.isHex
        idNeighbours = hexNeighbors(size(q,[1 2]));
      else
        idNeighbours = squareNeighbors(size(q,[1 2]));
      end
      sz = size(q,[1 2]);
      k = size(idNeighbours,3);

      % initial guess
      u = q;

      iter = 1;
      step = inf;
      while iter==1 || (iter < F.iterMax && step > F.tol)

        % the neighbours in the right tangent space of u, whose norm is their angle
        n = reshape(u,[],4);
        n = logRight(reshape(n(idNeighbours(:),:),[sz k 4]),u);

        % multiplier for regularization gradient
        if F.l1TV
          t = sqrt(sum(n.^2,4));
          w = alpha * (t <= F.threshold) ./ sqrt(t.^2+F.eps^2);
          w(isnan(w)) = 0;
        else
          w = alpha * ~isnan(n(:,:,:,1));
        end
        n(isnan(n)) = 0;

        % multiplier for data fit gradient
        d = logRight(q,u);
        if F.l1DataFit
          w0 = quality ./ sqrt(sum(d.^2,4)+F.eps^2);
        else
          w0 = quality;
        end
        w0(isnan(w0)) = 0;

        % the gradient, and its step length
        lambda = w0 + sum(w,3);
        lambda(lambda==0) = inf;
        g = (w0 .* d + sum(w .* n,3)) ./ lambda;
        step = max(sqrt(sum(g.^2,4)),[],'all');

        % update u
        u = expRight(g,u);

        iter = iter + 1;
      end
    end

    function u = proximal(F,q,alpha)

      if ~F.l1DataFit || ~F.l1TV
        error('The proximal method minimises the l1 data fit and the l1 total variation only.');
      end

      % the cyclic proximal point iteration on n x m x 4 unit quaternions, the
      % pixels without a measurement started at the mean
      qIn = reshape(q,[size(q,[1 2]) 4]);
      isOut = isnan(qIn(:,:,1));
      m = mean(reshape(qIn(~isOut(:,:,[1 1 1 1])),[],4),1);
      u = qIn;
      u(isOut(:,:,[1 1 1 1])) = repmat(m ./ norm(m),nnz(isOut),1);

      for k = 1:F.iterMax
        if F.isHex
          u = proxTVhex(u, F.lambda(k), alpha);
        else
          u = proxTVSquare(u, F.lambda(k), alpha);
        end
        u = proxl1(u, qIn, F.lambda(k));
      end
      u = reshape(u,[size(u,[1 2]) 1 4]);
    end

  end

end


% the eigenvalue of the grid's Laplacian at a plane wave of L pixel distances along the
% grid's first direction, summed over the neighbours of a pixel
function lambda = graphEigenvalue(isHex,L)

if isHex, p = [1 -1 0.5 -0.5 0.5 -0.5]; else, p = [1 -1 0 0]; end
lambda = sum(1 - cos(2*pi*p/L));

end


% inv(r) .* p as a rotation vector, unit quaternions along the fourth dimension
function v = logRight(p,r)

a = r(:,:,:,1).*p(:,:,:,1) + sum(r(:,:,:,2:4).*p(:,:,:,2:4),4);
v = r(:,:,:,1).*p(:,:,:,2:4) - p(:,:,:,1).*r(:,:,:,2:4) - cross4(r(:,:,:,2:4),p(:,:,:,2:4));
s = sqrt(sum(v.^2,4));
omega = 2 * (1 - 2*(a < 0)) .* atan2(s,abs(a)) ./ s;
omega(s == 0) = 0;
v = omega .* v;

end


% r .* exp(v) for rotation vectors v
function r = expRight(v,r)

omega = sqrt(sum(v.^2,4));
s = sin(omega/2) ./ omega;
s(omega == 0) = 0;
e = cat(4,cos(omega/2),s .* v);
r = cat(4,r(:,:,:,1).*e(:,:,:,1) - sum(r(:,:,:,2:4).*e(:,:,:,2:4),4), ...
  r(:,:,:,1).*e(:,:,:,2:4) + e(:,:,:,1).*r(:,:,:,2:4) + cross4(r(:,:,:,2:4),e(:,:,:,2:4)));

end


% the cross product of vectors along the fourth dimension
function c = cross4(x,y)

c = cat(4,x(:,:,:,2).*y(:,:,:,3) - x(:,:,:,3).*y(:,:,:,2), ...
  x(:,:,:,3).*y(:,:,:,1) - x(:,:,:,1).*y(:,:,:,3), ...
  x(:,:,:,1).*y(:,:,:,2) - x(:,:,:,2).*y(:,:,:,1));

end
