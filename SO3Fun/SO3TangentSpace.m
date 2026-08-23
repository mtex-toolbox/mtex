classdef SO3TangentSpace < int32
% class representing the different types of SO3 tangent space
%
% A tangent vector on SO(3) is only defined together with the side it is
% taken on: left, i.e. in specimen coordinates, or right, i.e. in crystal
% coordinates, and either as a @vector3d or as a @spinTensor. This
% enumeration is how that choice is passed around, and the sign of its
% value tells left from right.
%
% Syntax
%   tS = SO3TangentSpace.leftVector
%   SO3VF = SO3VectorFieldHandle(fun,SO3TangentSpace.rightVector)
%
% Class Properties
%  leftVector, rightVector, leftSpinTensor, rightSpinTensor - the members
%
% See also
% SO3VectorField SO3TangentVector spinTensor
%
  
  enumeration
    leftVector    (1)
    rightVector   (-1)
    leftSpinTensor (2)
    rightSpinTensor (-2)     
  end
  
  methods
    
    function out = isLeft(this)
      out = this > 0;
    end

    function out = isRight(this)
      out = this < 0;
    end

    function out = isVector(this)
      out = abs(this)==1;
    end

    function out = isSpinTensor(this)
      out = abs(this)==2;
    end

    function tS = uminus(tS)
      tS = SO3TangentSpace(-double(tS));
    end

    function tS = abs(tS)
      tS = SO3TangentSpace(abs(double(tS)));
    end
        
  end

  methods (Static=true)

    function tS = extract(varargin)
      
      % allow SO3TangentSpace.extract(varargin)
      if isscalar(varargin) && isa(varargin{1},'cell')
        varargin = varargin{:};
      end

      tS = getClass(varargin,'SO3TangentSpace');

      if ~isempty(tS), return; end
      
      if check_option(varargin,'right')
        tS = SO3TangentSpace.rightVector;
      else
        tS = SO3TangentSpace.leftVector;
      end
    end

  end
  
end