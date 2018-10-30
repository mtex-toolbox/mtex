classdef refractiveIndexTensor < tensor
  
  
  methods
    
    
    function rI = refractiveIndexTensor(varargin)
      rI = rI@tensor(varargin{:},'rank',2);
      
      % TODO: set up the unit correctly !!!
      
    end
    
    
  end
  
  
  methods (Static = true)
    function rI = calcite
      cs = crystalSymmetry('-3m1',[5,5,17],'mineral','Calcite','X||a');
      rI = refractiveIndexTensor(diag([1.66 1.66 1.486]),cs);
    end
    
    function rI = olivin
      cs = loadCIF('olivin.cif');
      rI = refractiveIndexTensor(diag([1.640 1.660 1.680]),cs);
    end
    
    function test
      rI = refractiveIndexTensor.calcite;
      
      vprop = plotS2Grid;
      
      figure(1)
      n = rI.birefringence(vprop);
      
      plot3d(vprop,n)
      
      figure(2)
      thickness = 10000;
      rgb = spectralTransmission(rI,vprop,thickness);
      plot3d(vprop,rgb./100)
      
    end
    
    function test2
      mtexdata fo
      
      rI = refractiveIndexTensor.olivin;
      
      oM = spectralTransmissionColorKey(rI,1000);
      oM.polarizer = vector3d.Y;
      
      plot(ebsd('fo'),oM.orientation2color(ebsd('fo').orientations)./100)
      
    end
    
    
  end

end