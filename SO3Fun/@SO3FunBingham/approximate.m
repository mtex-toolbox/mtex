function SO3F = approximate(f,varargin)
% Approximate BinghamODF from a given SO3Fun via kernel density estimation
%
% Syntax
%   SO3F = SO3FunBingham.approximate(odf)
%   SO3F = SO3FunBingham.approximate(odf,'resolution',5*degree)
%   SO3F = SO3FunBingham.approximate(odf,'SO3Grid',S3G)
%
% Input
%  odf - @SO3Fun
%  S3G - @rotation
%
% Output
%  SO3F - @SO3FunBingham
%
% Options
%  resolution - resolution of the grid nodes of the @SO3Grid
%  SO3Grid    - grid nodes of the @SO3Grid
%
% See also
% calcBinghamODF SO3FunBingham

if isa(f,'function_handle')
  [SRight,SLeft] = extractSym(varargin);
  f = SO3FunHandle(f,SRight,SLeft);
end

if isa(f,'SO3Fun')
  res = get_option(varargin,'resolution',5*degree);
  nodes = extract_SO3grid(f,varargin{:},'resolution',res);
  y = f.eval(nodes);
end

if isnumeric(nodes) && nargin==1
  y = [];
end

SO3F = calcBinghamODF(nodes,'weights',y);
