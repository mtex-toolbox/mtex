classdef sigmaSections < ODFSections

  properties
    sigma
    sR
    grid
  end

  properties (Hidden=true)
    maxSigma
  end

  methods

    function oS = sigmaSections(varargin)

      oS = oS@ODFSections(varargin{:});

      % get fundamental plotting region
      [~,~,phi2] = fundamentalRegionEuler(oS.CS1,oS.CS2,varargin{:});
      oS.maxSigma = phi2;
      oS.sR = oS.CS2.fundamentalSector(varargin{:},'upper');

      % get sections
      oS.sigma = linspace(0,phi2,1+get_option(varargin,'sections',6));
      oS.sigma(end) = [];
      oS.sigma = get_option(varargin,'sigma',oS.sigma,'double');

    end

    function ori = makeGrid(oS,varargin)

      oS.plotGrid = plotS2Grid(oS.sR,varargin{:});
      oS.gridSize = (0:numel(oS.sigma)) * length(oS.plotGrid);
      phi1 = repmat(oS.plotGrid.rho,[1,1,numel(oS.sigma)]);
      Phi = repmat(oS.plotGrid.theta,[1,1,numel(oS.sigma)]);
      sigmaLarge = repmat(reshape(oS.sigma,1,1,[]),[size(oS.plotGrid) 1]);

      ori = orientation.byEuler(phi1,Phi,sigmaLarge - phi1,'ZYZ',oS.CS,oS.SS);

    end

    function n = numSections(oS)
      n = numel(oS.sigma);
    end

    function [S2Pos,secPos] = project(oS,ori,varargin)

      % maybe this can be done more efficiently
      ori = ori.symmetrise('proper').';

      [e1,e2,e3] = Euler(ori,'ZYZ');

      sigma = mod(e1 + e3,oS.maxSigma); %#ok<*PROPLC,*PROP>
      secPos = oS.secList(sigma,oS.sigma);

      S2Pos = vector3d('polar',e2,e1);

    end

    function ori = iproject(oS,phi1,Phi,isigma)
      ori = orientation.byEuler(phi1,Phi,oS.sigma(isigma)-phi1,'ZYZ',oS.CS,oS.SS);
    end

    function h = plotSection(oS,ax,sec,v,data,varargin)

      % plot data
      if isa(oS.SS,'crystalSymmetry')
        varargin = [oS.SS.plotOptions,varargin];
      end
      h = plot(v,data{:},oS.sR,'TR',[int2str(oS.sigma(sec)./degree),'^\circ'],...
        'parent',ax,varargin{:},'doNotDraw');

      if (isempty(oS.grid) || length(oS.grid) < sec) && ~check_option(varargin,'noGrid')

        fak = sqrt(length(oS.SS));
        r = equispacedS2Grid(oS.sR,'resolution',15*degree / fak);

        [theta,rho] = polar(r);
        rot = rotation.byEuler(rho,theta,-rho,'ZYZ');

        vF = rotation.byAxisAngle(r,oS.sigma(sec)) .* rot * xvector;

        hold on
        oS.grid(sec) = quiver(r,vF,'parent',ax,'doNotDraw','arrowSize',0.1/fak,'color',0.7*[1 1 1],'HitTest','off');
        hold off
      end
    end
  end
end
