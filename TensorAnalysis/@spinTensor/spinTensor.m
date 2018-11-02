classdef spinTensor < tensor
  
  methods
    function Omega = spinTensor(varargin)
      Omega = Omega@tensor(varargin{:},'rank',2);
      Omega = Omega.antiSym;
    end    

    function rot = rotation(Omega)
      
      rot = rotation(expquat(Omega));
      
    end
    
    function rot = exp(Omega)
      rot = rotation(Omega);
    end
    
    
  end
  

end
