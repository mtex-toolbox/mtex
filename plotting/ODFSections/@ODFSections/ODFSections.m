classdef ODFSections < handle
  %ODFSECTIONS Summary of this class goes here
  %   Detailed explanation goes here
  %
  % Example
  %
  %   cs = crystalSymmetry('mmm')
  %   oS = axisAngleSections(cs,cs)
  %   ori = oS.makeGrid('resolution');
  %   oM = patalaOrientationMapping(cs,cs)
  %   rgb = oM.orientation2color(ori);
  %   plot(oS,rgb,'surf')
  %
  %   plot(oS,ori)
  %
  %   ori = orientation(randq(100),cs,cs)
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
    
  methods
    function oS = ODFSections(CS1,varargin)
      oS.CS1 = CS1.properGroup;
      CS2 = getClass(varargin,'symmetry',specimenSymmetry);
      oS.CS2 = CS2.properGroup;
      oS.tol = get_option(varargin,'tolerance',5*degree);
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
            
      bounds = [center(:) - oS.tol,center(:) + oS.tol];
      
      % ensure disjoint boxes
      ind = find(bounds(1:end-1,2) + eps >= bounds(2:end,1));
      bounds(ind,2) = (2*center(ind) + 1 * center(ind+1)) ./ 3;
      bounds(ind+1,1) = (center(ind) + 2 * center(ind+1)) ./ 3;
                 
      % compute box position
      [~,secPos] = histc(values,reshape(bounds.',[],1));
      secPos(iseven(secPos)) = -1;
      secPos = (secPos + 1)./2;
    end  
  end
  
end
