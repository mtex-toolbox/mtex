classdef halfQuadraticFilter < EBSDFilter
  % haldQuadraticFilter uses the techniques elaborated half-quadratic
  % minmization on manifolds to denoise EBSD data.
  % For further details of the algorithm see:
  % R. Bergmann, R. H. Chan, R. Hielscher, J. Persch, G. Steidl
  % Restoration of Manifold-Valued Images by Half-Quadratic Minimization.
  % Preprint, ArXiv #1505.07029. (2015)
  % 
  
  properties
    alpha = 0.04;         % regularization parameter
    eps   = 1e-3;         % parameter for the weight function
    tol   = 0.01*degree   % tolerance for gradient descent
    threshold = 15*degree % threshold for subgrain boundaries
    iterMax = 1000;       % maximum number of iterations
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
      
      % the regulaisation parameter
      alpha = 4 * F.alpha / size(idNeighbours,3); %#ok<*PROPLC>
      
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
          t = angle(u,n);
          w = (1+4*quality(idNeighbours(:,:,j))-quality)./5;
          w = alpha * w .* (t <= F.threshold) ./ sqrt(t.^2+F.eps^2);
          w(isnan(w)) = 0;
        
          % update gradient
          g = g + w .* log(n,u,'nan2zero');
          
          % update step length
          lambda = lambda + w;
          
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