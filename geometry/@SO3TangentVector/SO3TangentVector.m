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
%   SO3TV = SO3TangentVector(v,oriRef)
%   SO3TV = SO3TangentVector(v,oriRef,SO3TangentSpace.rightVector)
%   SO3TV = SO3TangentVector(v,oriRef,'right')
%
% Input
%  v      - @vector3d, the components of the skew symmetric matrix
%  oriRef - @orientation the tangent space is located at
%  tS     - @SO3TangentSpace, or 'left' / 'right'
%
% Output
%  SO3TV - @SO3TangentVector
%
% Description
%  The symmetries of a tangent vector are the symmetries of |oriRef| -
%  there is no separate symmetry argument. A field or function that owns
%  the pair therefore states it on the reference it hands in, e.g.
%  |SO3TangentVector(v,orientation(rot,SO3F.CS,SO3F.SS),tS)|, rather than
%  passing it alongside. That leaves exactly one place a symmetry can come
%  from, so there is nothing to arbitrate.
%
%  |left| means oriRef multiplies from the right (the default), |right|
%  that it multiplies from the left.
%
% See also
% vector3d.vector3d SO3VectorField.SO3VectorField SO3VectorFieldHarmonic.eval
% SO3Fun.grad SO3FunHarmonic.grad

% t_left * ori_ref = ori_ref * t_right
% -> t_left = ori_ref * t_right * inv(ori_ref)


properties
  tangentSpace SO3TangentSpace
  % the reference orientation, the only place the two symmetries are stored
  oriRef
end

properties (Dependent = true)
  % the reference as this representation sees it - read only, it is a view
  rot
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
% interchange, if the tangent space representation is switched. Hence both
% live on oriRef and rot is only the view of it this representation may show.

methods

  function SO3TV = SO3TangentVector(v,oriRef,tS)
    % constructor

    if nargin < 2
      error('MTEX:SO3TangentVector:missingReference',...
        ['A tangent vector needs the reference orientation its tangent '...
        'space is located at: SO3TangentVector(v,oriRef,tS).'])
    end

    % the components
    if ~isa(v,'vector3d'), v = vector3d(v); end
    SO3TV = SO3TV@vector3d(v);

    % the representation
    if nargin < 3, tS = SO3TangentSpace.leftVector; end
    if ~isa(tS,'SO3TangentSpace'), tS = SO3TangentSpace.extract(tS); end
    SO3TV.tangentSpace = tS;

    % the reference and, with it, the symmetries - a bare rotation has
    % nothing to inherit from, so there the session defaults apply
    oriRef = orientation(oriRef);

    % one reference per vector, or one for all of them - broadcast the bare rotation
    q = rotation(oriRef);
    sa = size(q); sb = size(SO3TV);
    maxDims = max(length(sa), length(sb));
    sa(end+1:maxDims) = 1; sb(end+1:maxDims) = 1;

    if length(q) == numel(SO3TV)
      q = reshape(q,size(SO3TV));
    elseif any(sa~=sb)
      try
        q = q .* rotation.id(size(SO3TV));
      catch
        error('The sizes of the tangent vectors and their reference orientations do not match.')
      end
    end

    SO3TV.oriRef = orientation(q,oriRef.CS,oriRef.SS);

  end
  
  % -----------------------------------------------------------------------

  % which outer symmetry survives depends on the tangent space representation
  function r = get.rot(SO3TV)
    r = SO3TV.oriRef;
    if isempty(r), return; end
    if SO3TV.tangentSpace.isLeft
      r.SS = stripSym(r.SS);
    else
      r.CS = stripSym(r.CS);
    end
  end


  % -----------------------------------------------------------------------

  function fr = getFrame(SO3TV)
    % the frame of a tangent vector is derived from its reference
    % orientation: a left vector is expressed in the specimen frame, a
    % right vector in the crystal frame
    ref = SO3TV.oriRef;
    if SO3TV.tangentSpace.isLeft
      fr = ref.SS.frame;
    else
      fr = ref.CS.frame;
    end
  end

  function SO3TV = setFrame(SO3TV,fr) %#ok<INUSD>
    error('MTEX:SO3TangentVector:fixedFrame',...
      ['The frame of a tangent vector is the specimen frame (left) or ' ...
      'crystal frame (right) of its reference orientation.']);
  end

  % -----------------------------------------------------------------------

  % rotate is inherited from vector3d - a rotated tangent vector is again one at
  % the same reference; rotate_outer is not, its n x m result has no reference
  function v = rotate_outer(v,q,varargin)
    v = rotate_outer@vector3d(vector3d(v),q,varargin{:});
  end


  function tV = transformTangentSpace(tV,newtS)

    % nothing to transform - and rebuilding anyway would cost a round trip
    % through the constructor for no change
    if newtS == tV.tangentSpace, return; end

    q = rotation(tV.oriRef);

    % rotating keeps the class and the reference, so the components change
    % in place and only the label has to follow - no cast, no rebuild
    if sign(tV.tangentSpace) > sign(newtS)
      % transform from left to right
      tV = inv(q) .* tV;
    elseif sign(tV.tangentSpace) < sign(newtS)
      % transform from right to left
      tV = q .* tV;
    end

    tV.tangentSpace = newtS;

    if abs(newtS) > 1, tV = spinTensor(tV); end
  end


  
end
end



