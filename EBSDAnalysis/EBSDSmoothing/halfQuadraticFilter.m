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
    l1DataFit = true      % wether to use the l1 norm for data fitting
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
                
        % extract neighbouring quaternions
        uu = repmat(u,1,1,size(idNeighbours,3));
        n = u(idNeighbours);
          
        % compute weights to the neighboring pixels
        t = angle(uu,n);
        %w = (1+4*quality(idNeighbours(:,:,j))-quality)./5;
        w = alpha * (t <= F.threshold) ./ sqrt(t.^2+F.eps^2);
        w(isnan(w)) = 0;
        
        % the gradient
        if F.l1DataFit
          w0 = quality ./ sqrt(angle(q,u).^2+F.eps^2);
        else
          w0 = quality;
        end
        w0(isnan(w0)) = 0;
        g = w0 .* log(q,u) + nansum(w .* log(n,uu),3);
          
        % update step length
        lambda = w0 + sum(w,3);
        lambda(lambda==0) = inf;
        
        % the final step
        g = g ./ lambda;
        
        % update u
        u = expquat(g,u);
                
        iter = iter + 1;
      end
      
      ori = orientation(u,ori.CS,ori.SS);
    end
    
  end
  
end