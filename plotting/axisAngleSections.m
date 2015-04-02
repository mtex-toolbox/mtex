classdef axisAngleSections < ODFSections
  
  properties
    angles
    axesSectors    
  end
    
  methods
    
    function oS = axisAngleSections(CS1,CS2,varargin)
      
      oS = oS@ODFSections(CS1,CS2);
      
      % get sections
      if check_option(varargin,{'omega','angles'})
        oS.angles = get_option(varargin,{'omega','angles'});
      else
        oS.angles = (5:10:180)*degree;
        oS.angles(oS.angles>maxAngle(oS.CS1,oS.CS2)) = [];
      end
      
    end
    
    function ori = makeGrid(oS,varargin)
      ori = orientation(oS.CS1,oS.CS2);
      oS.gridSize(1) = 0;
      for s = 1:length(oS.angles)
        sR = fundamentalSector(oS.CS,oS.CS2,'angle',oS.angles(s));
        oS.plotGrid{s} = plotS2Grid(sR,varargin{:});
        oS.gridSize(s+1) = oS.gridSize(s) + length(oS.plotGrid{s});
        ori(1+oS.gridSize(s):oS.gridSize(s+1)) = ...
          orientation('axis',oS.plotGrid{s},'angle',oS.angles(s));
      end     
    end

    function n = numSections(oS)
      n = numel(oS.angles);
    end
    
    function [S2Pos,secPos] = project(oS,ori)
    
      S2Pos = ori.axis;
      
      % this builds a list 
      bounds = sort(unique([oS.angles - oS.tol,oS.angles + oS.tol]));
      [~,secPos] = histc(ori.angle,bounds);
      secPos(iseven(secPos)) = -1;
      secPos = (secPos + 1)./2;
      
    end
        
    function h = plotSection(oS,ax,sec,v,data,varargin)
      
      angle = oS.angles(sec);
      
      % plot outer boundary
      plot(fundamentalSector(oS.CS1.Laue,oS.CS2.Laue),'parent',ax,...
        'TR',[int2str(oS.angles(sec)./degree),'^\circ'],'color',[0.8 0.8 0.8],'doNotDraw');
        
      % rescale the axes according to actual volume
      x = get(ax,'xLim');
      y = get(ax,'yLim');
      x = x .* sin(max(oS.angles)/2) / sin(angle/2);
      y = y .* sin(max(oS.angles)/2) / sin(angle/2);
      xlim(ax,x);
      ylim(ax,y);
    
      hold on
      sRSec = fundamentalSector(oS.CS1.Laue,oS.CS2.Laue,'angle',angle);
      % plot inner boundary
      plot(sRSec,'parent',ax,'color','k',varargin{:},'doNotDraw');
      
      % plot data
      h = plot(v,data{:},sRSec,'parent',ax,varargin{:},'doNotDraw','symmetrised');
      hold off

    end
  end
end
