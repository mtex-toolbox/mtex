classdef SO3TangentSpace < int32
% class representing the different types of SO3Tangent space
  
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