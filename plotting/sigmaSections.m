classdef sigmaSections < ODFSections
  
  properties
    sigma
    sR
  end
  
  properties (Hidden=true)
    maxSigma
  end
    
  methods
    
    function oS = sigmaSections(CS1,CS2,varargin)
      
      oS = oS@ODFSections(CS1,CS2);
      
      % get fundamental plotting region
      [phi1,Phi,phi2] = getFundamentalRegion(CS1,CS2,varargin{:});
      oS.maxSigma = min(phi1,phi2);
      oS.sR = sphericalRegion('maxTheta',Phi,'maxRho',max(phi1,phi2));
      
      % get sections
      
      oS.sigma = linspace(0,phi2,7);
      oS.sigma(end) = [];
      oS.sigma = get_option(varargin,'sigma',oS.sigma);      
      
    end
    
    function ori = makeGrid(oS,varargin)
      ori = orientation(oS.CS1,oS.CS2);
      oS.gridSize(1) = 0;
      for s = 1:length(oS.angles)
        sR = fundamentalSector(oS.CS,oS.CS2,'angle',oS.angles(s));
        oS.plotGrid{s} = plotS2Grid(sR,varargin{:});
        oS.gridSize(s+1) = oS.gridSize(s) + length(oS.plotGrid{s});
        ori(1+oS.gridSize(s):oS.gridSize(s+1)) = ...
          orientation('axis',oS.plotGrid{s},'angle',oS.angles(s));
      end     
    end

    function n = numSections(oS)
      n = numel(oS.sigma);
    end
    
    function [S2Pos,secPos] = project(oS,ori)
    
      [e1,e2,e3] = Euler(ori,'ABG');

      sigma = mod(e1 + e3,oS.maxSigma); %#ok<*PROP>
            
      % this builds a list 
      bounds = sort(unique([oS.sigma - oS.tol,oS.sigma + oS.tol]));
      [~,secPos] = histc(sigma,bounds);
      secPos(iseven(secPos)) = -1;
      secPos = (secPos + 1)./2;
      
      S2Pos = vector3d('polar',e2,e1);

    end
        
    function h = plotSection(oS,ax,sec,v,data,varargin)
      
      % plot data
      h = plot(v,data{:},'TR',[int2str(oS.sigma(sec)./degree),'^\circ'],...
        'parent',ax,varargin{:},'doNotDraw');

    end
  end
end
