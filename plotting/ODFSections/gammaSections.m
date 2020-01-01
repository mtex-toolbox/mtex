classdef gammaSections < ODFSections

  properties
    gamma
    sR
    maxGamma
  end

  methods

    function oS = gammaSections(varargin)
      % gamma sections for ODF and orientation plotting
      %
      % Syntax
      %
      %   oS = gammaSections(cs1,cs2,'sections',5)
      %   oS = gammaSections(cs1,cs2,'gamma',(0:15:90)*degree)
      %
      % Input
      %  cs1, cs2 - @crystalSymmetry, @specimenSymmetry
      %
      % Options
      %  sections - number of sections
      %  gamma - explicite section values
      %

      oS = oS@ODFSections(varargin{:});

      % get fundamental plotting region
      [alpha,beta,oS.maxGamma] = fundamentalRegionEuler(oS.CS1,oS.CS2,varargin{:}); %#ok<*PROP>
      oS.sR = sphericalRegion('maxTheta',beta,'maxRho',alpha);

      % get sections
      nsec = get_option(varargin,'sections',6);
      oS.gamma = linspace(0,oS.maxGamma,nsec+1);
      oS.gamma(end) = [];
      oS.gamma = get_option(varargin,'gamma',oS.gamma,'double');

      oS.updateTol(oS.gamma);
    end

    function ori = makeGrid(oS,varargin)

      oS.plotGrid = plotS2Grid(oS.sR,varargin{:});
      oS.gridSize = (0:numel(oS.gamma)) * length(oS.plotGrid);
      alpha = repmat(oS.plotGrid.rho,[1,1,numel(oS.gamma)]);
      beta = repmat(oS.plotGrid.theta,[1,1,numel(oS.gamma)]);
      gamma = repmat(reshape(oS.gamma,1,1,[]),[size(oS.plotGrid) 1]);

      ori = orientation.byEuler(alpha,beta,gamma,'ZYZ',oS.CS,oS.SS);

    end

    function n = numSections(oS)
      n = numel(oS.gamma);
    end

    function [S2Pos,secPos] = project(oS,ori,varargin)

      % maybe this can be done more efficiently
      ori = ori.symmetrise('proper').';
      [alpha,beta,gamma] = Euler(ori,'ZYZ'); %#ok<*PROPLC>

      secPos = oS.secList(gamma,oS.gamma);
      S2Pos = vector3d.byPolar(beta,alpha);

    end

    function ori = iproject(oS,alpha,beta,igamma)
      ori = orientation.byEuler(alpha,beta,oS.gamma(igamma),'ZYZ',oS.CS,oS.SS);
    end

    function h = plotSection(oS,ax,sec,v,data,varargin)

      % plot data
      h = plot(v,data{:},oS.sR,'TR',[int2str(oS.gamma(sec)./degree),'^\circ'],...
        'parent',ax,'projection','plain','xAxisDirection','east',...
        'xlabel','$\alpha$','ylabel','$\beta$','dynamicMarkerSize',...
        'zAxisDirection','intoPlane',varargin{:},'doNotDraw');

    end
  end
end
