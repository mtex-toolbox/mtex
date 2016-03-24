classdef stressTensor < tensor
  
  methods
    function sT = stressTensor(varargin)

      sT = sT@tensor(varargin{:},'name','stress');
      
    end
  end
  
   
  methods (Static = true)
    
    function sT = uniaxial(v)
      % define uniaxial stress tensor
      %
      % Syntax
      %   sT = stressTensor.uniaxial(v)
      %
      % Input
      %  v - @vector3d
      %
      % Output
      %  sT - @stressTensor
      %
           
      T = EinsteinSum(tensor(v),1,v,2);
      sT = stressTensor(T);

   end
  end
end