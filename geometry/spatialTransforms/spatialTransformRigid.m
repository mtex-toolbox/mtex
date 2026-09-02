classdef spatialTransformRigid < spatialTransformShift
% one displacement, the same everywhere
%
% The whole frame moved and nothing within it changed shape. Fitted as the
% weighted mean of the measured displacements, so a tile that correlated
% weakly counts for little.
%
% Syntax
%
%   T = spatialTransformRigid(u)
%   T = spatialTransformRigid.fit(posA,posB)
%   T = spatialTransformRigid.fit(posA,posB,'weights',w)
%
% Input
%  u          - @vector3d, the displacement
%  posA, posB - @vector3d, the same points in the two frames
%  w          - double, one weight per point
%
% Output
%  T - @spatialTransformRigid
%
% Class Properties
%  u - @vector3d, the displacement added to every position
%
% See also
% spatialTransform spatialTransformShift

  properties (Dependent = true)
    u
  end

  methods

    function T = spatialTransformRigid(u)

      if nargin == 0, return; end

      assert(isa(u,'vector3d') && isscalar(u),'MTEX:spatialTransform:notAVector',...
        'A rigid transform is given by one @vector3d displacement.');

      T.M(1:2,3) = [u.x; u.y];

    end

    function u = get.u(T)
      u = vector3d(T.M(1,3),T.M(2,3),0);
    end

    function s = paramChar(T)
      s = sprintf('move (%.4g, %.4g)',T.M(1,3),T.M(2,3));
    end

  end

  methods (Static = true)

    function T = fit(posA,posB,varargin)
      % the weighted mean displacement from posA to posB
      %
      % Syntax
      %   T = spatialTransformRigid.fit(posA,posB)
      %   T = spatialTransformRigid.fit(posA,posB,'weights',w)

      [dx,dy,w] = transformFitData(posA,posB,varargin{:});

      T = spatialTransformRigid(vector3d(...
        sum(w.*dx)/sum(w), sum(w.*dy)/sum(w), 0));

    end

  end

end
