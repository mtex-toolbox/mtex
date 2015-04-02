classdef ODFSections < handle
  %ODFSECTIONS Summary of this class goes here
  %   Detailed explanation goes here
  %
  % oS = ODFSections(CS1,CS2)
  % oS.makeGrid('resolution',5*degree);
  % f = eval(odf,oS.grid)
  % plot(oS,f,'surf')
  %
  % plot(oS,ori)
  %
  
  
  properties
    CS1 % crystal symmetry 1
    CS2 % crystal symmetry 2 or specimen symmetry
    
    sR % list of spherical regions of each section
    ax % list of axes  
  end
  
  properties (Dependent=true)
    CS
    SS
  end
    
  methods
    function oS = ODFSections(CS1,CS2)
      oS.CS1 = CS1;
      oS.CS2 = CS2;
    end
    
    
    function plot(oS,varargin)
      if nargin > 1 && isnumeric(varargin{1})
        plotGrid(oS,varargin{:})
      else
        plotOri(oS,varargin{:});
      end
    end
    
    function plotOri(oS,ori,varargin)
      for i = 1:numel(oS.ax)
        
      end
    end       
    
    function CS = get.CS(oS), CS = oS.CS1; end
    function SS = get.SS(oS), SS = oS.CS2; end
    
  end

  methods (Abstract = true)
    generateGrid(oS,varargin)
    [S2Pos,secPos] = project(oS,ori)
  end
  
end
