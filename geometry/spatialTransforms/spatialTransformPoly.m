classdef spatialTransformPoly < spatialTransform
% a displacement that varies polynomially across the frame
%
% Degree 1 is an affine and could equally be a
% <spatialTransformShift.html |spatialTransformShift|>
% - inv converts to one, since a matrix has an exact inverse where a
% polynomial does not. Degree 2 is what mops up the residual curvature a
% projective stage leaves behind.
%
% The coefficients describe the DISPLACEMENT, not the mapped position, so
% the identity is c = 0.
%
% Syntax
%
%   T = spatialTransformPoly(c,degree)
%   T = spatialTransformPoly.fit(posA,posB,'degree',2)
%   T = spatialTransformPoly.fit(posA,posB,'degree',2,'weights',w)
%
% Input
%  c          - m × 2 coefficients, one column per displacement component
%  degree     - 1 or 2
%  posA, posB - @vector3d, the same points in the two frames
%  w          - double, one weight per point
%
% Output
%  T - @spatialTransformPoly
%
% Class Properties
%  c      - m x 2 coefficients against [1 x y] or [1 x y x^2 xy y^2]
%  degree - 1 or 2
%
% See also
% spatialTransform spatialTransformShift spatialTransformTilt

  properties
    c = zeros(3,2)
    degree = 1
  end

  methods

    function T = spatialTransformPoly(c,degree)

      if nargin == 0, return; end

      if nargin < 2, degree = 1 + (size(c,1) > 3); end

      m = size(polyBasis(0,0,degree),2);

      assert(isequal(size(c),[m 2]),'MTEX:spatialTransform:badCoefficients',...
        'A degree %d polynomial displacement has %d × 2 coefficients, got %s.',...
        degree,m,mat2str(size(c)));

      T.c = c; T.degree = degree;

    end

    function pos = eval(T,pos)

      B = polyBasis(pos.x,pos.y,T.degree);

      % reshape back, since pos may be a matrix on a gridded map
      pos.x = pos.x + reshape(B*T.c(:,1),size(pos.x));
      pos.y = pos.y + reshape(B*T.c(:,2),size(pos.y));

    end

    function T = inv(T)

      if T.degree == 1
        T = inv(shiftMatrix(T));
      else
        T = spatialTransformInverse(T);
      end

    end

    function tf = isid(T)
      tf = norm(T.c,'fro') < 1e-12;
    end

    function S = shiftMatrix(T)
      % the same transform as an affine, which degree 1 always is

      assert(T.degree == 1,'MTEX:spatialTransform:notAffine',...
        'Only a degree 1 polynomial displacement is an affine.');

      S = spatialTransformShift([...
        T.c(2,1)+1, T.c(3,1),   T.c(1,1); ...
        T.c(2,2),   T.c(3,2)+1, T.c(1,2); ...
        0,          0,          1]);

    end

    function s = shortChar(T)
      s = sprintf('poly%d%d',T.degree,T.degree);
    end

    function s = paramChar(T)
      s = sprintf('|c| = %.4g',norm(T.c,'fro'));
    end

    function opt = fitOptions(T)
      opt = {'degree',T.degree};
    end

  end

  methods (Static = true)

    function T = fit(posA,posB,varargin)
      % the polynomial displacement best mapping posA onto posB
      %
      % Syntax
      %   T = spatialTransformPoly.fit(posA,posB,'degree',2)
      %   T = spatialTransformPoly.fit(posA,posB,'degree',2,'weights',w)

      degree = get_option(varargin,'degree',1);

      [dx,dy,w,x,y] = transformFitData(posA,posB,varargin{:});

      B = polyBasis(x,y,degree);

      assert(size(B,1) >= size(B,2),'MTEX:spatialTransform:tooFewPoints',...
        'A degree %d polynomial needs at least %d points, got %d.',...
        degree,size(B,2),size(B,1));

      T = spatialTransformPoly(robustLsq(B,[dx dy],w,varargin{:}),degree);

    end

  end

end
