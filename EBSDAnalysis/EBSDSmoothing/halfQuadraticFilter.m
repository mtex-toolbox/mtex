classdef halfQuadraticFilter < EBSDFilter
  % haldQuadraticFilter uses the techniques elaborated half-quadratic
  % minmization on manifolds
  % to smooth EBSD data.
  % Properties:   alpha:  regularisation parameter in [x,y] direction
  %               weight: function handle specified by the regularising
  %                       function \varphi, @(t,eps), where eps is its
  %                       parameter
  %               eps:    Parameter for the weight
  %               tol:    Tolerance for the gradient descent
  %               threshold: threshold for subgrain boundaries
  % Methods:      smooth: Applies the HQ minimization on the quaternions
  %                       of the given orientations
  %
  % For further details of the algorithm see:
  % R. Bergmann, R. H. Chan, R. Hielscher, J. Persch, G. Steidl
  % Restoration of Manifold-Valued Images by Half-Quadratic Minimization.
  % Preprint, ArXiv #1505.07029. (2015)
  %
  %
  
  properties
    alpha = 0.04;                      % regularization parameter
    weight = @(t,eps,th) (t<=th)./(t.^2+eps^2).^(1/2); % weight function handle b^*(t,epsilon)
    eps = 1e-3;                             % parameter for the weight function
    tol = 0.01*degree                        % tolerance for gradient descent
    threshold = 15*degree                   % threshold for subgrain boundaries
    iterMax = 1000;
  end
  
  methods
    
    function ori = smooth(F,ori,quality)
      
      
      if nargin == 2, quality = ones(size(ori)); end
      
      % precompute neigbour ids
      if F.isHex
        idNeighbours = hexNeighbors(size(ori));
      else
        idNeighbours = squareNeighbors(size(ori));
      end
      
      % project around center
      [~,q] = mean(ori);
      
      % initial guess
      u = q;
      
      iter = 1;
      while iter==1 || (iter < F.iterMax && max(max(abs(g)))>F.tol)
                
        % init gradient
        g = quality .* log(q,u);
        
        % init step length
        lambda = quality;
        
        for j = 1:size(idNeighbours,3) % for all neighbours
                 
          % extract neighbouring quaternions
          n = u(idNeighbours(:,:,j));
          
          % compute weights to the neighboring pixels
          w = (1+4*quality(idNeighbours(:,:,j))-quality)./5 .* ...
            F.weight(angle(u,n),F.eps,F.threshold);
          w(isnan(w)) = 0;
        
          % update gradient
          g = g + F.alpha * w .* log(n,u,'nan2zero');
          
          % update step length
          lambda = lambda + F.alpha * w;
          
        end
        
        % the final gradient
        lambda(lambda==0) = inf;
        g = g ./ lambda;
        
        % update u
        u = expquat(g,u);
                
        iter = iter + 1;
      end
      
      ori = orientation(u,ori.CS,ori.SS);
    end
    
  end
  
end