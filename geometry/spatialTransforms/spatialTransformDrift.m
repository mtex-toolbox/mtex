classdef spatialTransformDrift < spatialTransform
% a displacement that varies only along the slow scan direction
%
% Temporal drift during a scan: the beam returns to the start of each line
% at a stage position slightly different from the last, so the whole line
% is displaced together and the displacement accumulates down the scan.
% Modelled as a linear spline in the slow scan coordinate alone - a
% rolling shutter, not a smooth field.
%
% Which direction is the slow scan is a fact about the acquisition, not
% about the data, so it is carried rather than inferred. After resampling
% or rotation it is no longer grid dimension 1.
%
% The spline is defined between its outermost knots and NOT beyond, so
% positions outside the measured band come back NaN rather than
% extrapolated. That is deliberate - it is what marks the region the
% correction is supported on. Pass 'extrapolate' to continue the end
% segments instead.
%
% Syntax
%
%   T = spatialTransformDrift(s,u)
%   T = spatialTransformDrift(s,u,'slowScan',xvector)
%   T = spatialTransformDrift.fit(posA,posB)
%   T = spatialTransformDrift.fit(posA,posB,'slowScan',xvector,'extrapolate')
%
% Input
%  s          - n x 1 knot coordinates along the slow scan direction
%  u          - n x 2 displacement at each knot
%  posA, posB - @vector3d, the same points in the two frames
%
% Output
%  T - @spatialTransformDrift
%
% Class Properties
%  s           - n x 1 knots, ascending
%  u           - n x 2 displacement at the knots
%  slowScan    - @vector3d, the direction the spline runs along
%  extrapolate - continue the end segments instead of returning NaN
%
% See also
% spatialTransform spatialTransformField

  properties
    s = zeros(0,1)
    u = zeros(0,2)
    slowScan = vector3d(0,1,0)
    extrapolate = false
  end

  methods

    function T = spatialTransformDrift(s,u,varargin)

      if nargin == 0, return; end

      s = s(:);
      assert(isequal(size(u),[numel(s) 2]),'MTEX:spatialTransform:badKnots',...
        'Expected %d x 2 displacements to go with %d knots, got %s.',...
        numel(s),numel(s),mat2str(size(u)));

      [T.s,ord] = sort(s);
      T.u = u(ord,:);

      sc = get_option(varargin,'slowScan',T.slowScan);
      T.slowScan = normalize(sc);

      T.extrapolate = check_option(varargin,'extrapolate');

    end

    function pos = eval(T,pos)

      if isempty(T.s), return; end

      t = dot(pos,T.slowScan);

      % one knot is a constant offset, which interp1 will not do
      if isscalar(T.s)
        pos.x = pos.x + T.u(1,1); pos.y = pos.y + T.u(1,2);
        return
      end

      if T.extrapolate
        d = interp1(T.s,T.u,t(:),'linear','extrap');
      else
        d = interp1(T.s,T.u,t(:),'linear');
      end

      pos.x = pos.x + reshape(d(:,1),size(pos.x));
      pos.y = pos.y + reshape(d(:,2),size(pos.y));

    end

    function T = inv(T)
      T = spatialTransformInverse(T);
    end

    function tf = isid(T)
      tf = isempty(T.s) || norm(T.u,'fro') < 1e-12;
    end

    function s = paramChar(T)
      if isempty(T.s), s = '(no knots)'; return; end
      s = sprintf('%d knots over %.4g .. %.4g, |u| <= %.4g',...
        numel(T.s),T.s(1),T.s(end),max(hypot(T.u(:,1),T.u(:,2))));
    end

    function s = char(T)
      s = ['drift  ' paramChar(T)];
    end

  end

  methods (Static = true)

    function T = fit(posA,posB,varargin)
      % a linear spline through the per line median displacement
      %
      % The median rather than the mean: a line crossing a badly correlated
      % patch should not be pulled by it, and with one number per line
      % there is no room for a weighted fit to outvote anything.
      %
      % Syntax
      %   T = spatialTransformDrift.fit(posA,posB)
      %   T = spatialTransformDrift.fit(posA,posB,'slowScan',xvector)

      [dx,dy,~,x,y] = transformFitData(posA,posB,varargin{:});

      sc = normalize(get_option(varargin,'slowScan',vector3d(0,1,0)));
      t = dot(vector3d(x,y,zeros(size(x))),sc);

      % points sharing a scan line share a slow coordinate, to rounding
      span = max(t(:)) - min(t(:));
      [knots,~,grp] = uniquetol(t(:),1e-10,'DataScale',max(1,span));

      u = [accumarray(grp,dx,[],@median), accumarray(grp,dy,[],@median)];

      T = spatialTransformDrift(knots,u,varargin{:});

    end

  end

end
