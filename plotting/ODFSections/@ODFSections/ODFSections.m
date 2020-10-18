classdef ODFSections < handle
  %ODFSECTIONS Summary of this class goes here
  %   Detailed explanation goes here
  %
  % Example
  %
  %   cs = crystalSymmetry('222')
  %   oS = axisAngleSections(cs,cs);
  %   ori = oS.makeGrid('resolution',2.5*degree);
  %   oM = PatalaColorKey(cs,cs)
  %   rgb = oM.orientation2color(ori);
  %   plot(oS,rgb,'surf')
  %
  %   ori = orientation.rand(100,cs,cs)
  %   plot(oS,ori)
  
  properties
    CS1 % crystal symmetry of phase 1
    CS2 % crystal symmetry of phase 2
    tol % tolerance
    plotGrid
    gridSize
  end
  
  properties (Dependent=true)
    CS % crystal symmetry
    SS % specimen symmetry
  end
   
  properties (Access = protected)
    upperAndLower = false % whether upper AND lower hemispheres are displayed
  end
  
  methods
    function oS = ODFSections(CS1,varargin)
      CS2 = getClass(varargin,'symmetry',specimenSymmetry);
      if check_option(varargin,'pointGroup')
        oS.CS1 = CS1;
        oS.CS2 = CS2;
      else
        oS.CS1 = CS1.properGroup;
        oS.CS2 = CS2.properGroup;
      end
      oS.tol = get_option(varargin,'tolerance',5*degree);
    end
    
    function updateTol(oS,secAngles)
      oS.tol = min([2.1*oS.tol;abs(diff(secAngles(:)))])./2.1;
    end
        
    function CS = get.CS(oS), CS = oS.CS1; end
    function SS = get.SS(oS), SS = oS.CS2; end    
  end

  methods (Abstract = true)
    makeGrid(oS,varargin)
    [S2Pos,secPos] = project(oS,ori)
    ori = iproject(oS,rho,theta,secAngle)
    h = plotSection(oS,ax,sec,v,data,varargin)
    n = numSections(oS)
  end
  
  methods (Hidden = true)
    function secPos = secList(oS, values, center)
      
      % ensure disjoint boxes
      if length(center)>1 && min(abs(diff(center))) <= 2*oS.tol
        oS.tol = 0.99*min(diff(center))/2;
      end      
      bounds = [center(:) - oS.tol,center(:) + oS.tol];
          
      %ind = find(bounds(1:end-1,2) + eps >= bounds(2:end,1));
      %bounds(ind,2) = (5*center(ind) + 4 * center(ind+1)) ./ 9;
      %bounds(ind+1,1) = (4*center(ind) + 5 * center(ind+1)) ./ 9;
                 
      % must pay special attention to the case center == 0
      if min(center(:)) <= oS.tol
        values = mod(values+oS.tol,2*pi)-oS.tol;
      end
      
      % compute box position
      [~,~,secPos] = histcounts(values,reshape(bounds.',[],1));
      secPos(iseven(secPos)) = -1;
      secPos = (secPos + 1)./2;
    end  
  end
  
end
