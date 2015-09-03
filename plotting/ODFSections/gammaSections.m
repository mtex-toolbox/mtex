classdef gammaSections < ODFSections

  properties
    gamma
    sR
    maxGamma
  end

  methods

    function oS = gammaSections(CS1,CS2,varargin)

      oS = oS@ODFSections(CS1,CS2);

      % get fundamental plotting region
      [alpha,beta,oS.maxGamma] = fundamentalRegionEuler(CS1,CS2,varargin{:}); %#ok<*PROP>
      oS.sR = sphericalRegion('maxTheta',beta,'maxRho',alpha);

      % get sections
      nsec = get_option(varargin,'sections',6);
      oS.gamma = linspace(0,oS.maxGamma,nsec+1);
      oS.gamma(end) = [];
      oS.gamma = get_option(varargin,'gamma',oS.gamma,'double');

    end

    function ori = makeGrid(oS,varargin)

      oS.plotGrid = plotS2Grid(oS.sR,varargin{:});
      oS.gridSize = (0:numel(oS.gamma)) * length(oS.plotGrid);
      alpha = repmat(oS.plotGrid.rho,[1,1,numel(oS.gamma)]);
      beta = repmat(oS.plotGrid.theta,[1,1,numel(oS.gamma)]);
      gamma = repmat(reshape(oS.gamma,1,1,[]),[size(oS.plotGrid) 1]);

      ori = orientation('Euler',alpha,beta,gamma,'ZYZ',oS.CS,oS.SS);

    end

    function n = numSections(oS)
      n = numel(oS.gamma);
    end

    function [S2Pos,secPos] = project(oS,ori,varargin)

      % maybe this can be done more efficiently
      ori = ori.symmetrise('proper').';
      [alpha,beta,gamma] = Euler(ori,'ZYZ'); %#ok<*PROPLC>

      bounds = sort(unique([oS.gamma - oS.tol,oS.gamma + oS.tol]));
      [~,secPos] = histc(mod(gamma,oS.maxGamma),bounds);
      secPos(iseven(secPos)) = -1;
      secPos = (secPos + 1)./2;

      S2Pos = vector3d('polar',beta,alpha);

    end

    function ori = iproject(oS,alpha,beta,igamma)
      ori = orientation('Euler',alpha,beta,oS.gamma(igamma),'ZYZ',oS.CS,oS.SS);
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
