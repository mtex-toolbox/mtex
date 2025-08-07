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
%   SO3TV = SO3TangentVector(v,ori,SO3TangentSpace.rightVector,cs,ss)
%
% Input
%  x,y,z - cart. coordinates
%  v - @vector3d
%  ori - @orientation
%  cs,ss - @symmetry
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

properties (Hidden = true)
  hiddenCS symmetry = crystalSymmetry;
  hiddenSS symmetry = specimenSymmetry;
end

% There is a left and a right tangent space representation.
%
% A SO3TangentVector w.r.t. left sided tangent space representation is
% described by S * R, where S denotes a skew symmetric matrix (spin tensor)
% and R is the rotation where the tangent space is located.
% In case of right sided tangent space it is described by R * S.
% 
% Hence tangent vectors are defined by 2 parts:
%   - the 3 components of the skew symmetric matrix S   --> vector3d
%   - the rotation, where the tangent space is located  --> rot
%
% The most common application is the gradient of some SO3Fun (i.e. the 
% evaluation of SO3VectorFields). Therefore only one of the symmetries is
% preserved on the orientation (dependent on the tangent space 
% representation). The other symmetry is hidden, but both symmetries 
% interchange, if the tangent space representation is switched.
%
% Thats why, both symmetries are stored in the properties hiddenCS and hiddenSS.

methods

  function SO3TV = SO3TangentVector(varargin)
    % constructor
    
    % reconstruct SO3TangentVector (apply options and maybe change attributes)
    if nargin > 0 && isa(varargin{1},'SO3TangentVector')
      varargin = {varargin{:}, varargin{1}.rot, varargin{1}.tangentSpace, varargin{1}.hiddenCS, varargin{1}.hiddenSS};
      varargin{1} = vector3d(varargin{1});
    end

    % vectors
    SO3TV = SO3TV@vector3d(varargin{:});

    % tangent space representation
    tS = SO3TangentSpace.extract(varargin);
    SO3TV.tangentSpace = tS;

    % get rotations
    id = find(cellfun(@(i) isa(i,'quaternion') , varargin),1);
    if isempty(id)
      error('The orientations which belong to the tangent vectors and defines the tangent space are missing.')
    end
    rot = orientation(varargin{id});

    % Bring both to same dimension size
    sa = size(rot); sb = size(SO3TV);
    maxDims = max(length(sa), length(sb));
    sa(end+1:maxDims) = 1; sb(end+1:maxDims) = 1;

    if length(rot) == numel(SO3TV)
      rot = reshape(rot,size(SO3TV));
    elseif any(sa~=sb)
      try 
        rot = rot.*rotation.id(size(SO3TV));
      catch
        error('The sizes of the tangent vectors and there orientations do not match.')
      end
    end

    % get symmetries
    [cs,ss] = extractSym(varargin);
    if cs.id==1
      cs = rot.CS;
    end
    if ss.id==1
      ss = rot.SS;
    end
    SO3TV.hiddenCS = cs;
    SO3TV.hiddenSS = ss;

    SO3TV.rot = rotation(rot);

  end
  
  % -----------------------------------------------------------------------

  % Get and Set outer symmetries dependent of the tangent space representation
  function r = get.rot(SO3TV)
    r = orientation(SO3TV.rot);
    if sign(SO3TV.tangentSpace)>0
      r.CS = SO3TV.hiddenCS;
      r.SS = ID1(SO3TV.hiddenSS);
    else
      r.CS = ID1(SO3TV.hiddenCS);
      r.SS = SO3TV.hiddenSS;
    end
  end


  % -----------------------------------------------------------------------

  % When rotating tangent vectors it may changes the representation of the
  % tangent space (left <-> right)
  % this funtions are necessary for .left and .right methods 
  % (we need to forget the tangent vector structure and rotate vector3d)
  function v = rotate(v,q,varargin)
    v = rotate@vector3d(vector3d(v),q,varargin{:});
  end
  function v = rotate_outer(v,q,varargin)
    v = rotate_outer@vector3d(vector3d(v),q,varargin{:});
  end
 

  function tV = transformTangentSpace(tV,newtS)
    
    rot = rotation(tV.rot);
    cs = tV.hiddenCS;
    ss = tV.hiddenSS;
    
    if sign(tV.tangentSpace) > sign(newtS)
      % transform from left to right
      tV = inv(rot) .* tV;
    elseif sign(tV.tangentSpace) < sign(newtS)
      % transform from right to left 
      tV = rot .* tV;
    end

    if abs(newtS) > 1
      tV = spinTensor(tV);
    else
      tV = SO3TangentVector(tV,rot,newtS,cs,ss);
    end
  end


  
end
end



