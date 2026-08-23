classdef SO3Fun < dynOption
% an abstract class representing functions on the rotation group
%
% SO3Fun is the common interface of all representations of a function on
% SO(3), most prominently an ODF. Two symmetries act on it, SRight from
% the crystal side and SLeft from the specimen side, and each contributes
% the @referenceFrame of that side.
%
% Deriving classes only have to implement the method eval, everything else
% - arithmetics, plotting, pole figures, texture characteristics - is
% inherited from here.
%
% Class Properties
%  SRight, CS - @symmetry acting from the right, the crystal side
%  SLeft, SS  - @symmetry acting from the left, the specimen side
%  antipodal  - grain exchange symmetry
%  bandwidth  - maximum harmonic degree
%  isReal     - the function takes only real values
%  frameLeft  - @referenceFrame of SLeft, read only
%  frameRight - @referenceFrame of SRight, read only
%
% Derived Classes
%  @SO3FunHarmonic    - harmonic series on SO(3)
%  @SO3FunRBF         - superposition of radial basis functions
%  @SO3FunCBF         - superposition of fibre components
%  @SO3FunBingham     - Bingham distribution
%  @SO3FunHandle      - function given by a function handle
%  @SO3FunHomochoric  - values on a homochoric grid
%  @SO3FunComposition - sum of several SO3Fun
%  @SO3FunSBF         - deformation texture from strain and slip systems
%
% See also
% SO3FunHarmonic SO3FunRBF SO3FunHandle

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