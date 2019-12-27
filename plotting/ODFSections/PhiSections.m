classdef PhiSections < ODFSections

  properties
    Phi
    maxphi1
    maxphi2
    maxPhi
  end

  methods

    function oS = PhiSections(varargin)

      oS = oS@ODFSections(varargin{:});

      % get fundamental plotting region
      [oS.maxphi1,oS.maxPhi,oS.maxphi2] = fundamentalRegionEuler(oS.CS1,oS.CS2,varargin{:});

      % get sections
      nsec = get_option(varargin,'sections',6);
      oS.Phi = linspace(0,oS.maxphi2,nsec);
      oS.Phi = get_option(varargin,'Phi',oS.Phi,'double');

      oS.updateTol(oS.Phi);
      
    end

    function ori = makeGrid(oS,varargin)

      res = get_option(varargin,'resolution',2.5*degree);
      phi1 = linspace(0,oS.maxphi1,round(oS.maxphi1/res)+1);
      phi2 = linspace(0,oS.maxphi2,round(oS.maxphi2/res)+1);
      [phi1,phi2] = meshgrid(phi1,phi2);
      oS.plotGrid.phi1 = phi1;
      oS.plotGrid.phi2 = phi2;
      oS.gridSize = (0:numel(oS.Phi)) * numel(phi1);
      phi1 = repmat(phi1,[1,1,numel(oS.Phi)]);
      phi2 = repmat(phi2,[1,1,numel(oS.Phi)]);
      Phi = repmat(reshape(oS.Phi,1,1,[]),[size(oS.plotGrid.phi1) 1]);

      ori = orientation.byEuler(phi1,Phi,phi2,'Bunge',oS.CS,oS.SS); %#ok<*PROPLC>

    end

    function n = numSections(oS)
      n = numel(oS.Phi);
    end

    function [S2Pos,secPos] = project(oS,ori,varargin)

      ori = ori.symmetrise('proper').';
      [phi1,Phi,phi2] = Euler(ori,'Bunge');

      secPos = oS.secList(Phi,oS.Phi);
      S2Pos = struct('phi1',phi1,'phi2',phi2);

    end

    function ori = iproject(oS,phi1,Phi,iphi2)
      ori = orientation.byEuler(phi1,Phi,oS.phi2(iphi2),'Bunge',oS.CS,oS.SS);
    end

    function h = plotSection(oS,ax,sec,v,data,varargin)

      % plot data
      if min(size(v.phi1)) > 1
        h = contourf(v.phi1 ./ degree,v.phi2 ./ degree,reshape(data{1},size(v.phi1)),'parent',ax);
        set(ax,'DataAspectRatio',[1 1 1]);
        xlabel(ax,'\phi_1');
        ylabel(ax,'\phi_2');
      else
        patchArgs = {'parent',ax,...
          'vertices',[v.phi1(:) v.phi2(:)] ./ degree,...
          'faces',1:numel(v.phi1),...
          'facecolor','none',...
          'edgecolor','none',...
          'marker','o',...
          'markerFaceColor','b',...
          };
        h = optiondraw(patch(patchArgs{:}),varargin{:});
        set(ax,'DataAspectRatio',[1 1 1],'box','on');
        axis(ax,'on')
        xlim(ax,[0,oS.maxphi1]./degree);
        ylim(ax,[0,oS.maxphi2]./degree);
        xlabel(ax,'\phi_1');
        ylabel(ax,'\phi_2');
      end
    end
  end
end
