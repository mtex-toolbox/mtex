classdef curvatureFilter < boundaryFilter
% smooth grain boundaries by a single variational solve
%
% Description
% Defines the smooth boundary as the minimizer of
%
%   |V - V0|^2 + alpha * |L V|^2
%
% where |L| is the normalized Laplacian of the boundary network, i.e. |L V|
% measures how far a vertex sits off the line through its neighbours. The
% first term keeps the result close to the measured boundary, the second one
% penalizes curvature, and |alpha| decides between them.
%
% There is no iteration count. The minimizer is the solution of one sparse
% linear system, so the result depends on |alpha| alone and not on how long
% the algorithm was run. Junctions are eliminated from that system rather than
% penalized, so they stay exactly where they are.
%
% |alpha| is not stated directly but through |smoothingLength|, a length in
% the units of the map. On a boundary sampled at spacing |h| the filter has
% gain |1/(1+4*alpha*sin(w/2)^4)| at the spatial frequency |w|, so it damps
% the wavelength
%
%   Lambda = pi*h / asin((4*alpha)^(-1/4))
%
% to half amplitude. |smoothingLength| is that wavelength - detail finer than
% it is removed, detail coarser than it survives. Being a length, it means the
% same thing whatever step size the map was measured at. It cannot be shorter
% than |2*h|, which is all the sampling can represent.
%
% Syntax
%
%   grains = smoothBoundary(grains,curvatureFilter)
%
%   F = curvatureFilter;
%   F.smoothingLength = 3;   % in the units of the map
%   grains = smoothBoundary(grains,F)
%
% Class Properties
%  smoothingLength - wavelength damped to half amplitude, in map units
%                    (default: 4 times the vertex spacing)
%  alpha           - the regularization weight itself; set it to override
%                    smoothingLength
%
% See also
% grain2d/smoothBoundary boundaryFilter laplaceFilter taubinFilter huberFilter

properties
  smoothingLength = []  % wavelength damped to half amplitude
  alpha = []            % regularization weight, overrides smoothingLength
end

methods

  function F = curvatureFilter(varargin)

    if nargin > 0 && isnumeric(varargin{1}) && ~isempty(varargin{1})
      F.smoothingLength = varargin{1};
    end

    F.smoothingLength = get_option(varargin,'smoothingLength',F.smoothingLength);
    F.alpha = get_option(varargin,'alpha',F.alpha);

  end

  function V = smooth(F,V,A_V,isFixed,h)

    alpha = F.weight(h); %#ok<PROPLC>
    if alpha <= 0, return; end %#ok<PROPLC>

    L = boundaryFilter.laplacian(A_V);

    M = speye(size(L,1)) + alpha * (L.' * L); %#ok<PROPLC>

    V = boundaryFilter.solveDirichlet(M,V,isFixed | ~isfinite(sum(V,2)));

  end

  function alpha = weight(F,h)
    % the regularization weight, from smoothingLength if it is not set directly

    if ~isempty(F.alpha)
      alpha = F.alpha;
      return
    end

    lambda = F.smoothingLength;
    if isempty(lambda), lambda = 4*h; end

    % Invert the gain 1/(1+4*alpha*sin(w/2)^4) = 1/2 at w = 2*pi*h/Lambda.
    % Solving it exactly rather than for small w matters at the short end -
    % the small angle form is 20% out already at Lambda = 4h.
    alpha = 1 / (4 * sin(pi*h/max(lambda,2*h))^4);

  end

end

end
