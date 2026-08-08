classdef laplaceFilter < boundaryFilter
% constrained Laplacian smoothing of grain boundaries
%
% Description
% Replaces every vertex by a weighted mean of itself and its neighbours, a
% fixed number of times. This is what grain2d/smoothBoundary has always done
% and it stays the default.
%
% Note that a Laplacian is a low pass filter with gain |1-lambda*k|, so it
% shrinks: every iteration pulls a convex region inwards, without bound. Use
% <taubinFilter.taubinFilter.html |taubinFilter|> when that matters. Note also
% that |iter| is not a physical quantity - how far a boundary is smoothed
% depends on how densely it is sampled, so the same call on the same sample
% measured at a finer step size does something different. Use
% <curvatureFilter.curvatureFilter.html |curvatureFilter|> when that matters.
%
% The averaging includes the vertex itself with the weight of its own degree,
% which is how the adjacency comes out of the vertex - segment incidence
% matrix. For a vertex with two neighbours the mean is therefore
% |(2*V + Vl + Vr)/4|, so |lambda| is applied to half the normalized Laplacian
% - the default |lambda = 0.5| is in truth a rate of 0.25. The variational
% filters use the normalized Laplacian itself, so their parameters are not
% comparable to this one.
%
% Syntax
%
%   grains = smoothBoundary(grains,5)          % the default, iter = 5
%
%   F = laplaceFilter;
%   F.iter = 10;
%   F.weight = 'gauss';
%   grains = smoothBoundary(grains,F)
%
% Class Properties
%  iter        - number of iterations (default: 1)
%  lambda      - step size (default: 0.5)
%  weight      - 'rate', 'gauss', 'exp' or 'umbrella'
%  secondOrder - average over the neighbours of the neighbours as well
%
% See also
% grain2d/smoothBoundary boundaryFilter taubinFilter curvatureFilter

properties
  iter = 1             % number of iterations
  lambda = 0.5         % step size
  weight = 'rate'      % 'rate', 'gauss', 'exp' or 'umbrella'
  secondOrder = false  % include the neighbours of the neighbours
end

methods

  function F = laplaceFilter(varargin)

    if nargin > 0 && isnumeric(varargin{1}) && ~isempty(varargin{1})
      F.iter = varargin{1};
    end

    F.weight = get_flag(varargin,{'gauss','expotential','exp','umbrella','rate'},'rate');

    % the kernel name doubles as the name of its parameter, so it may or may
    % not be followed by a value - insisting on a numeric one keeps a
    % following flag from being read as the step size, which used to make
    % smoothBoundary(grains,5,'gauss','moveTriplePoints') throw
    F.lambda = get_option(varargin,F.weight,0.5,'double');
    F.secondOrder = check_option(varargin,{'second order','second_order','S','S2'});

  end

  function V = smooth(F,V,A_V,isFixed,~)

    t = size(A_V,1);

    if F.secondOrder
      A_V = logical(A_V + A_V*A_V);
      A_V = A_V - diag(diag(A_V));
    end

    lambda = F.lambda; %#ok<PROPLC>

    isNotZero = ~all(~isfinite(V) | V == 0,2) & ~isFixed;

    for l=1:F.iter
      if ~strcmpi(F.weight,'rate')
        [i,j] = find(A_V);
        d = sqrt(sum((V(i,:)-V(j,:)).^2,2)); % distance
        switch F.weight
          case 'umbrella'
            w = 1./(d);
            w(d==0) = 1;
          case 'gauss'
            w = exp(-(d./lambda).^2); %#ok<PROPLC>
          case {'expotential','exp'}
            w = lambda*exp(-lambda*d); %#ok<PROPLC>
        end

        A_V = sparse(i,j,w,t,t);
      end

      % take the mean over the neighbors
      Vt = A_V * V;

      m = sum(A_V,2);

      dV = V(isNotZero,:)-bsxfun(@rdivide,Vt(isNotZero,:),m(isNotZero,:));

      isZero = any(~isfinite(dV),2);
      dV(isZero,:) = 0;

      V(isNotZero,:) = V(isNotZero,:) - lambda*dV; %#ok<PROPLC>

    end

  end

end

end
