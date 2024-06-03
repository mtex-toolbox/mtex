classdef alphaSections < ODFSections

  properties
    alpha
    sR
    maxalpha
  end

  methods

    function oS = alphaSections(varargin)
      % alpha sections for ODF and orientation plotting
      %
      % Syntax
      %
      %   oS = alphaSections(cs1,cs2,'sections',5)
      %   oS = alphaSections(cs1,cs2,'alpha',(0:15:90)*degree)
      %
      % Input
      %  cs1, cs2 - @crystalSymmetry, @specimenSymmetry
      %
      % Options
      %  sections - number of sections
      %  alpha - explicite section values
      %

      oS = oS@ODFSections(varargin{:});

      % get fundamental plotting region
      [oS.maxalpha,beta,maxgamma] = fundamentalRegionEuler(oS.CS1,oS.CS2,varargin{:},'Matthies'); %#ok<*PROP>
      oS.sR = sphericalRegion('maxTheta',beta,'maxRho',maxgamma);

      % get sections
      nsec = get_option(varargin,'sections',6);
      oS.alpha = linspace(0,oS.maxalpha,nsec+1);
      oS.alpha(end) = [];
      oS.alpha = get_option(varargin,'alpha',oS.alpha,'double');

      oS.updateTol(oS.alpha);
    end

    function ori = makeGrid(oS,varargin)

      oS.plotGrid = plotS2Grid(oS.sR,varargin{:});
      oS.gridSize = (0:numel(oS.alpha)) * length(oS.plotGrid);
      gamma = repmat(oS.plotGrid.rho,[1,1,numel(oS.alpha)]);
      beta = repmat(oS.plotGrid.theta,[1,1,numel(oS.alpha)]);
      alpha = repmat(reshape(oS.alpha,1,1,[]),[size(oS.plotGrid) 1]);

      ori = orientation.byEuler(alpha,beta,gamma,'ZYZ',oS.CS,oS.SS);

    end

    function ori = quiverGrid(oS,varargin)

      maxbeta = oS.sR.thetaMax;
      maxgamma = oS.sR.rhoMax;
      res = get_option(varargin,'resolution',15*degree);
      
      [gamma,beta,alpha] = meshgrid(res/2:res:maxgamma,res/2:res:maxbeta,oS.alpha);
      
      ori = orientation.byEuler(alpha,beta,gamma,'ZYZ',oS.CS,oS.SS);

    end


    function n = numSections(oS)
      n = numel(oS.alpha);
    end

    function [S2Pos,secPos] = project(oS,ori,varargin)

      % maybe this can be done more efficiently
      if ~check_option(varargin,'noSymmetry')
        ori = ori.symmetrise('proper').';
      end
      [alpha,beta,gamma] = Euler(ori,'ZYZ'); %#ok<*PROPLC>

      secPos = oS.secList(mod(alpha,oS.maxalpha),oS.alpha);
      S2Pos = vector3d.byPolar(beta,gamma);

    end

    function ori = iproject(oS,gamma,beta,ialpha)
      ori = orientation.byEuler(oS.alpha(ialpha),beta,gamma,'ZYZ',oS.CS,oS.SS);
    end

    function h = plotSection(oS,ax,sec,v,data,varargin)

      % plot data
      h = plot(v,data{:},oS.sR,'TR',[int2str(oS.alpha(sec)./degree),'^\circ'],...
        'parent',ax,'projection','plain','xAxisDirection','east',...
        'xlabel','$\gamma$','ylabel','$\beta$','dynamicMarkerSize',...
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
      h = quiver(v,data{:},oS.sR,'TR',[int2str(oS.alpha(sec)./degree),'^\circ'],...
      'parent',ax,'projection','plain','xAxisDirection','east',...
        'xlabel','$\gamma$','ylabel','$\beta$',...
        'zAxisDirection','intoPlane',varargin{:},'doNotDraw');        

    end


  end
end
