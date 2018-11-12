classdef spinTensor < tensor
  
  methods
    function Omega = spinTensor(varargin)
      Omega = Omega@tensor(varargin{:},'rank',2);
      Omega = Omega.antiSym;
    end    

    function v = vector3d(Omega)
      v = vector3d(Omega.M(3,2,:),-Omega.M(3,1,:),Omega.M(2,1,:));
    end
    
    
    function rot = rotation(Omega)
      
      rot = rotation(expquat(Omega));
      
    end
    
    function rot = orientation(Omega)
      
      if isa(Omega.CS,'crystalSymmetry')
        rot = orientation(expquat(Omega),Omega.CS,Omega.CS);
      else
        rot = rotation(expquat(Omega));
      end
      
    end
    
    function rot = exp(Omega)
      rot = orientation(Omega);
    end
    
    function omega = angle(Omega)
      
      omega = reshape(sqrt(Omega.M(2,1,:).^2 + Omega.M(3,1,:).^2 + Omega.M(3,2,:).^2),size(Omega));
      
    end
    
    
  end
  

end

