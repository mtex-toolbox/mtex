classdef plasticSimulation < handle
  % represents the entire simulation, i.e, parameters, initial texture, result

  properties
    method      % Taylor, affine, secant, second order, vp
    deformation % deformation model
    plasticity  % array of plasticityModels - one for each phase
    microstructure % homogenized representation of the microstructor - time dependet array
  end
  
  properties (Dependent = true)
    CSList % phase list
  end
  
  methods

    writePlasticity2VPSC(this,path)
    writeMicrostructure2VPSC(this,path)
    
  end
  
end
  