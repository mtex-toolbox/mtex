classdef S2FunTri < S2Fun
% a class represeneting a function on the sphere
  
  properties
    tri          % S2Triangulation
    values = []  % function values
  end
  
  properties (Dependent = true)
    vertices
  end
  
  methods
    
    function sF = S2FunTri(n,v)      
      % initialize a spherical function
      
      sF.values = v;
      
      if isa(n,'tririangulation')
        sF.tri = n;
      else
        sF.tri = S2Triangulation(n);
      end
    end
    
    function v = get.vertices(S2F)
      v = S2F.tri.vertices;
    end
    
    function S2F = set.vertices(S2F,v)
      S2F.tri.vertices = v;
      S2F.tri.update;
    end

  end    

  
  methods (Static = true)
    
    function sF = demo
      
      %mtexdata dubna;
      
      %sF = S2Fun(pf({1}).r,pf({1}).intensities);
      
      %plot(sF,'upper');
       
      odf = SantaFe;
      
      v = equispacedS2Grid('points',1000);
      
      values = odf.calcPDF(Miller(1,0,0,odf.CS),v);
      
      sF = S2FunTri(v,values)
      
      plot(sF,'upper')
      
    end
  end
end
  



