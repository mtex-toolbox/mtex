classdef (InferiorClasses = {?vector3d}) SO3TangentVector < vector3d
% The left tangent space of SO(3) in some rotation R can be described by
% 
% $$ T_R(SO(3)) = \{ s\cdot R | s = -s^T \} $$
%
% where $R$ denotes the rotation matrix and $s$ are skew symmetric matrices 
% which look like 
%
% $$ \left(\begin{matrix} 0 & -c & b \\ c & 0 & -a \\ -b & a & 0 \end{matrix}\right).$$
%
% Hence we describe an element of of the tangent space T_R(SO(3)) by the 
% vector $(a,b,c)^T$ which in fact is an vector3d and the corresponding rotation.
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
%   SO3TV = SO3TangentVector(x,y,z,ori)
%   SO3TV = SO3TangentVector(v,ori,SO3TangentSpace.rightVector)
%
% Input
%  x,y,z - cart. coordinates
%  v - @vector3d
%  ori - @orientation
%
% Output
%  SO3TV - @SO3TangentVector
%
% Options
%  left  - ori_ref multiplies from the right (default)
%  right - ori_ref multiplies from the left
%
% See also
% vector3d.vector3d SO3VectorField.eval SO3VectorFieldHarmonic.eval
% SO3Fun.grad SO3FunHarmonic.grad

% t_left * ori_ref = ori_ref * t_right
% -> t_left = ori_ref * t_right * inv(ori_ref)


properties
  tangentSpace SO3TangentSpace
  rot
end

methods

  function SO3TV = SO3TangentVector(varargin)
    % constructor
    
    % reconstruct SO3TangentVector (apply options and maybe change attributes)
    if nargin > 0 && isa(varargin{1},'SO3TangentVector')
      varargin{end+1} = varargin{1}.rot;
      varargin{end+2} = varargin{1}.tangentSpace;
      varargin{1} = vector3d(varargin{1});
    end

    % vectors
    SO3TV = SO3TV@vector3d(varargin{:});

    % tangent space representation
    SO3TV.tangentSpace = SO3TangentSpace.extract(varargin{:});
      
    % rotations
    id = find(cellfun(@(i) isa(i,'quaternion') , varargin));
    if isempty(id)
      error('The rotations which belong to the tangent vectors and defines the tangent space are missing.')
    end
    SO3TV.rot = varargin{id(1)};
    if any(size(SO3TV.rot)~=size(SO3TV))
      try 
        SO3TV.rot = SO3TV.rot.*rotation.id(size(SO3TV));
      catch
        error('The sizes of the tangent vectors and there rotations do not match.')
      end
    end

  end
  
  % -----------------------------------------------------------------------

  % When rotating tangent vectors it may changes the representation of the
  % tangent space (left <-> right)
  function v = rotate(v,q,varargin)
    v = rotate@vector3d(vector3d(v),q,varargin{:});
  end
  function v = rotate_outer(v,q,varargin)
    v = rotate_outer@vector3d(vector3d(v),q,varargin{:});
  end
 

  function tV = transformTangentSpace(tV,newtS)
    
    if sign(tV.tangentSpace) > sign(newtS)
      % transform from left to right
      tV = inv(tV.rot) .* tV;
    elseif sign(tV.tangentSpace) < sign(newtS)
      % transform from right to left 
      tV = tV.rot .* tV;
    end

    if abs(newtS) > 1
      tV = spinTensor(tV);
    else
      tV = SO3TangentVector(tV,newtS);
    end
  end
end
end



