classdef phi2Sections < ODFSections

  properties
    phi2
    sR
    maxphi2
  end

  methods

    function oS = phi2Sections(varargin)
      % phi2 sections for ODF and orientation plotting
      %
      % Syntax
      %
      %   oS = phi2Sections(cs1,cs2,'sections',5)
      %   oS = phi2Sections(cs1,cs2,'phi2',(0:15:90)*degree)
      %
      % Input
      %  cs1, cs2 - @crystalSymmetry, @specimenSymmetry
      %
      % Options
      %  sections - number of sections
      %  phi2 - explicite section values
      %

      oS = oS@ODFSections(varargin{:});

      % get fundamental plotting region
      [phi1,Phi,oS.maxphi2] = fundamentalRegionEuler(oS.CS1,oS.CS2,varargin{:}); %#ok<*PROP>
      Phi = get_option(varargin,'maxPhi',Phi);
      phi1 = get_option(varargin,'maxphi1',phi1);
      oS.sR = sphericalRegion('maxTheta',Phi,'maxRho',phi1);

      % get sections
      nsec = get_option(varargin,'sections',6);
      nsec = 1+oS.maxphi2./get_option(varargin,'secResolution',oS.maxphi2/(nsec-1));
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

      ori = orientation.byEuler(phi1,Phi,phi2,'Bunge',oS.CS,oS.SS);

    end

    function n = numSections(oS)
      n = numel(oS.phi2);
    end

    function [S2Pos,secPos] = project(oS,ori,varargin)

      % maybe this can be done more efficiently
      if ~check_option(varargin,'noSymmetry')
        ori = ori.symmetrise('proper').';
      end
      [phi1,Phi,phi2] = Euler(ori,'Bunge'); %#ok<*PROPLC>

      secPos = oS.secList(mod(phi2,oS.maxphi2),oS.phi2);

      S2Pos = vector3d('polar',Phi,phi1);

    end

    function ori = iproject(oS,phi1,Phi,iphi2)
      ori = orientation.byEuler(phi1,Phi,oS.phi2(iphi2),'Bunge',oS.CS,oS.SS);
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
