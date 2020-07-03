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

      oS.updateTol(oS.phi2);
    end

    function ori = makeGrid(oS,varargin)

      oS.plotGrid = plotS2Grid(oS.sR,varargin{:});
      oS.gridSize = (0:numel(oS.phi2)) * length(oS.plotGrid);
      phi1 = repmat(oS.plotGrid.rho,[1,1,numel(oS.phi2)]);
      Phi = repmat(oS.plotGrid.theta,[1,1,numel(oS.phi2)]);
      phi2 = repmat(reshape(oS.phi2,1,1,[]),[size(oS.plotGrid) 1]);

      ori = orientation.byEuler(phi1,Phi,phi2,'Bunge',oS.CS,oS.SS);

    end
    
    function ori = quiverGrid(oS,varargin)

      maxPhi = oS.sR.thetaMax;
      maxphi1 = oS.sR.rhoMax;
      res = get_option(varargin,'resolution',15*degree);
      
      [phi1,Phi,phi2] = meshgrid(res/2:res:maxphi1,res/2:res:maxPhi,oS.phi2);
      
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

      secPos = oS.secList(phi2,oS.phi2);
      Phi = min(max(Phi,1e-5),pi-1e-5);
      S2Pos = vector3d.byPolar(Phi,phi1);
      
      % try to handle the case that some orientations apear at different sections
      if ~check_option(varargin,'preserveOrder')
      
        ind = find(Phi <= 1e-5).';
        if ~isempty(ind)
          secPos = [secPos(~ind).', reshape(repmat(1:length(oS.phi2),1,length(ind)),1,[])];
          newPhi1 = bsxfun(@minus,phi1(ind)+phi2(ind),oS.phi2.');
          S2Pos = [S2Pos(~ind).',reshape(vector3d.byPolar(1e-5,newPhi1),1,[])];
        end
        
        ind = find(Phi >= pi-1e-5).';
        if ~isempty(ind)
          secPos = [secPos(~ind).', reshape(repmat(1:length(oS.phi2),1,length(ind)),1,[])];
          newPhi1 = bsxfun(@plus,phi1(ind)-phi2(ind), oS.phi2.');
          S2Pos = [S2Pos(~ind).',reshape(vector3d.byPolar(pi-1e-5,newPhi1),1,[])];
        end
      end

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
    
    function h = quiverSection(oS,ax,sec,v,data,varargin)

      % translate rotational data into tangential data
      if iscell(data) && isa(data{1},'quaternion')
        [v2,sec2] = project(oS,data{1},'noSymmetry','preserveOrder');
        data{1} = v2 - v;
        data{1}(sec2 ~= sec)=NaN;
      end
      if check_option(varargin,'normalize'), data{1} = normalize(data{1}); end
      
      % plot data
      h = quiver(v,data{:},oS.sR,'TR',[int2str(oS.phi2(sec)./degree),'^\circ'],...
      'parent',ax,'projection','plain','xAxisDirection','east',...
        'xlabel','$\varphi_1$','ylabel','$\Phi$',...
        'zAxisDirection','intoPlane',varargin{:},'doNotDraw');        

    end
    
    
  end
end
