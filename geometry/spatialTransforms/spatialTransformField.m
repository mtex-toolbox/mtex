classdef spatialTransformField < spatialTransform
% a displacement measured at scattered points and interpolated between them
%
% The free form transform: no model, just where things moved. Used to mop
% up whatever structure a fitted model leaves in its residual, and as the
% common currency any chain can be collapsed into by
% <spatialTransform.discretize.html |discretize|>.
%
% The sample points need not lie on a grid and the query points need not
% either, so a field fitted on one data set can be evaluated on another.
% Interpolation is natural neighbour, extrapolation linear.
%
% Coordinates are normalised before interpolating, because natural
% neighbour weights come from a Delaunay triangulation and that is not
% scale invariant - a frame far wider than it is tall would otherwise get
% sliver triangles. The displacements themselves need no normalising: the
% weights do not depend on them.
%
% Syntax
%
%   T = spatialTransformField(pos,u)
%   T = spatialTransformField.fit(posA,posB)
%
% Input
%  pos        - @vector3d, where the displacement was measured
%  u          - @vector3d, the displacement there
%  posA, posB - @vector3d, the same points in the two frames
%
% Output
%  T - @spatialTransformField
%
% There is deliberately no smooth: tools/math_tools/smoothn is for gridded
% data, and applying it to scattered samples in storage order smooths along
% the index rather than across the frame, which collapses the field to its
% mean. Smoothing a scattered field needs a regularised scattered fit.
%
% Class Properties
%  pos - @vector3d, the sample points
%  u   - @vector3d, the displacement at each
%
% See also
% spatialTransform spatialTransform/discretize spatialTransformDrift

  properties
    pos = vector3d.empty
    u = vector3d.empty
  end

  methods

    function T = spatialTransformField(pos,u)

      if nargin == 0, return; end

      assert(isa(pos,'vector3d') && isa(u,'vector3d'),...
        'MTEX:spatialTransform:notAVector',...
        'A field is given by two @vector3d, the points and the displacement.');

      assert(length(pos) == length(u),'MTEX:spatialTransform:sizeMismatch',...
        'Expected one displacement per point, got %d and %d.',...
        length(pos),length(u));

      T.pos = pos(:); T.u = u(:);

    end

    function pos = eval(T,pos)

      if isempty(T.pos), return; end

      [xs,ys,cx,cy,sx,sy] = normalized(T);

      F = scatteredInterpolant([xs,ys],T.u.x(:),'natural','linear');

      qx = (pos.x(:) - cx)./sx; qy = (pos.y(:) - cy)./sy;

      dx = F(qx,qy);
      F.Values = T.u.y(:);
      dy = F(qx,qy);

      pos.x = pos.x + reshape(dx,size(pos.x));
      pos.y = pos.y + reshape(dy,size(pos.y));

    end

    function T = inv(T)
      T = spatialTransformInverse(T);
    end

    function tf = isid(T)
      tf = isempty(T.pos) || max(norm(T.u)) < 1e-12;
    end

    function s = paramChar(T)
      if isempty(T.pos), s = '(empty)'; return; end
      s = sprintf('%d points, |u| <= %.4g',length(T.pos),max(norm(T.u)));
    end

    function s = char(T)
      s = ['field  ' paramChar(T)];
    end

  end

  methods (Access = private)

    function [xs,ys,cx,cy,sx,sy] = normalized(T)

      x = T.pos.x(:); y = T.pos.y(:);

      cx = mean(x); cy = mean(y);
      sx = std(x); sy = std(y);
      if sx < eps, sx = 1; end
      if sy < eps, sy = 1; end

      xs = (x - cx)./sx; ys = (y - cy)./sy;

    end

  end

  methods (Static = true)

    function T = fit(posA,posB,varargin)
      % the displacement from posA to posB, kept as measured
      %
      % There is nothing to fit - a field interpolates its samples exactly.
      % Points with a missing measurement are dropped, as for every other
      % class, so the same call works on the output of a failed correlation.

      [dx,dy,~,x,y] = transformFitData(posA,posB,varargin{:});

      z = zeros(size(x));
      T = spatialTransformField(vector3d(x,y,z),vector3d(dx,dy,z));

    end

  end

end
