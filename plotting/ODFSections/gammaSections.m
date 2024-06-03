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
      [alpha,beta,oS.maxGamma] = fundamentalRegionEuler(oS.CS1,oS.CS2,varargin{:},'Matthies'); %#ok<*PROP>
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

    function ori = quiverGrid(oS,varargin)

      maxbeta = oS.sR.thetaMax;
      maxalpha = oS.sR.rhoMax;
      res = get_option(varargin,'resolution',15*degree);
      
      [alpha,beta,gamma] = meshgrid(res/2:res:maxalpha,res/2:res:maxbeta,oS.gamma);
      
      ori = orientation.byEuler(alpha,beta,gamma,'ZYZ',oS.CS,oS.SS);

    end


    function n = numSections(oS)
      n = numel(oS.gamma);
    end

    function [S2Pos,secPos] = project(oS,ori,varargin)

      % maybe this can be done more efficiently
      if ~check_option(varargin,'noSymmetry')
        ori = ori.symmetrise('proper').';
      end
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

    function h = quiverSection(oS,ax,sec,v,data,varargin)

      % translate rotational data into tangential data
      if iscell(data) && isa(data{1},'quaternion')
        [v2,sec2] = project(oS,data{1},'noSymmetry','preserveOrder');
        data{1} = v2 - v;
        data{1}(sec2 ~= sec)=NaN;
      end
      if check_option(varargin,'normalize'), data{1} = normalize(data{1}); end
      
      % plot data
      h = quiver(v,data{:},oS.sR,'TR',[int2str(oS.gamma(sec)./degree),'^\circ'],...
      'parent',ax,'projection','plain','xAxisDirection','east',...
        'xlabel','$\alpha$','ylabel','$\beta$',...
        'zAxisDirection','intoPlane',varargin{:},'doNotDraw');        

    end


  end
end
