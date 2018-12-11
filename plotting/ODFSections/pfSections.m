classdef pfSections < ODFSections

  properties
    h1        % the pole figure which is splitted up
    h2        %
    omega
    sR
    referenceField
  end

  properties (Hidden=true)
    maxOmega
  end

  methods

    function oS = pfSections(CS1,CS2,varargin)

      oS = oS@ODFSections(CS1,CS2);

      oS.h1 = Miller(0,0,1,'hkl',CS1); % c*
      oS.h2 = Miller(1,0,0,'uvw',CS1); % a

      oS.maxOmega = get_option(varargin,'maxOmega',2*pi / CS1.nfold(oS.h1));
      oS.sR = CS2.fundamentalSector(varargin{:});

      % get sections
      oS.omega = linspace(0,oS.maxOmega,1+get_option(varargin,'sections',6));
      oS.omega(end) = [];
      oS.omega = get_option(varargin,'omega',oS.omega,'double');

      oS.referenceField = @(r) pfSections.oneSingularityField(r);
      %oS.referenceField = @(r) pfSections.polarField(r);

    end

    function ori = makeGrid(oS,varargin)

      oS.plotGrid = plotS2Grid(oS.sR,varargin{:});
      oS.gridSize = (0:numel(oS.omega)) * length(oS.plotGrid);

      ori = orientation.nan(oS.plotGrid.size(1),oS.plotGrid.size(2),numel(oS.omega),oS.CS1,oS.CS2);
      for iOmega = 1:numel(oS.omega)

        r2 = oS.vectorField(oS.plotGrid,oS.omega(iOmega));
        ori(:,:,iOmega) = reshape(orientation.map(oS.h1,oS.plotGrid,oS.h2,r2),size(oS.plotGrid));

      end

    end

    function n = numSections(oS)
      n = numel(oS.omega);
    end

    function [r,secPos] = project(oS,ori,varargin)

      % maybe this can be done more efficiently
      ori = ori.symmetrise('proper').';

      % determine pole figure position
      r = ori * oS.h1;

      % determine omega angle
      rF = ori * oS.h2;
      vF = vectorField(oS,r);
      omega = angle(rF,vF,r);

      % this builds a list
      bounds = sort(unique([oS.omega - oS.tol,oS.omega + oS.tol]));
      [~,secPos] = histc(omega,bounds); %#ok<*PROPLC>
      secPos(iseven(secPos)) = -1;
      secPos = (secPos + 1)./2;

    end

    function ori = iproject(oS,rho,theta,iOmega)
      r1 = vector3d('polar',theta,rho);
      r2 = oS.vectorField(r1,oS.omega(iOmega));

      ori = orientation.map(soS.h1,r1,oS.h2,r2);
    end

    function h = plotSection(oS,ax,sec,v,data,varargin)

      % plot data
      h = plot(v,data{:},oS.sR,'TR',[int2str(oS.omega(sec)./degree),'^\circ'],...
        'parent',ax,varargin{:},'doNotDraw');

      hold on
      r = equispacedS2Grid(oS.sR,'resolution',15*degree);
      vF = oS.vectorField(r,oS.omega(sec));
      quiver(r,vF,'parent',ax,'doNotDraw','arrowSize',0.1,'color',0.7*[1 1 1],'HitTest','off');
      hold off

    end

    function vF = vectorField(oS,r,omega)


      vF = oS.referenceField(r);

      if nargin == 3
        vF = rotation.byAxisAngle(r,omega) .* vF;
      end

    end


  end

  methods (Static = true)
    function vF = polarField(r,rRef)
      % compute and reference vector field on the pole figure

      if nargin == 1, rRef = xvector; end

      vF = normalize(rRef - r);
      vF = normalize(vF - dot(vF,r) .* r);

    end

    function vF = sigmaField(r)

      [theta,rho] = polar(r);
      rot = rotation.byEuler(rho,theta,-rho,'ZYZ');
      vF = rot * xvector;

    end

    function vF = oneSingularityField(r1)

      r2 = r1; r2.x = -r2.x;

      N = normalize(cross(r1+zvector,r2+zvector));

      ind = r1.x == 0;
      N(ind) = normalize(r1(ind) - zvector);

      ind = r1 == zvector;
      N(ind) = yvector;

      vF = normalize(r1 - dot(r1,N) .* N);
      vF = rotation.byAxisAngle(N,sign(N.y)*90*degree) .* vF;

      vF = normalize(vF - dot(vF,r1) .* r1);

    end

  end

end

% testing code
% r = equispacedS2Grid('resolution',20*degree)
% quiver(r,vector3d(vF),'arrowSize',0.1)
