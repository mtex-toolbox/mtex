classdef axisAngleSections < ODFSections
% sections of constant rotational angle for ODF and orientation plotting
%
% Every section is the axis sector belonging to one misorientation angle,
% so an orientation is placed at its rotational axis. Since that sector
% shrinks with the angle, the axes are rescaled by default to keep equal
% orientation volumes comparable.
%
% Syntax
%   oS = axisAngleSections(cs1,cs2)
%   oS = axisAngleSections(cs1,cs2,'sections',5)
%   oS = axisAngleSections(cs1,cs2,'axisAngle',(10:20:180)*degree)
%
% Input
%  cs1, cs2 - @crystalSymmetry, @specimenSymmetry
%
% Options
%  sections      - number of sections
%  axisAngle     - explicit section values
%  volumeScaling - rescale the axes by the volume of the section
%  antipodal     - grain exchange symmetry
%
% Class Properties
%  angles        - the rotational angle of each section
%  axesSectors   - the axis sector of each section
%  jointCS       - the joint proper @symmetry of cs1 and cs2
%  oR            - @orientationRegion of cs1 and cs2
%  volumeScaling - rescale the axes by the volume of the section
%
% Example
%
%   cs = crystalSymmetry('432');
%   oS = axisAngleSections(cs,cs)
%
% See also
% ODFSections sigmaSections SO3Fun/plotSection
%

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
      oS.upperAndLower = all(oS.oR.checkInside(axis2quat(zvector,[1,-1]*degree)));
      
      oS.volumeScaling = get_option(varargin,'volumeScaling',true);
      
      % get sections
      if check_option(varargin,'sections')
         omega = linspace(0,oS.oR.maxAngle, 1+get_option(varargin,'sections'));
        oS.angles = 0.5*(omega(1:end-1) + omega(2:end));
      else
        oS.angles = get_option(varargin,'axisAngle',(5:10:180)*degree,'double');
        oS.angles(oS.angles>oS.oR.maxAngle) = [];
      end
      
      oS.updateTol(oS.angles);
      
      for s=1:length(oS.angles)
        oS.axesSectors{s} = oS.oR.axisSector(oS.angles(s));
      end
      
    end
    
    function ori = makeGrid(oS,varargin)
      ori = orientation(oS.CS1,oS.CS2);
      oS.gridSize(1) = 0;
      for s = 1:length(oS.angles)
        % the sectors are computed once in the constructor - recomputing
        % them here costs as much as the grid itself
        oS.plotGrid{s} = plotS2Grid(oS.axesSectors{s},varargin{:});
        
        oS.gridSize(s+1) = oS.gridSize(s) + length(oS.plotGrid{s});
        ori(1+oS.gridSize(s):oS.gridSize(s+1)) = ...
          orientation.byAxisAngle(oS.plotGrid{s},oS.angles(s),oS.CS1,oS.CS2);
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
      if oS.upperAndLower
        iangle = any(reshape(iangle,2,[]));
      end
      ori = orientation.byAxisAngle(vector3d.byPolar(theta,rho),...
        oS.angles(iangle),oS.CS,oS.SS);
    end
        
    function h = plotSection(oS,ax,sec,v,data,varargin)
      
      % if plot not yet prepared
      if isempty(findall(ax,'tag','outerBoundary'))
        
        % plot outer boundary
        [~,cax] = plot(fundamentalSector(oS.jointCS,varargin{:}),'hold',...
          'TR',['\omega = ' xnum2str(oS.angles(sec)./degree,'precision',0.1),'^\circ'],'color',[0.8 0.8 0.8],...
          'tag','outerBoundary','noLabel',...
          'xAxisDirection','east','zAxisDirection','outOfPlane','hitTest','off',oS.jointCS.how2plot);
        
        % for all generated axes
        for ax = cax(:).'
        
          % rescale the axes according to actual volume
          angle = oS.angles(sec);
          if oS.volumeScaling
            sP = getappdata(ax,'sphericalPlot');
            bounds = sP.bounds * sin(max(oS.angles)/2) / sin(angle/2);
            set(ax,'xlim',bounds([1,3]),'ylim',bounds([2,4]))                        
          end
          
          % plot inner boundary
          if isempty(findall(ax,'tag','innerBoundary'))
            opt= extract_option(varargin,{'color'});
            plot(oS.axesSectors{sec},'parent',ax,'color','k',opt{:},...
              'tag','innerBoundary','hitTest','off');
          end
        end
        
      else
        cax = ax;
      end
            
      v.opt.region = oS.axesSectors{sec};
      
      % plot data into all axes - a disconnected sector needs more than one
      % graphics object per axes
      h = gobjects(1,0);
      for k = 1:length(cax)
        hk = plot(v,data{:},'parent',cax(k),varargin{:});
        h = [h,reshape(hk,1,[])]; %#ok<AGROW>
      end

    end
  end
end
