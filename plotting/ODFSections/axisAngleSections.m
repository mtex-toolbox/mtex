classdef axisAngleSections < ODFSections
  
  properties
    angles
    axesSectors 
    jointCS
    oR
  end
    
  methods
    
    function oS = axisAngleSections(CS1,CS2,varargin)
      
      oS = oS@ODFSections(CS1,CS2);
      oS.CS1 = CS1.properGroup;
      oS.CS2 = CS2.properGroup;
      oS.jointCS = disjoint(oS.CS1,oS.CS2);      
      if check_option(varargin,'antipodal')
        oS.jointCS = oS.jointCS.Laue;
      end
      oS.oR = fundamentalRegion(oS.CS1,oS.CS2,varargin{:});
      
      % get sections      
      oS.angles = get_option(varargin,'axisAngle',(5:10:180)*degree,'double');
      oS.angles(oS.angles>oS.oR.maxAngle) = [];

      for s=1:length(oS.angles)
        oS.axesSectors{s} = oS.oR.axisSector(oS.angles(s));
      end
      
    end
    
    function ori = makeGrid(oS,varargin)
      ori = orientation(oS.CS1,oS.CS2);
      oS.gridSize(1) = 0;
      for s = 1:length(oS.angles)
        sR = fundamentalSector(oS.jointCS,varargin{:},'angle',oS.angles(s));
        oS.plotGrid{s} = plotS2Grid(sR,varargin{:});
        oS.gridSize(s+1) = oS.gridSize(s) + length(oS.plotGrid{s});
        ori(1+oS.gridSize(s):oS.gridSize(s+1)) = ...
          orientation('axis',oS.plotGrid{s},'angle',oS.angles(s),oS.CS1,oS.CS2);
      end     
    end

    function n = numSections(oS)
      n = numel(oS.angles);
    end
    
    function [S2Pos,secPos] = project(oS,ori,varargin)
    
      % symmetrise
      if check_option(varargin,'complete')
        ori = quaternion(ori.symmetrise('proper'));
      else
        ori = quaternion(ori.project2FundamentalRegion);
      end

      S2Pos = ori.axis;
      angle = ori.angle;
      
      % this builds a list 
      bounds = sort(unique([oS.angles - oS.tol,oS.angles + oS.tol]));
      [~,secPos] = histc(angle,bounds);
      secPos(iseven(secPos)) = -1;
      secPos = (secPos + 1)./2;
      
    end
    
    function ori = iproject(oS,rho,theta,iangle)
      ori = orientation('axis',vector3d('polar',theta,rho),'angle',...
        oS.angles(iangle),oS.CS,oS.SS);
    end
        
    function h = plotSection(oS,ax,sec,v,data,varargin)
      
      angle = oS.angles(sec);
      
      % plot outer boundary
      if isempty(findall(ax,'tag','outerBoundary'))
        plot(fundamentalSector(oS.jointCS,varargin{:}),'parent',ax,...
          'TL',['\omega = ' int2str(oS.angles(sec)./degree),'^\circ'],'color',[0.8 0.8 0.8],...
          'doNotDraw','tag','outerBoundary','hitTest','off');
      end
        
      % rescale the axes according to actual volume      
      sP = getappdata(ax,'sphericalPlot');
      bounds = sP.bounds * sin(max(oS.angles)/2) / sin(angle/2);
      set(ax,'xlim',bounds([1,3]),'ylim',bounds([2,4]))
          
      hold on
                  
      % plot data 
      h = plot(v,data{:},'parent',ax,varargin{:},'doNotDraw');
      
      % plot inner boundary
      if isempty(findall(ax,'tag','innerBoundary'))
        varargin = extract_option(varargin,{'color'});
        plot(oS.axesSectors{sec},'parent',ax,'color','k',varargin{:},...
          'doNotDraw','tag','innerBoundary','hitTest','off');
      end
      hold off

    end
  end
end
