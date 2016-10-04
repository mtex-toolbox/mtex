classdef sphFun < sphTriangulation
% a class represeneting a function on the sphere
  
  properties
    values = []  % function values
  end
  
  methods
    
    function sF = sphFun(n,v)      
      % initialize a spherical function
      
      sF.values = v;
      
      if isa(n,'sphTriangulation')
      
        sF.vertices = n.vertices;
        sF.edges = n.edges;
        sF.T= n.T;
        sF.A_V= n.A_V;
        sF.neighbours = n.neighbours;
        
      else
        sF.vertices = n;
        sF = sF.update;
      end

    end
    
    function value = entropy(sF1)
    end
  end    

  
  methods (Static = true)
    
    function demo
      
      %mtexdata dubna;
      
      %sF = sphFun(pf({1}).r,pf({1}).intensities);
      
      %plot(sF,'upper');
       
      odf = SantaFe;
      
      v = equispacedS2Grid('points',10000,'upper');
      
      values = odf.calcPDF(Miller(1,0,0,odf.CS),v);
      
      sF = sphFun(v,values)
      
      plot(sF,'upper')
      
    end
  end
end
  



