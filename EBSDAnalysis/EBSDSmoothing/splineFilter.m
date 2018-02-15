classdef splineFilter < EBSDFilter
  % smoothes quaternions by projecting them into tangential space and
  % performing there smoothing spline approximation
  
  properties
    alpha = [] % smoothing parameter
    robust = true % robust smoothing
  end
  
  methods
    
    function F = splineFiler(alpha,robust)
      if nargin > 0, F.alpha = alpha;end
      if nargin > 1, F.robust = robust; end
    end
    
    function ori = smooth(F,ori)

      % project to tangential space
      [qmean,q] = mean(ori);
      tq = log(q,quaternion(qmean));      

      % perform smoothing
      if F.robust, rob = {'robust'}; else, rob = {}; end
      [tq,F.alpha] = smoothn({tq.x,tq.y,tq.z},F.alpha,rob{:});
            
      % project back to orientation space
      ori = orientation(expquat(vector3d(tq{:}),quaternion(qmean)),ori.CS,ori.SS);
    end
  end
end
