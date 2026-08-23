classdef splineFilter < EBSDFilter
  % smoothes quaternions by projecting them into tangential space and
  % performing there smoothing spline approximation
  %
  % The MTEX default filter. With alpha empty the smoothing parameter is
  % chosen by generalized cross validation, which is why it needs no tuning
  % in most cases. Not yet fully supported on hexagonal grids.
  %
  % Syntax
  %   F = splineFilter
  %   F = splineFilter(alpha)
  %   ebsd = smooth(ebsd,F)
  %
  % Input
  %  alpha  - smoothing parameter, empty means choose it automatically
  %  robust - down weight outliers, true by default
  %
  % Class Properties
  %  alpha        - smoothing parameter
  %  robust       - robust smoothing
  %  useEmbedding - smooth the isometric embedding instead of the tangent space
  %  isHex        - is the map on a hexagonal grid
  %
  % See also
  % EBSDFilter EBSD/smooth halfQuadraticFilter
  %
  
  properties
    alpha = []    % smoothing parameter
    robust = true % robust smoothing
    useEmbedding = false
  end
  
  methods
    
    function F = splineFilter(alpha,robust)
      if nargin > 0, F.alpha = alpha;end
      if nargin > 1, F.robust = robust; end
      
      addlistener(F,'isHex','PostSet',@check);
      function check(varargin)
        if F.isHex
          warning(['Hexagonal grids are not yet fully supportet for the splineFilter. ' ...
            'It might give reasonable results anyway']);
        end
      end
      
    end
    
    function ori = smooth(F,ori,quality)

      ori(quality==0) = nan;
      if F.robust, rob = {'robust'}; else, rob = {}; end
      
      if F.useEmbedding
      
        % compute isometric embedding
        e = embedding(ori);
      
        % convert to double
        d = reshape(double(e),size(ori,1),size(ori,2),[]);
      
        % perform smoothing
        [d,F.alpha] = smoothn({d(:,:,1),d(:,:,2),d(:,:,3),d(:,:,4),d(:,:,5),d(:,:,6),d(:,:,7),d(:,:,8),d(:,:,9)},F.alpha,rob{:});
            
        % revert to embedding object
        e = setDouble(e,cat(3,d{:}));

        % project back to orientation space
        ori = orientation(e);

      else

        % project to tangential space
        [qmean,q] = mean(ori);
        tq = logRight(quaternion(q),quaternion(qmean));

        % perform smoothing
        [tq,F.alpha] = smoothn({tq.x,tq.y,tq.z},F.alpha,rob{:});
            
        % project back to orientation space
        ori = orientation(expquat(vector3d(tq{:}),quaternion(qmean),'right'),ori.CS,ori.SS);
      end
    end
    
  end
end
