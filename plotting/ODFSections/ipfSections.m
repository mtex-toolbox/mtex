classdef ipfSections < ODFSections
  
  properties
    r1        % the inverse pole figure which is split up
    r2        % the second
    omega     % 
    sR
    referenceField
    % an orientation ori in an ipf section is plotted at
    % position h1 in section omega where
    % h1 = sym * inv(ori) * r1
    % sym is such that h1 is in the fundamental sector
    % h2 = sym * inv(ori) * r2
    % omega = angle(referenceField(h1), h2, h1)
  end
  
  properties (Hidden=true)
    maxOmega
  end
    
  methods
    
    function oS = ipfSections(CS1,varargin)
      
      oS = oS@ODFSections(CS1,varargin{:});
     
      oS.r1 = zvector;
      oS.r2 = xvector;
      
      oS.maxOmega = get_option(varargin,'maxOmega',2*pi / oS.CS2.nfold(oS.r1));
      oS.sR = CS1.fundamentalSector(varargin{:});
     
      % get sections      
      oS.omega = linspace(0,oS.maxOmega,1+get_option(varargin,'sections',6));
      oS.omega(end) = [];
      oS.omega = get_option(varargin,'omega',oS.omega,'double');
      
      oS.updateTol(oS.omega);
      
      oS.referenceField = S2VectorField.sigma;
      
    end
    
    function ori = makeGrid(oS,varargin)
      
      oS.plotGrid = plotS2Grid(oS.sR,varargin{:});
      oS.gridSize = (0:numel(oS.omega)) * length(oS.plotGrid);
      
      ori = orientation.nan(oS.plotGrid.size(1),oS.plotGrid.size(2),numel(oS.omega),oS.CS1,oS.CS2);
      for iOmega = 1:numel(oS.omega)
      
        h2 = oS.vectorField(oS.plotGrid,oS.omega(iOmega));
        ori(:,:,iOmega) = reshape(...
          orientation.map(oS.plotGrid,oS.r1,h2,oS.r2),size(oS.plotGrid));

      end      
      
    end

    function ori = quiverGrid(oS,varargin)
      
      S2G = equispacedS2Grid(oS.sR,varargin{:});
      
      ori = orientation.nan(S2G.size(1),S2G.size(2),numel(oS.omega),oS.CS1,oS.CS2);
      for iOmega = 1:numel(oS.omega)

        h2 = oS.vectorField(S2G,oS.omega(iOmega));
        ori(:,:,iOmega) = reshape(orientation.map(S2G,oS.r1,h2,oS.r2),size(S2G));

      end
    end

    function n = numSections(oS)
      n = numel(oS.omega);
    end
    
    function [h1,secPos] = project(oS,ori,varargin)
      
      ori = ori(:);

      % determine position in the inverse pole figure
      h1 = ori .\ oS.r1;
      [h1,sym] = h1.project2FundamentalRegion;

      % determine omega angle
      h2 = sym .* (ori .\ oS.r2);
      vF = vectorField(oS,h1,0);
      
      omegaSec = angle(vF, h2, h1);

      secPos = oS.secList(omegaSec,oS.omega);
                 
    end
    
    function ori = iproject(oS,rho,theta,iOmega)

      h1 = vector3d.byPolar(theta,rho);
      h2 = oS.vectorField(h1,oS.omega(iOmega));
      
      ori = orientation.map(h1,oS.r1,h2,oS.r2);      
    end
    
    function h = plotSection(oS,ax,sec,v,data,varargin)
      
      % plot data
      h = plot(v,data{:},oS.sR,oS.CS1,...
        'TR',[int2str(oS.omega(sec)./degree),'^\circ'],...
        'parent',ax,varargin{:},'doNotDraw');

      if ~check_option(varargin,'noGrid')
        hold on
        S2G = equispacedS2Grid(oS.sR,'resolution',7.5*degree);
        vF = oS.vectorField(S2G,oS.omega(sec));
        h(end+1) = quiver(S2G,vF,'parent',ax,'doNotDraw','color',0.7*[1 1 1],'HitTest','off');
        hold off
      end
    end
    
    function h = quiverSection(oS,ax,sec,v,data,varargin)

      % translate rotational data into tangential data
      if iscell(data) && isa(data{1},'quaternion')
        [v2,sec2] = project(oS,data{1},'noSymmetry'); %#ok<PRJET>
        data{1} = v2 - v;
        data{1}(sec2 ~= sec)=NaN;
      end
      if check_option(varargin,'normalize'), data{1} = normalize(data{1}); end
      
      % plot data
      h = quiver(v,data{:},oS.sR,oS.CS1,'TR',[int2str(oS.omega(sec)./degree),'^\circ'],...
        'parent',ax,varargin{:},'doNotDraw');

    end

    function vF = vectorField(oS,r,omega)
      
      vF = oS.referenceField.eval(r);
      
      if nargin == 3
        vF = rotation.byAxisAngle(r,omega-pi/2) .* vF;
      end
      
    end
    
    
  end
  
  methods (Static = true)
    function vF = polarField(r)
      % compute and reference vector field on the pole figure
     
      vF = normalize(r + xvector);
      vF = normalize(vF - dot(vF,r) .* r);
      
    end
    
    function vF = oneSingularityField(r1)
      
      r2 = r1; r2.y = -r2.y;
      
      N = normalize(cross(r1+zvector,r2+zvector));
      
      ind = r1.y == 0;
      N(ind) = normalize(r1(ind) - zvector);
      
      ind = r1 == zvector;
      N(ind) = xvector;
      
      vF = normalize(r1 - dot(r1,N) .* N);
      vF = rotation.byAxisAngle(N,-90*degree*sign(N.x)) .* vF;

      vF = normalize(vF - dot(vF,r1) .* r1);      
      
    end
    
  end
  
end

% testing code
% r = equispacedS2Grid('resolution',20*degree)
% quiver(r,vector3d(vF))