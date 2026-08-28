classdef SO3Fun < dynOption
% an abstract class representing functions on the rotation group
%
% SO3Fun is the common interface of all representations of a function on
% SO(3), most prominently an ODF. It relates two reference frames, named
% by position the way an @orientation names them: A is the frame its
% argument maps from, the crystal side, B the one it maps into, the
% specimen side. The group acting from each side is the one that frame
% carries.
%
% Deriving classes only have to implement the method eval, everything else
% - arithmetics, plotting, pole figures, texture characteristics - is
% inherited from here.
%
% Class Properties
%  frameA     - @referenceFrame of the crystal side, acting from the right
%  frameB     - @referenceFrame of the specimen side, acting from the left
%  SRight, CS - the frame of the crystal side, positionally A
%  SLeft, SS  - the frame of the specimen side, positionally B
%  antipodal  - grain exchange symmetry
%  bandwidth  - maximum harmonic degree
%  isReal     - the function takes only real values
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
    frameA    % the frame the argument is given in, acting from the right
    frameB    % the frame the argument maps into, acting from the left
    antipodal % grain exchange symmetry
    bandwidth %
    isReal
  end

  properties (Dependent = true)
    CS     % the frame of the crystal side - positionally A, see frameA
    SS     % the frame of the specimen side - positionally B, see frameB
    SRight % the frame acting from the right, which is A
    SLeft  % the frame acting from the left, which is B
  end

  methods

    % the four older names resolve positionally, which is what they have
    % always meant - the group of a side is the one its frame carries
    function fr = get.CS(SO3F), fr = SO3F.frameA; end
    function fr = get.SS(SO3F), fr = SO3F.frameB; end
    function fr = get.SRight(SO3F), fr = SO3F.frameA; end
    function fr = get.SLeft(SO3F), fr = SO3F.frameB; end

    function SO3F = set.CS(SO3F,fr), SO3F.frameA = fr; end
    function SO3F = set.SS(SO3F,fr), SO3F.frameB = fr; end
    function SO3F = set.SRight(SO3F,fr), SO3F.frameA = fr; end
    function SO3F = set.SLeft(SO3F,fr), SO3F.frameB = fr; end

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