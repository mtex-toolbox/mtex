function ensureCompatibleTangentSpaces(v1,v2,varargin)
% Check whether the tangent spaces are the same, w.r.t. the rotations where 
% they are defined

eps = 1e-5;

if ~isa(v1,'SO3TangentVector') || ~isa(v2,'SO3TangentVector')
  error('You try to combine tangent vectors with other objects.')
end

ensureCompatibleSymmetries(v1,v2)

if check_option(varargin,'equal') && ~all(angle(v1.rot,v2.rot)<eps,'all')
  error('You are combining tangent vectors of different tangent spaces.')
end

if check_option(varargin,'AllEqual') && (~all(angle(v1.rot,v2.rot)<eps,'all') || ~all(angle(v1.rot(1),v1.rot(:))<eps,'all'))
  error('You are combining tangent vectors of different tangent spaces.')
end
  
end