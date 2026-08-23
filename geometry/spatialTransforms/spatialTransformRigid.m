classdef spatialTransformRigid < spatialTransform
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

  properties
    u = vector3d(0,0,0)
  end

  methods

    function T = spatialTransformRigid(u)

      if nargin == 0, return; end

      assert(isa(u,'vector3d') && isscalar(u),'MTEX:spatialTransform:notAVector',...
        'A rigid transform is given by one @vector3d displacement.');

      T.u = u;

    end

    function pos = eval(T,pos)
      pos.x = pos.x + T.u.x;
      pos.y = pos.y + T.u.y;
    end

    function T = inv(T)
      T.u = -T.u;
    end

    function tf = isid(T)
      tf = norm(T.u) < 1e-12;
    end

    function T = absorb(T1,T2)

      T = absorb@spatialTransform(T1,T2);
      if ~isempty(T), return; end

      if isa(T2,'spatialTransformRigid')
        T = spatialTransformRigid(T1.u + T2.u);
      end

    end

    function s = char(T)
      s = sprintf('rigid  (%.4g, %.4g)',T.u.x,T.u.y);
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

      w = max(real(w),0);
      if sum(w) == 0, w = ones(size(w)); end

      T = spatialTransformRigid(vector3d(...
        sum(w.*dx)/sum(w), sum(w.*dy)/sum(w), 0));

    end

  end

end
