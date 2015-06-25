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
    
    function q = smooth(F,q)
      
      % project to tangential space
      tq = log(q);

      tq1 = reshape(tq(:,1),size(q));
      tq2 = reshape(tq(:,2),size(q));
      tq3 = reshape(tq(:,3),size(q));

      % perform smoothing
      if F.robust
        [tq,F.alpha] = smoothn({tq1,tq2,tq3},F.alpha,'robust');
      else
        [tq,F.alpha] = smoothn({tq1,tq2,tq3},F.alpha);
      end
      
      % project back to orientation space
      q = reshape(expquat(vector3d(tq{:})),size(q));
    end
  end
end
  
  
  
