function tS1 = ensureCompatibleTangentSpaces(v1,v2,varargin)

tS1 = []; tS2 = [];

% Check for suitable tangent space representation
if isa(v1,'SO3TangentVector') || isa(v1,'SO3VectorField')
  tS1 = v1.tangentSpace;
end
if isa(v2,'SO3TangentVector') || isa(v2,'SO3VectorField')
  tS2 = v2.tangentSpace;
end
% TODO: change this (This shouldnt be an error. The tangent spaces should be changed to be suitable.)
if  ~isempty(tS1) && ~isempty(tS2) && tS1 ~= tS2
  error(['You are mixing left and right sided representation of the tangent spaces. ' ...
    'Change the Code to ensure suitable representations.'])
end

% Obtain tangent space
if isempty(tS1), tS1 = tS2; end

% Check whether the tangent spaces are the same, w.r.t. the rotations where 
% they are defined
eps = 1e-5;
if isa(v1,'SO3TangentVector') && isa(v2,'SO3TangentVector')

  if check_option(varargin,'equal') && ~all(angle(v1.rot,v2.rot)<eps,'all')
    error('You are combining tangent vectors of different tangent spaces.')
  end

  if check_option(varargin,'AllEqual') && (~all(angle(v1.rot,v2.rot)<eps,'all') || ~all(angle(v1.rot(1),v1.rot(:))<eps,'all'))
    error('You are combining tangent vectors of different tangent spaces.')
  end
  
end


end