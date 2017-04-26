classdef axisAngleSections < ODFSections
  
  properties
    angles
    axesSectors 
    jointCS
    oR
    volumeScaling
  end
    
  methods
    
    function oS = axisAngleSections(varargin)
      % defines an axis angle section
      
      oS = oS@ODFSections(varargin{:});
      oS.jointCS = properGroup(disjoint(oS.CS1,oS.CS2));
      if check_option(varargin,'antipodal')
        oS.jointCS = oS.jointCS.Laue;
      end
      oS.oR = fundamentalRegion(oS.CS1,oS.CS2,varargin{:});
      oS.volumeScaling = get_option(varargin,'volumeScaling',true);
      
      % get sections
      if check_option(varargin,'sections')
         omega = linspace(0,oS.oR.maxAngle, 1+get_option(varargin,'sections'));
        oS.angles = 0.5*(omega(1:end-1) + omega(2:end));
      else
        oS.angles = get_option(varargin,'axisAngle',(5:10:180)*degree,'double');
        oS.angles(oS.angles>oS.oR.maxAngle) = [];
      end
      for s=1:length(oS.angles)
        oS.axesSectors{s} = oS.oR.axisSector(oS.angles(s));
      end
      
    end
    
    function ori = makeGrid(oS,varargin)
      ori = orientation(oS.CS1,oS.CS2);
      oS.gridSize(1) = 0;
      for s = 1:length(oS.angles)
        sR = oS.oR.axisSector(oS.angles(s));
        
        % consider only upper as we can't plot more
        % TODO: we may need to inform the user about this
        sR = sR.restrict2Upper;
        
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
      secPos = oS.secList(ori.angle,oS.angles);
      
    end
    
    function ori = iproject(oS,rho,theta,iangle)
      ori = orientation('axis',vector3d('polar',theta,rho),'angle',...
        oS.angles(iangle),oS.CS,oS.SS);
    end
        
    function h = plotSection(oS,ax,sec,v,data,varargin)
      
      angle = oS.angles(sec);
      
      % plot outer boundary
      if isempty(findall(ax,'tag','outerBoundary'))
        opt = oS.jointCS.plotOptions;
        plot(fundamentalSector(oS.jointCS,varargin{:}),'parent',ax,...
          'TR',['\omega = ' int2str(oS.angles(sec)./degree),'^\circ'],'color',[0.8 0.8 0.8],...
          'doNotDraw','tag','outerBoundary','noLabel',...
          'xAxisDirection','east','zAxisDirection','outOfPlane','hitTest','off',opt{:});
      end
      
      % rescale the axes according to actual volume      
      if oS.volumeScaling
        sP = getappdata(ax,'sphericalPlot');
        bounds = sP.bounds * sin(max(oS.angles)/2) / sin(angle/2);
        set(ax,'xlim',bounds([1,3]),'ylim',bounds([2,4]))
      end
          
      hold on
                  
      % plot data
      %v(~oS.axesSectors{sec}.checkInside(v)) = vector3d.nan;
      v.opt.region = oS.axesSectors{sec};
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
