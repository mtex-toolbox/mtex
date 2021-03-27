classdef deformationModel < handle
% describes the imposed outer deformation as a function of time


  properties
    t % time steps
    L % velocity gradient tensor for each time step
      % it would be nice to have a method to compute L(t) from a given
      % deformation gradient tensor
    T % temperature at time t
    bndConditions % not sure how to store this
    sigma         % external stress at the boundaries    
  end
  
  methods
    % it would be funny to have some interpolation function
    % 
  end
  
  
  
end
  