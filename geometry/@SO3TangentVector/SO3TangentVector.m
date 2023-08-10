classdef (InferiorClasses = {?vector3d}) SO3TangentVector < vector3d
% The left tangent space of SO(3) in some rotation R can be described by
% 
% $$ T_R(SO(3)) = \{ s\cdot R | s = -s^T \} $$
%
% where $s$ are skew symmetric matrices which means they look like 
%
% $$ \left(\begin{matrix} 0 & -c & b \\ c & 0 & -a \\ -b & a & 0 \end{matrix}\right).$$
%
% Hence we describe an element of of the tangent space T_R(SO(3)) by the 
% vector $(a,b,c)^T$ which in fact is an vector3d.
%
% Note that $ \{ R\cdot t | t = -t^T \} $ is another possible representation 
% of the tangent space. It is called right tangent space.
% 
% We denote whether an SO3TangentVector v is described w.r.t. the left tangent
% space or right tangent space by the property v.tangentSpace.
% Moreover we can change the representation of the tangentSpace by using
% the methods right(v) and left(v).
%
% Syntax
%   SO3TV = SO3TangentVector(x,y,z)
%   SO3TV = SO3TangentVector(v,'right')
%
% Input
%  x,y,z - cart. coordinates
%  v - @vector3d
%
% Output
%  SO3TV - @SO3TangentVector
%
% Options
%  left/right - describes the representation of the tangent space (default: left)
%
% See also
% vector3d.vector3d SO3VectorField.eval SO3VectorFieldHarmonic.eval
% SO3Fun.grad SO3FunHarmonic.grad

properties
  tangentSpace
end

methods

  function SO3TV = SO3TangentVector(varargin)
    % constructor
    v=[];
    if nargin>0 && isa(varargin{1},'vector3d')
      v = varargin{1};
      varargin = {v.x,v.y,v.z,varargin{2:end}};
    end

    SO3TV = SO3TV@vector3d(varargin{:});

    if isa(v,'SO3TangentVector')
      SO3TV = v;
      return
    end

    if check_option(varargin,'right')
      SO3TV.tangentSpace = 'right';
    else
      SO3TV.tangentSpace = 'left';
    end

  end

  function SO3TV = set.tangentSpace(SO3TV,s)
    if strcmp(s,'left') || strcmp(s,'right')
      SO3TV.tangentSpace = s;
    end
  end


  % -----------------------------------------------------------------------
  % check for some overloaded methods that the representation of the
  % tangent space is the same and assure that the result is again a
  % SO3TangentVector

  function SO3TV = cat(dim,varargin)
    [~,ind] = find(cellfun(@(v) isa(v,'SO3TangentVector'),varargin));
    v = varargin{ind(1)};
    for i = ind(1:end)
      tS = ensureCompatibleTangentSpaces(v,varargin{i});
      v.tangentSpace = tS;
    end
    v = cat@vector3d(dim,varargin{:});
    SO3TV = SO3TangentVector(v,tS);
  end

  function v = cross(v1,v2,varargin)
    tS = ensureCompatibleTangentSpaces(v1,v2);
    v = cross@vector3d(v1,v2,varargin{:});
    v = SO3TangentVector(v,tS);
  end

  function v = cross_outer(v1,v2,varargin)
    tS = ensureCompatibleTangentSpaces(v1,v2);
    v = cross_outer@vector3d(v1,v2,varargin{:});
    v = SO3TangentVector(v,tS);
  end

  function v = dot(v1,v2,varargin)
    ensureCompatibleTangentSpaces(v1,v2);
    v = dot@vector3d(v1,v2,varargin{:});
  end

  function v = dot_outer(v1,v2,varargin)
    ensureCompatibleTangentSpaces(v1,v2);
    v = dot_outer@vector3d(v1,v2,varargin{:});
  end

  function m = mean(v,varargin)
    m = mean@vector3d(v,varargin{:});
    m = SO3TangentVector(m,v.tangentSpace);
  end

  function v = minus(v1,v2,varargin)
    tS = ensureCompatibleTangentSpaces(v1,v2);
    v = minus@vector3d(v1,v2,varargin{:});
    v = SO3TangentVector(v,tS);
  end

  function v = mtimes(v1,v2,varargin)
    tS = ensureCompatibleTangentSpaces(v1,v2);
    v = mtimes@vector3d(v1,v2,varargin{:});
    if isa(v,'vector3d'), v = SO3TangentVector(v,tS); end
  end

  function v = plus(v1,v2,varargin)
    tS = ensureCompatibleTangentSpaces(v1,v2);
    v = plus@vector3d(v1,v2,varargin{:});
    v = SO3TangentVector(v,tS);
  end

  function v = rdivide(v1,v2,varargin)
    tS = ensureCompatibleTangentSpaces(v1,v2);
    v = rdivide@vector3d(v1,v2,varargin{:});
    v = SO3TangentVector(v,tS);
  end

  % When rotating tangent vectors it may changes the representation of the
  % tangent space (left <-> right)
  function v = rotate(v,q,varargin)
    v = rotate@vector3d(vector3d(v),q,varargin{:});
  end
  function v = rotate_outer(v,q,varargin)
    v = rotate_outer@vector3d(vector3d(v),q,varargin{:});
  end

  function v = times(v1,v2,varargin)
    tS = ensureCompatibleTangentSpaces(v1,v2);
    v = times@vector3d(v1,v2,varargin{:});
    v = SO3TangentVector(v,tS);
  end

end

end

