function ensureCompatibleSymmetries(SO3VF,varargin)
% For calculating with @SO3VectorFields (+, -, .*, ./, ...) we have to verify
% that the symmetries are suitable.
%
% Syntax
%   ensureCompatibleSymmetries(SO3F1,SO3F2)
%   ensureCompatibleSymmetries(SO3F1,sF)
%   ensureCompatibleSymmetries(SO3F1,ori)
%   ensureCompatibleSymmetries(SO3F1,SO3F2,'conv')
%   ensureCompatibleSymmetries(SO3F1,'antipodal')
%
% Input
%  SO3F1, SO3F2 - @SO3VectorField, @SO3Fun
%  sF - @S2FunHarmonicSym
%  ori - @orientation
%
% Output
%  msg - yields a error message if the symmetry do not match
%
% Options
%  conv - be shure switched symmetries match
%

if isa(SO3VF,'SO3VectorField')
  SO3VF = SO3FunHarmonic(0,SO3VF.SRight,SO3VF.SLeft);
end
if nargin>1 && isa(varargin{1},'SO3VectorField')
  varargin{1} = SO3FunHarmonic(0,varargin{1}.SRight,varargin{1}.SLeft);
end

ensureCompatibleSymmetries(SO3VF,varargin{:},'SO3VectorField')

end