classdef phi1Sections < ODFSections

  properties
    phi1
    sR
    maxphi1
  end

  methods

    function oS = phi1Sections(varargin)
      % phi1 sections for ODF and orientation plotting
      %
      % Syntax
      %
      %   oS = phi1Sections(cs1,cs2,'sections',5)
      %   oS = phi1Sections(cs1,cs2,'phi1',(0:15:90)*degree)
      %
      % Input
      %  cs1, cs2 - @crystalSymmetry, @specimenSymmetry
      %
      % Options
      %  sections - number of sections
      %  phi1 - explicite section values
      %

      oS = oS@ODFSections(varargin{:});

      % get fundamental plotting region
      [oS.maxphi1,Phi,maxphi2] = fundamentalRegionEuler(oS.CS1,oS.CS2,varargin{:}); %#ok<*PROP>
      oS.sR = sphericalRegion('maxTheta',Phi,'maxRho',maxphi2);

      % get sections
      nsec = get_option(varargin,'sections',6);
      oS.phi1 = linspace(0,oS.maxphi1,nsec+1);
      oS.phi1(end) = [];
      oS.phi1 = get_option(varargin,'phi1',oS.phi1,'double');

    end

    function ori = makeGrid(oS,varargin)
      % generate a grid for plotting smooth functions

      oS.plotGrid = plotS2Grid(oS.sR,varargin{:});
      oS.gridSize = (0:numel(oS.phi1)) * length(oS.plotGrid);
      phi2 = repmat(oS.plotGrid.rho,[1,1,numel(oS.phi1)]);
      Phi = repmat(oS.plotGrid.theta,[1,1,numel(oS.phi1)]);
      phi1 = repmat(reshape(oS.phi1,1,1,[]),[size(oS.plotGrid) 1]);

      ori = orientation.byEuler(phi1,Phi,phi2,'Bunge',oS.CS,oS.SS);

    end

    function n = numSections(oS)
      n = numel(oS.phi1);
    end

    function [S2Pos,secPos] = project(oS,ori,varargin)

      % maybe this can be done more efficiently
      ori = ori.symmetrise('proper').';
      [phi1,Phi,phi2] = Euler(ori,'Bunge'); %#ok<*PROPLC>

      secPos = oS.secList(mod(phi1,oS.maxphi1),oS.phi1);

      S2Pos = vector3d.byPolar(Phi,phi2);

    end

    function ori = iproject(oS,phi2,Phi,iphi1)
      ori = orientation.byEuler(oS.phi1(iphi1),Phi,phi2,'Bunge',oS.CS,oS.SS);
    end

    function h = plotSection(oS,ax,sec,v,data,varargin)

      % plot data
      h = plot(v,data{:},oS.sR,'TR',[int2str(oS.phi1(sec)./degree),'^\circ'],...
        'parent',ax,'projection','plain','xAxisDirection','east',...
        'xlabel','$\varphi_2$','ylabel','$\Phi$','dynamicMarkerSize',...
        'zAxisDirection','intoPlane',varargin{:},'doNotDraw');

    end
  end
end
