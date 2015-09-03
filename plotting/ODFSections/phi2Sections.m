classdef phi2Sections < ODFSections
  
  properties
    phi2
    sR
    maxphi2
  end
    
  methods
    
    function oS = phi2Sections(CS1,CS2,varargin)
   
      oS = oS@ODFSections(CS1,CS2);
      
      % get fundamental plotting region
      [phi1,Phi,oS.maxphi2] = fundamentalRegionEuler(CS1,CS2,varargin{:}); %#ok<*PROP>
      oS.sR = sphericalRegion('maxTheta',Phi,'maxRho',phi1);
      
      % get sections
      nsec = get_option(varargin,'sections',6);
      oS.phi2 = linspace(0,oS.maxphi2,nsec+1);
      oS.phi2(end) = [];
      oS.phi2 = get_option(varargin,'phi2',oS.phi2,'double');
      
    end
    
    function ori = makeGrid(oS,varargin)
    
      oS.plotGrid = plotS2Grid(oS.sR,varargin{:});
      oS.gridSize = (0:numel(oS.phi2)) * length(oS.plotGrid);
      phi1 = repmat(oS.plotGrid.rho,[1,1,numel(oS.phi2)]);
      Phi = repmat(oS.plotGrid.theta,[1,1,numel(oS.phi2)]);
      phi2 = repmat(reshape(oS.phi2,1,1,[]),[size(oS.plotGrid) 1]);
      
      ori = orientation('Euler',phi1,Phi,phi2,'Bunge',oS.CS,oS.SS);

    end

    function n = numSections(oS)
      n = numel(oS.phi2);
    end
    
    function [S2Pos,secPos] = project(oS,ori,varargin)
    
      % maybe this can be done more efficiently
      ori = ori.symmetrise('proper').';
      [phi1,Phi,phi2] = Euler(ori,'Bunge');

      bounds = sort(unique([oS.phi2 - oS.tol,oS.phi2 + oS.tol]));
      [~,secPos] = histc(mod(phi2,oS.maxphi2),bounds);
      secPos(iseven(secPos)) = -1;
      secPos = (secPos + 1)./2;
      
      S2Pos = vector3d('polar',Phi,phi1);

    end
        
    function ori = iproject(oS,phi1,Phi,iphi2)
      ori = orientation('Euler',phi1,Phi,oS.phi2(iphi2),'Bunge',oS.CS,oS.SS);
    end
    
    function h = plotSection(oS,ax,sec,v,data,varargin)
      
      % plot data
      h = plot(v,data{:},oS.sR,'TR',[int2str(oS.phi2(sec)./degree),'^\circ'],...
        'parent',ax,'projection','plain','xAxisDirection','east',...
        'xlabel','$\varphi_1$','ylabel','$\Phi$','dynamicMarkerSize',...
        'zAxisDirection','intoPlane',varargin{:},'doNotDraw');

    end
  end
end


  
