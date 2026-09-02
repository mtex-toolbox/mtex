classdef pairShifts
% the shifts one cross correlation pass measured between two images
%
% Syntax
%   ps = pairShifts(pos,u,peak,roiSize)
%   v = meanShift(ps,px)
%
% Input
%  pos     - @vector3d, the tile centres
%  u       - @vector3d, how far each tile of the test image has to move to
%            sit on the reference
%  peak    - the height of the correlation peak at each tile, which is the
%            weight of the measurement
%  roiSize - the tile size in pixels
%  px      - the pixel size, to state the shifts in pixels
%
% Output
%  v - [mean length, mean x, mean y] in pixels
%
% See also
% xcfShift trueEbsd/calcDistortion

  properties
    pos = vector3d   % default constructed, so that isempty answers
    u = vector3d
    peak = []
    roiSize = []
  end

  methods

    function ps = pairShifts(pos,u,peak,roiSize)

      if nargin == 0, return; end

      ps.pos = pos(:); ps.u = u(:); ps.peak = peak(:); ps.roiSize = roiSize;

    end

    function v = meanShift(ps,px)
      % the measured shifts as [mean length, mean x, mean y], in pixels

      x = ps.u.x / px; y = ps.u.y / px;
      ok = isfinite(x) & isfinite(y);

      if ~any(ok), v = [0 0 0]; return; end
      v = [mean(hypot(x(ok),y(ok))) mean(x(ok)) mean(y(ok))];

    end

  end

end
