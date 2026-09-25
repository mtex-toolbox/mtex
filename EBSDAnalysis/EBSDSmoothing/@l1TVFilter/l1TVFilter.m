classdef l1TVFilter < EBSDFilter
  % smoothes quaternions by projecting them into tangential space and
  % performing there smoothing spline approximation
  %
  % The total variation penalty keeps sharp steps, so unlike a spline or
  % halfquadratic filter this one does not smear a subgrain boundary out.
  % The price is a cyclic proximal point iteration, which makes it the
  % slowest of the @EBSDFilter.
  %
  % Syntax
  %   F = l1TVFilter
  %   F = l1TVFilter(alpha)
  %   ebsd = smooth(ebsd,F)
  %
  % Input
  %  alpha - regularization parameter, larger means smoother
  %
  % Output
  %  F - @l1TVFilter
  %
  % Class Properties
  %  alpha  - regularization parameter
  %  maxit  - maximum number of iterations
  %  lambda - step sizes of the proximal point iteration
  %
  % See also
  % EBSDFilter EBSD/smooth
  %

  properties
    alpha = 0.4  % regularization parameter
    maxit = 1000; % maximum number of iterations
    lambda       % 
  end
  
  methods
    
    function F = l1TVFilter(alpha)
      if nargin > 0, F.alpha = alpha;end
      F.lambda = 2.8*(1:10000).^(-1.2);
    end
    
    function ori = smooth(F,ori,~)

      % the equivalents nearest the mean, as n x m x 4 unit quaternions: past this
      % the neighbours of a grain need no symmetry
      [~,q] = mean(ori);
      qIn = cat(3,q.a,q.b,q.c,q.d);

      % perform cyclic proximal point algorithm
      isOut = isnan(qIn(:,:,1));
      m = mean(reshape(qIn(~isOut(:,:,[1 1 1 1])),[],4),1);
      qOut = qIn;
      qOut(isOut(:,:,[1 1 1 1])) = repmat(m ./ norm(m),nnz(isOut),1);

      for k = 1:F.maxit
       
        if F.isHex
          qOut = proxTVhex(qOut, F.lambda(k), F.alpha);
        else
          qOut = proxTVSquare(qOut, F.lambda(k), F.alpha);
          %qOut = proxLaplace(qOut, F.lambda(k) *  F.alpha);
        end
        
        qOut = proxl1(qOut, qIn, F.lambda(k));
        %qOut = proxl2(qOut, qIn, F.lambda(k));
        
      end
                        
      % project back to orientation space
      ori = orientation(quaternion(qOut(:,:,1),qOut(:,:,2),qOut(:,:,3),qOut(:,:,4)),ori.CS,ori.SS);
        
    end
    
  end
  
end