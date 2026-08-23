classdef spatialTransformProjective < spatialTransform
% a projective transform, stored as a homography
%
% What a tilted specimen does to a map: the plane is seen obliquely, so
% straight lines stay straight but parallel ones need not, and the scale
% varies across the frame. Eight parameters, fitted by the direct linear
% transform and solved robustly.
%
% Unlike a polynomial this is a genuine geometric map, so its inverse is
% another homography rather than an iteration.
%
% Syntax
%
%   T = spatialTransformProjective(H)
%   T = spatialTransformProjective.fit(posA,posB)
%   T = spatialTransformProjective.fit(posA,posB,'weights',w)
%
% Input
%  H          - 3x3 homography, scaled so H(3,3) = 1
%  posA, posB - @vector3d, the same points in the two frames
%  w          - double, one weight per point
%
% Output
%  T - @spatialTransformProjective
%
% Class Properties
%  H - 3x3 homography acting on [x; y; 1], divided through by the third row
%
% See also
% spatialTransform spatialTransformShift spatialTransformTilt

  properties
    H = eye(3)
  end

  methods

    function T = spatialTransformProjective(H)

      if nargin == 0, return; end

      assert(isequal(size(H),[3 3]),'MTEX:spatialTransform:badMatrix',...
        'A projective transform is given by a 3x3 homography.');

      assert(abs(H(3,3)) > 1e-12,'MTEX:spatialTransform:badHomography',...
        'A homography with H(3,3) = 0 sends the origin to infinity.');

      T.H = H ./ H(3,3);

    end

    function pos = eval(T,pos)

      % the third homogeneous coordinate is what makes this projective
      % rather than affine, so it has to divide through
      d = T.H(3,1)*pos.x + T.H(3,2)*pos.y + T.H(3,3);

      x = (T.H(1,1)*pos.x + T.H(1,2)*pos.y + T.H(1,3)) ./ d;
      y = (T.H(2,1)*pos.x + T.H(2,2)*pos.y + T.H(2,3)) ./ d;

      pos.x = x; pos.y = y;

    end

    function T = inv(T)
      T = spatialTransformProjective(inv(T.H));
    end

    function tf = isid(T)
      tf = norm(T.H - eye(3),'fro') < 1e-12;
    end

    function T = absorb(T1,T2)

      T = absorb@spatialTransform(T1,T2);
      if ~isempty(T), return; end

      if isa(T2,'spatialTransformProjective')
        T = spatialTransformProjective(T1.H * T2.H);
      elseif isa(T2,'spatialTransformShift')
        T = spatialTransformProjective(T1.H * T2.M);
      end

    end

    function s = char(T)
      s = sprintf('projective  perspective (%.3g, %.3g)',T.H(3,1),T.H(3,2));
    end

  end

  methods (Static = true)

    function T = fit(posA,posB,varargin)
      % the homography best mapping posA onto posB, by the DLT
      %
      % Syntax
      %   T = spatialTransformProjective.fit(posA,posB)
      %   T = spatialTransformProjective.fit(posA,posB,'weights',w)

      [dx,dy,w,x,y] = transformFitData(posA,posB,varargin{:});

      assert(numel(x) >= 4,'MTEX:spatialTransform:tooFewPoints',...
        'A homography needs at least four points, got %d.',numel(x));

      xB = x + dx; yB = y + dy;

      o = ones(size(x)); z = zeros(size(x));

      % x' * (h31 x + h32 y + 1) = h11 x + h12 y + h13, and likewise for y',
      % stacked so both coordinates share one robust scale
      A = [x, y, o, z, z, z, -x.*xB, -y.*xB; ...
           z, z, z, x, y, o, -x.*yB, -y.*yB];

      h = robustLsq(A,[xB; yB],[w; w],varargin{:});

      T = spatialTransformProjective(reshape([h(:); 1],3,3).');

    end

  end

end
