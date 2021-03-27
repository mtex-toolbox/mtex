classdef microstructure < handle
  % abstract representation of a microstruture

  properties % field may be empty if unknown or not important
    ebsd     % full EBSD data set
    grains   % grains 
    odf      % 
    ori      % discrete orientations representing the texture
    ellipses % as table with a, b, angle
    sigma    % internal stress
    dislocationDensity
    T        % temperature distribution
  end
  
  properties (Dependent = true)
    CSList % phase list
  end
  
  methods

    writePlasticity2VPSC(this,path)
    writeMicrostructure2VPSC(this,path)
    
  end
  
end
  