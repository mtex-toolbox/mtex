classdef SO3Fun < dynOption
% a class representing functions on the rotational group

  properties (Abstract = true)
    SLeft     % symmetry that acts from the left
    SRight    % symmetry that acts from the right
    antipodal % grain exchange symmetry
    bandwidth % 
    isReal
  end    
  
  properties (Dependent = true)
    CS
    SS
    frameLeft  % the reference frame of SLeft - the specimen side of an ODF
    frameRight % the reference frame of SRight - the crystal side of an ODF
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

    % the two frames of an SO3Fun are the frames of its symmetries, resolved live
    function fr = get.frameLeft(SO3F)
      fr = SO3F.SLeft.frame;
    end

    function fr = get.frameRight(SO3F)
      fr = SO3F.SRight.frame;
    end

    function SO3F = set.frameLeft(SO3F,~)
      error('MTEX:SO3Fun:fixedFrame',...
        ['The frames of an SO3Fun are the frames of its symmetries - ' ...
        'assign SLeft / SRight instead.']);
    end

    function SO3F = set.frameRight(SO3F,~)
      error('MTEX:SO3Fun:fixedFrame',...
        ['The frames of an SO3Fun are the frames of its symmetries - ' ...
        'assign SLeft / SRight instead.']);
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
    
  end

end