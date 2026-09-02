classdef spatialTransformShift < spatialTransform
% a 2D affine transform, stored as a homogeneous matrix
%
% Translation, rotation, scale and shear together - six parameters, the
% most general transform that keeps straight lines straight and parallel
% lines parallel. In an EBSD setting this is the DC field shift between two
% detectors or two beam energies.
%
% The identity is eye(3), and two affines compose to a third, so a chain of
% them never grows into a composite.
%
% Syntax
%
%   T = spatialTransformShift              % the identity
%   T = spatialTransformShift(M)           % from a homogeneous matrix
%   T = spatialTransformShift.fit(posA,posB)
%   T = spatialTransformShift.fit(posA,posB,'weights',w)
%
% Input
%  M          - 3x3 double, last row [0 0 1]
%  posA, posB - @vector3d, the same points in the two frames
%  w          - double, one weight per point
%
% Output
%  T - @spatialTransformShift
%
% Class Properties
%  M - 3x3 homogeneous matrix, acting on [x; y; 1]
%
% See also
% spatialTransform spatialTransformId

  properties
    M = eye(3)
  end

  methods

    function T = spatialTransformShift(M)

      if nargin == 0, return; end

      assert(isequal(size(M),[3 3]), 'MTEX:spatialTransform:badMatrix',...
        'An affine transform is given by a 3x3 homogeneous matrix.');

      assert(norm(M(3,:) - [0 0 1]) < 1e-12, 'MTEX:spatialTransform:notAffine',...
        ['The last row of an affine homogeneous matrix is [0 0 1]. A '...
        'projective transform is spatialTransformTilt.']);

      T.M = M;

    end

    function pos = eval(T,pos)

      % both coordinates read the old x and y, so compute before assigning
      x = T.M(1,1)*pos.x + T.M(1,2)*pos.y + T.M(1,3);
      y = T.M(2,1)*pos.x + T.M(2,2)*pos.y + T.M(2,3);
      pos.x = x; pos.y = y;

    end

    function T = inv(T)
      T.M = inv(T.M);
    end

    function tf = isid(T)
      tf = norm(T.M - eye(3),'fro') < 1e-12;
    end

    function H = matrix(T)
      H = T.M;
    end

    function s = paramChar(T)
      % what the affine does, which its matrix does not say
      %
      % Six numbers in two rows are not readable as a distortion, and the
      % four that matter are all near their identity value, where a rotation
      % of a hundredth of a degree and one of ten degrees look alike. The QR
      % factors are what a registration is judged on instead.

      [sx,sy,rot,shear] = parts(T);

      s = sprintf('scale %.4g × %.4g, rotate %.3g°, shear %.3g°, move (%.4g, %.4g)',...
        sx,sy,rot,shear,T.M(1,3),T.M(2,3));

    end

  end

  methods (Access = private)

    function [sx,sy,rot,shear] = parts(T)
      % the affine as rotation, scale and shear, from its QR factors
      %
      % M = Q*R with R upper triangular: Q is the rotation, the diagonal of
      % R the scale along each axis and R(1,2) the shear of x with y. A
      % mirrored transform has no rotation of its own, so its flip is
      % carried by a negative y scale.

      [Q,R] = qr(T.M(1:2,1:2));

      % qr fixes neither the sign of a column nor which factor carries it
      d = sign(diag(R)); d(d == 0) = 1;
      Q = Q .* d.'; R = d .* R;

      if det(Q) < 0, Q(:,2) = -Q(:,2); R(2,:) = -R(2,:); end

      sx = R(1,1); sy = R(2,2);
      rot = atan2d(Q(2,1),Q(1,1));
      shear = atand(R(1,2)/R(2,2));

      % below this an angle is rounding noise out of qr and not a
      % distortion - and a signed zero prints as -0
      rot(abs(rot) < 1e-9) = 0;
      shear(abs(shear) < 1e-9) = 0;

    end

  end

  methods (Static = true)

    function T = fit(posA,posB,varargin)
      % the affine best mapping posA onto posB
      %
      % Syntax
      %   T = spatialTransformShift.fit(posA,posB)
      %   T = spatialTransformShift.fit(posA,posB,'weights',w)
      %
      % Input
      %  posA, posB - @vector3d, the same points in the two frames
      %  w          - double, one weight per point
      %
      % Output
      %  T - @spatialTransformShift
      %
      % See also
      % spatialTransformShift spatialTransformPoly/fit

      % a degree one polynomial displacement is an affine, and this one is the
      % plain weighted least squares fit
      T = shiftMatrix(spatialTransformPoly.fit(posA,posB,varargin{:},'degree',1,'noRobust'));

    end

  end

end
