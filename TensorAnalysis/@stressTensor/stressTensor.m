classdef stressTensor < tensor
  
  methods
    function sT = stressTensor(varargin)

      sT = sT@tensor(varargin{:},'rank',2);
      
    end
  end
  
   
  methods (Static = true)

    function sigma = load(varargin)
      T = load@tensor(varargin{:});
      sigma = stressTensor(T);
    end
    
    function sigma = uniaxial(v)
      % define uniaxial stress tensor
      %
      % Syntax
      %   sigma = stressTensor.uniaxial(v)
      %
      % Input
      %  v - @vector3d loading direction
      %
      % Output
      %  sigma - @stressTensor
      %
           
      sigma = stressTensor(dyad(v,2));

    end
   
    function sigma = rand(varargin)
      t = tensor.rand(varargin{:},'rank',2);
      sigma = stressTensor(t.sym);
    end

  end
end