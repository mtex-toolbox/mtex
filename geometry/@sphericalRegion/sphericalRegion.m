classdef sphericalRegion
% sphericalRegion implements a region on the sphere
% The region is bounded by small circles given by there normal vectors
% and the maximum inner product, i.e., all points v inside a region
% satisfy the conditions dot(v, N) <= alpha
%
%  Syntax
%   sR = sphericalRegion(N)
%   sR = sphericalRegion(N,alpha)
%   sR = sphericalRegion(N,'antipodal')
%
  
  properties
    N = vector3d       % the normal vectors of the bounding circles
    alpha = []         % the cosine of the bounding circle
    antipodal = false  % used for check_inside
  end

  
  methods
        
    function sR = sphericalRegion(varargin)
      %

      % default syntax sphericalRegion(N,alpha)
      if nargin>=1 && isa(varargin{1},'vector3d')
        sR.N = normalize(varargin{1});
        if nargin>=2 && isa(varargin{2},'double')
          sR.alpha = varargin{2};
          if length(sR.alpha) == 1
            sR.alpha = repmat(sR.alpha,size(sR.N));
          end
        else
          sR.alpha = zeros(size(sR.N));
        end
      elseif nargin>=1 && isa(varargin{1},'sphericalRegion')
        sR = varargin{1};
      else
        sR.N = vector3d;
        sR.alpha = [];
      end
      
      % region given by vertices
      if check_option(varargin,'vertices')
        v = get_option(varargin,'vertices');
        N = normalize(cross(v,v([2:end,1])));
        sR.N = [sR.N,N];
        sR.alpha = [sR.alpha,zeros(size(N))];      
        warning('This syntax is obsolete. Use sphericalRegion.byVertices!')
      end
        
      % additional options
      maxTheta = get_option(varargin,'maxTheta',pi);
      if maxTheta < pi-1e-5
        sR.N = [sR.N,zvector];
        sR.alpha = [sR.alpha,cos(maxTheta)];
      end
        
      minTheta = get_option(varargin,'minTheta',0);
      if minTheta > 1e-5
        sR.N = [sR.N,-zvector];
        sR.alpha = [sR.alpha,cos(pi-minTheta)];
      end
        
      minRho = get_option(varargin,'minRho',0);
      maxRho = get_option(varargin,'maxRho',2*pi);
                
      if maxRho - minRho < 2*pi - 1e-5
        sR.N = [sR.N,vector3d('theta',90*degree,'rho',[90*degree+minRho,maxRho-90*degree])];
        sR.alpha = [sR.alpha,0,0];
      end
      
      if check_option(varargin,{'complete','3d'}), sR = sphericalRegion; end
      if check_option(varargin,'upper'), sR = sR.restrict2Upper; end
      if check_option(varargin,'lower'), sR = sR.restrict2Lower; end
      
    end
            
    function th = thetaMin(sR)
      
      th = thetaRange(sR);
      
    end
    
    function th = thetaMax(sR)
      
      [~,th] = thetaRange(sR);
      
    end
      
    function rh = rhoMax(sR)

      [~,rh] = rhoRange(sR);
      if length(rh) ~=1, rh = 2*pi; end
      
      
    end
    
    function rh = rhoMin(sR)

      rh = rhoRange(sR);
      if length(rh) ~=1, rh = 0; end
      
    end
    
    function bounds = polarRange(sR)
      
      [thetaMin, thetaMax] = thetaRange(sR);
      [rhoMin, rhoMax] = rhoRange(sR);
      if length(rhoMin) ~= 1      
        rhoMin = 2*pi;
        rhoMax = 2*pi;
      end
            
      bounds = [thetaMin, rhoMin, thetaMax, rhoMax];
      
    end
    
    function [thetaMin, thetaMax] = thetaRange(sR,rho)
      
      % antipodal should not increase spherical region
      sR.antipodal = false;
      
      if nargin == 2
        
        theta = linspace(0,pi,10000);
        
        srho = size(rho);
        [rho,theta] = meshgrid(rho,theta);
        
        v = vector3d('polar',theta,rho);
        
        ind = sR.checkInside(v);
        
        theta(~ind) = NaN;
        
        thetaMin = reshape(nanmin(theta),srho);
        thetaMax = reshape(nanmax(theta),srho);
   
      else
        
        % polar angle of the vertices
        th = sR.vertices.theta;
        
        if sR.checkInside(zvector)
          thetaMin = 0;
        elseif ~isempty(th)
          thetaMin = min(th);
        elseif ~isempty(sR.N)
          thetaMin = pi-max(acos(sR.alpha) + angle(sR.N,-zvector));
        else
          thetaMin = 0;
        end
        
        if sR.checkInside(-zvector)
          thetaMax = pi;
        elseif ~isempty(th)
          thetaMax = max(th);
        elseif ~isempty(sR.N)
          thetaMax = max(acos(sR.alpha) + angle(sR.N,zvector));
        else
          thetaMax = pi;
        end        
      end            
    end

    
    function rh = maxRho(sR)
    end
        
    
    function v = vertices(sR)
      % get the vertices of the fundamental region
      
      v = unique(boundary(sR));
      
    end
    
    function e = edges(sR)
      
            
    end
    
    function [v,e] = boundary(sR)
      % compute vertices and eges of a spherical region
    
      [l,r] = find(triu(ones(length(sR.N)),1));
      
      v = planeIntersect(sR.N(l),sR.N(r),sR.alpha(l),sR.alpha(r));
      
      ind = (imag(v.x).^2 + imag(v.y).^2 + imag(v.z).^2) < 1e-5;
      ind = ind & sR.checkInside(v);
      l = [l(:),l(:)]; r = [r(:),r(:)];
      e = [reshape(l(ind),[],1),reshape(r(ind),[],1)];
      v(~ind) = [];
      
      % e - gives for each vertex the corresponding normal ids
      % 
      % I = sparse()
      
      
    end
    
    function alpha = innerAngle(sR)
      
      [~,e] = boundary(sR);
      alpha = pi-angle(sR.N(e(:,1)),sR.N(e(:,2)));      
      
    end
    
    function c = center(sR)
      
      v = unique(sR.vertices);
      
      if length(sR.N) < 2
        
        c = sR.N;
        
      elseif length(v) < 3
        
        % find the pair of maximum angle
        w = angle_outer(sR.N,sR.N);
        [i,j] = find(w == max(w(:)),1);
        
        c = mean(sR.N([i,j]));
      
      elseif length(v) < 4
        
        c = mean(v);

      else
      
        v = equispacedS2Grid(sR,'resolution',1*degree);
        c = mean(v);
      
        if norm(c) < 1e-4
          c = zvector;
        else
          c = c.normalize;
        end
      end
    end
  end
  
  methods (Static = true)
    sR = byVertices(V,varargin)    
    sR = triangle(a,b,c,varargin)
  end
end

