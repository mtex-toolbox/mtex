classdef S2FunTri < S2Fun
% a class represeneting a function on the sphere
  
  properties
    tri          % S2Triangulation
    values = []  % function values
  end
  
  properties (Dependent = true)
    vertices
    antipodal
  end
  
  methods
    
    function sF = S2FunTri(nodes,values)      
      % initialize a spherical function
      
      if isa(nodes,'function_handle')
        n = equispacedS2Grid('resolution',1.5*degree);
        values = nodes(n);
        nodes = n;
      end
            
      if isa(nodes,'S2Triangulation')
        sF.tri = nodes;
      else
        sF.tri = S2Triangulation(nodes);
      end
      
      sF.values = values;
    end
    
    function v = get.vertices(S2F)
      v = S2F.tri.vertices;
    end
    
    function v = get.antipodal(S2F)
      v = S2F.tri.antipodal;
    end
    
    function S2F = set.vertices(S2F,v)
      if ~isempty(S2F.values), S2F.values = S2F.eval(v); end
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
  



