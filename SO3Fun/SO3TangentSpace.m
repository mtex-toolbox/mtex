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

    function toLeft(this,tV,ori_ref)

    end
        
  end

  methods (Static=true)

    function tS = extract(varargin)
      
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