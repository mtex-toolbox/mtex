function SO3VF = symmetrise(SO3VF,varargin)
% Symmetrise the harmonic coefficients of an SO3VectorFieldHarmonic w.r.t.
% its symmetries.
% 
% Therefore we compute the harmonic coefficients of the SO3VectorFieldHarmonic 
% by using symmetry properties.
%
% Syntax
%  SO3VF = symmetrise(SO3VF)
%
% Input
%  SO3VF - @SO3FunVectorFieldHarmonic
%
% Output
%  SO3VF - @SO3FunVectorFieldHarmonic
%

if SO3VF.bandwidth==0
  return
end
varargin = delete_option(varargin,'antipodal');

SO3VF.SO3F = symmetrise(SO3VF.SO3F,varargin{:});

end