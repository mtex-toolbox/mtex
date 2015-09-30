classdef ODFSections < handle
  %ODFSECTIONS Summary of this class goes here
  %   Detailed explanation goes here
  %
  % Example 1
  %
  % cs = crystalSymmetry('mmm')
  % oS = axisAngleSections(cs,cs)
  % ori = oS.makeGrid('resolution');
  % oM = patalaOrientationMapping(cs,cs)
  % rgb = oM.orientation2color(ori);
  % plot(oS,rgb,'surf')
  %
  % plot(oS,ori)
  %
  % ori = orientation(randq(100),cs,cs)
  % plot(oS,ori)
  
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
    function oS = ODFSections(CS1,CS2,varargin)
      oS.CS1 = CS1.properGroup;
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
  
end
