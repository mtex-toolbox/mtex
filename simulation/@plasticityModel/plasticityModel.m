classdef plasticityModel < handle
  
  properties
    slipSystems
    twinSystems
    C            % stiffness tensor
    alpha        % thermal expansion coefficient
  end
  
  properties (Dependent = true)
    CS
  end
  
  
end
  