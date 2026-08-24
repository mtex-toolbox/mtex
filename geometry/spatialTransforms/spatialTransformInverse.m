classdef spatialTransformInverse < spatialTransform
% the inverse of a transform that has no closed form one
%
% A polynomial, a spline or a scattered field maps position to position
% perfectly well but cannot be solved backwards in closed form. Since the
% displacement is smooth by construction - it was fitted through a smooth
% basis - the inverse is reached by iterating
%
%   q <- p - u(q),   u(q) = eval(T,q) - q
%
% which converges geometrically as long as the displacement gradient is
% below one, i.e. as long as the field does not fold. A field that does
% fold has no inverse to find and the iteration is refused rather than
% returning a wrong answer.
%
% inv of this returns the original transform, so a round trip costs nothing.
%
% Syntax
%
%   Tinv = inv(T)                          % how one is normally made
%   Tinv = spatialTransformInverse(T)
%   Tinv = spatialTransformInverse(T,'tol',1e-10,'iterMax',100)
%
% Input
%  T - @spatialTransform, the forward map
%
% Output
%  Tinv - @spatialTransformInverse
%
% Class Properties
%  T       - the forward transform
%  tol     - convergence tolerance, relative to the coordinate scale
%  iterMax - iteration budget
%
% See also
% spatialTransform spatialTransformField spatialTransform

  properties
    T
    tol = 1e-10
    iterMax = 100
  end

  methods

    function Ti = spatialTransformInverse(T,varargin)

      assert(nargin >= 1 && isa(T,'spatialTransform'),...
        'MTEX:spatialTransform:notATransform',...
        'The inverse wraps a spatial transform.');

      Ti.T = T;
      Ti.tol = get_option(varargin,'tol',Ti.tol);
      Ti.iterMax = get_option(varargin,'iterMax',Ti.iterMax);

    end

    function pos = eval(Ti,pos)

      target = pos;
      scale = max(1,max(abs([pos.x(:); pos.y(:)]),[],'omitnan'));

      resid = inf; prev = inf;

      for iter = 1:Ti.iterMax

        moved = eval(Ti.T,pos);

        ex = moved.x - target.x;
        ey = moved.y - target.y;

        pos.x = pos.x - ex;
        pos.y = pos.y - ey;

        resid = max(hypot(ex(:),ey(:)),[],'omitnan');
        if resid <= Ti.tol * scale, break; end

        % a diverging or stalled iterate means the field folds, and no
        % number of further steps will find a preimage
        if iter > 3 && resid > 0.9 * prev, break; end
        prev = resid;

      end

      assert(resid <= Ti.tol * scale,'MTEX:spatialTransform:notInvertible',...
        ['The displacement field did not invert - it stalled at %g after '...
        '%d iterations, against a tolerance of %g. Either it folds, which '...
        'means some positions have no preimage, or it is being asked for '...
        'preimages well outside the region it was fitted on.'],...
        resid,iter,Ti.tol*scale);

    end

    function T = inv(Ti)
      T = Ti.T;
    end

    function tf = isid(Ti)
      tf = isid(Ti.T);
    end

    function s = shortChar(Ti)
      s = ['inv-' shortChar(Ti.T)];
    end

    function s = paramChar(Ti)
      % the parameters are the forward transform's - this class has none
      s = paramChar(Ti.T);
    end

    function s = char(Ti)
      s = ['inverse of  ' char(Ti.T)];
    end

  end

end
