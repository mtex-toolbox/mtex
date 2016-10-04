classdef sphVectorField < sphTriangulation
% a class represeneting a function on the sphere
  
  properties
    vec = []  % function values
  end
  
  methods
    
    function sVF = sphVectorField(n,v)      
      % initialize a spherical vector field
      
      sVF.vec = v;
      
      if isa(n,'sphTriangulation')
      
        sVF.vertices = n.vertices;
        sVF.edges = n.edges;
        sVF.T= n.T;
        sVF.A_V= n.A_V;
        sVF.neighbours = n.neighbours;
        
      else
        sVF.vertices = n;
        sVF = sVF.update;
      end
      
           
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
  



