classdef SO3Fun < dynOption
% a class representing functions on the rotational group

  properties (Abstract = true)
    SLeft     % symmetry that acts from the left
    SRight    % symmetry that acts from the right
    antipodal % grain exchange symmetry
    bandwidth % 
  end    
  
  properties (Dependent = true)
    CS
    SS 
  end
  
  methods
        
    function CS = get.CS(SO3F)
      CS = SO3F.SRight;
    end
    
    function SS = get.SS(SO3F)
      SS = SO3F.SLeft;
    end
    
    function SO3F = set.CS(SO3F,CS)
      SO3F.SRight = CS;
    end
    
    function SO3F = set.SS(SO3F,SS)
      SO3F.SLeft = SS;
    end
    
  end
  
  methods (Hidden = true)
    function str = symChar(SO3F)
      %str = [char(SO3F.CS,'compact') ' ' char([55358 56342]) ' ' char(SO3F.SS,'compact')];
      str = [char(SO3F.CS,'compact') ' ' char(8594) ' ' char(SO3F.SS,'compact')];
    end
  end
  
  methods (Abstract = true)
    
    f = eval(F,v,varargin)
    
  end
  
  methods (Static = true)
  
    [SO3F,interface,options] = load(fname,varargin)
    SO3F = dubna(varargin)
    SO3F = interpolate(ori,values,varargin)
    
  end

end