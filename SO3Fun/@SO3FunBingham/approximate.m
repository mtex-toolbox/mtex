function SO3F = approximate(nodes,y,varargin)
% Approximate BinghamODF from individual orientations or a given SO3Fun
% via kernel density estimation
%
% Syntax
%   SO3F = SO3FunBingham.approximate(odf)
%   SO3F = SO3FunBingham.approximate(odf,'resolution',5*degree)
%   SO3F = SO3FunBingham.approximate(odf,'SO3Grid',S3G)
%   SO3F = SO3FunBingham.approximate(nodes, y)
%
% Input
%  odf   - @SO3Fun
%  nodes - rotational grid @SO3Grid, @orientation, @rotation
%  y     - function values on the grid (maybe empty)
%
% Output
%  SO3F - @SO3FunBingham
%
% Options
%  resolution - resolution of the grid nodes of the @SO3Grid
%  SO3Grid    - grid nodes of the @SO3Grid
%
% See also
% calcBinghamODF rotation/interp

if isa(nodes,'function_handle')
  [SRight,SLeft] = extractSym([y,varargin]);
  nodes = SO3FunHandle(nodes,SRight,SLeft);
end

if isa(nodes,'SO3Fun')
  odf = nodes;
  if nargin>1, varargin = {y,varargin{:}}; end
  res = get_option(varargin,'resolution',5*degree);
  nodes = extract_SO3grid(odf,varargin{:},'resolution',res);
  y = odf.eval(nodes);
end

if isnumeric(nodes) && nargin==1
  y=[];
end

SO3F = calcBinghamODF(nodes,'weights',y);
