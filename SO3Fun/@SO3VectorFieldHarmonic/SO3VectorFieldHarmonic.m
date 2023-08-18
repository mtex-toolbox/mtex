classdef (InferiorClasses = {?SO3FunBingham,?SO3FunCBF,?SO3FunComposition, ...
    ?SO3FunHandle,?SO3FunHarmonic,?SO3FunHomochoric,?SO3FunRBF,?SO3FunSBF, ...
    ?SO3VectorFieldHandle,?vector3d}) SO3VectorFieldHarmonic < SO3VectorField
% a class representing left sided vector fields on the rotation group

properties
  SO3F
  SRight
  SLeft
  tangentSpace = 'left'
end

properties(Dependent = true)
  x
  y
  z
  bandwidth
  isReal
end

methods

  function SO3VF = SO3VectorFieldHarmonic(SO3F, varargin)
    % initialize a rotational vector field
    
    if nargin == 0, return; end
    
    if isa(SO3F,'SO3FunHarmonic')
      SO3VF.SO3F = SO3FunHarmonic(SO3F(:));
      % extract symmetry
      isSym = cellfun(@(x) isa(x,'symmetry'),varargin,'UniformOutput',true);
      [SRight,SLeft] = extractSym(varargin);
      if ~any(isSym), SRight=crystalSymmetry; end

      if check_option(varargin,'right')
        SO3VF.tangentSpace = 'right';
        SO3VF.SRight = SRight;
      else
        SO3VF.tangentSpace = 'left';
        SO3VF.SLeft = SLeft;
      end
      return
    end

    if isa(SO3F,'SO3VectorFieldHarmonic')
      SO3VF = SO3VectorFieldHarmonic(SO3F.SO3F,SO3F.CS,SO3F.SS,SO3F.tangentSpace);
      return
    end
    
    if isa(SO3F,'SO3VectorField')
      SO3VF = SO3VectorFieldHarmonic.quadrature(SO3F,varargin{:});
      return
    end
    error('Input should be of type SO3FunHarmonic or SO3VectorField.')

  end


  % -----------------------------------------------------------------------
  % Representation of the tangent space   and   Symmetries

  function SO3VF = set.tangentSpace(SO3VF,s)
    if strcmp(s,'left') && strcmp(SO3VF.tangentSpace,'right')
      SO3VF.tangentSpace = s;
      SO3VF.SLeft = specimenSymmetry;
      if length(SO3VF.SLeft.rot)>1
        warning('You may loose symmetry.')
      end
    elseif strcmp(s,'right') && strcmp(SO3VF.tangentSpace,'left')
      SO3VF.tangentSpace = s;
      SO3VF.SRight = crystalSymmetry;
      if length(SO3VF.SRight.rot)>1
        warning('You may loose symmetry.')
      end
    end
  end


  function SRight = get.SRight(SO3VF)
    if strcmp(SO3VF.tangentSpace,'left')
      SRight = SO3VF.SO3F.SRight;
    else
      SRight = SO3VF.SRight;
    end
  end
  function SO3VF = set.SRight(SO3VF,SRight)
    if strcmp(SO3VF.tangentSpace,'left')
      SO3VF.SO3F.SRight = SRight;
    else
      SO3VF.SRight = SRight;
    end
  end
  function SLeft = get.SLeft(SO3VF)
    if strcmp(SO3VF.tangentSpace,'right')
      SLeft = SO3VF.SO3F.SLeft;
    else
      SLeft = SO3VF.SLeft;
    end
  end
  function SO3VF = set.SLeft(SO3VF,SLeft)
    if strcmp(SO3VF.tangentSpace,'right')
      SO3VF.SO3F.SLeft = SLeft;
    else
      SO3VF.SLeft = SLeft;
    end
  end

  % -----------------------------------------------------------------------

  function bw = get.bandwidth(SO3VF), bw = SO3VF.SO3F.bandwidth; end
  function SO3VF = set.bandwidth(SO3VF,bw), SO3VF.SO3F.bandwidth = bw; end
  
  function x = get.x(SO3VF), x = SO3VF.SO3F(1); end
  function y = get.y(SO3VF), y = SO3VF.SO3F(2); end
  function z = get.z(SO3VF), z = SO3VF.SO3F(3); end
  function SO3VF = set.x(SO3VF, x), SO3VF.SO3F(1) = x; end
  function SO3VF = set.y(SO3VF, y), SO3VF.SO3F(2) = y; end
  function SO3VF = set.z(SO3VF, z), SO3VF.SO3F(3) = z; end

  function r = get.isReal(SO3VF), r = SO3VF.SO3F.isReal; end  
  function SO3VF = set.isReal(SO3VF,r), SO3VF.SO3F.isReal = r; end
  
end

methods(Static = true)
  SO3VF = quadrature(f, varargin)
  SO3VF = approximation(f, varargin)
end

end
