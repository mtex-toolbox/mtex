classdef ipfSections < ODFSections
  
  properties
    r1        % the inverse pole figure which is splitted up
    r2        % 
    omega
    sR
    referenceField
  end
  
  properties (Hidden=true)
    maxOmega
  end
    
  methods
    
    function oS = ipfSections(CS1,CS2,varargin)
      
      oS = oS@ODFSections(CS1,CS2);
     
      oS.r1 = zvector;
      oS.r2 = xvector;
      
      oS.maxOmega = get_option(varargin,'maxOmega',2*pi / CS2.nfold(oS.r1));
      oS.sR = CS1.fundamentalSector(varargin{:});
     
      % get sections      
      oS.omega = linspace(0,oS.maxOmega,1+get_option(varargin,'sections',6));
      oS.omega(end) = [];
      oS.omega = get_option(varargin,'omega',oS.omega,'double');
      
      oS.updateTol(oS.omega);
      
      oS.referenceField = @(h) pfSections.oneSingularityField(h);
      
    end
    
    function ori = makeGrid(oS,varargin)
      
      oS.plotGrid = plotS2Grid(oS.sR,varargin{:});
      oS.gridSize = (0:numel(oS.omega)) * length(oS.plotGrid);
      
      ori = orientation.nan(oS.plotGrid.size(1),oS.plotGrid.size(2),numel(oS.omega),oS.CS1,oS.CS2);
      for iOmega = 1:numel(oS.omega)
      
        h2 = oS.vectorField(oS.plotGrid,oS.omega(iOmega));
        ori(:,:,iOmega) = reshape(orientation.map(oS.plotGrid,oS.r1,h2,oS.r2),size(oS.plotGrid));
      
      end      
      
    end

    function n = numSections(oS)
      n = numel(oS.omega);
    end
    
    function [r,secPos] = project(oS,ori,varargin)

      % maybe this can be done more efficiently
      ori = ori.symmetrise('proper').';

      % determine pole figure position
      h = ori \ oS.r1;
      
      % determine omega angle
      hF = ori \ oS.r2;
      vF = vectorField(oS,h);      
      
      omega = angle(hF,vF,h); %#ok<*PROPLC>
      secPos = oS.secList(omega,oS.omega);
                 
    end
    
    function ori = iproject(oS,rho,theta,iOmega)
      h1 = vector3d.byPolar(theta,rho);
      h2 = oS.vectorField(h1,oS.omega(iOmega));
      
      ori = orientation.map(h1,oS.r1,h2,oS.r2);      
    end
    
    function h = plotSection(oS,ax,sec,v,data,varargin)
      
      % plot data
      h = plot(v,data{:},oS.sR,'TR',[int2str(oS.omega(sec)./degree),'^\circ'],...
        'parent',ax,varargin{:},'doNotDraw');

      hold on
      h = equispacedS2Grid(oS.sR,'resolution',15*degree);
      vF = oS.vectorField(h,oS.omega(sec));      
      quiver(h,vF,'parent',ax,'doNotDraw','color',0.7*[1 1 1],'HitTest','off');
      hold off
      
    end
    
    function vF = vectorField(oS,r,omega)
      
      
      vF = oS.referenceField(r);
      
      if nargin == 3
        vF = rotation.byAxisAngle(r,omega-pi/2) .* vF;
      end
      
    end
    
    
  end
  
  methods (Static = true)
    function vF = polarField(r)
      % compute and reference vector field on the pole figure
     
      vF = normalize(r + xvector);
      vF = normalize(vF - dot(vF,r) .* r);
      
    end
    
    function vF = oneSingularityField(r1)
      
      r2 = r1; r2.y = -r2.y;
      
      N = normalize(cross(r1+zvector,r2+zvector));
      
      ind = r1.y == 0;
      N(ind) = normalize(r1(ind) - zvector);
      
      ind = r1 == zvector;
      N(ind) = xvector;
      
      vF = normalize(r1 - dot(r1,N) .* N);
      vF = rotation.byAxisAngle(N,-90*degree*sign(N.x)) .* vF;

      vF = normalize(vF - dot(vF,r1) .* r1);      
      
    end
    
  end
  
end

% testing code
% r = equispacedS2Grid('resolution',20*degree)
% quiver(r,vector3d(vF))