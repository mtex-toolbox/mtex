function o = symmetrise(o,varargin)  
% all crystallographically equivalent orientations
%
% Syntax
%
%   oriSym = symmetrise(ori)
%
%   oriSym = symmetrise(ori,'antipodal')
% 
% Input
%  ori - @orientation 
%
% Output
%  oriSym - @orientation (numel(CS) * numel(SS)) x numel(ori)
%
% Flags
%  proper - consider only proper symmetry operations
%  noSym1 - ignore left symmetry 
%  noSym2 - ignore right symmetry
%  unique - return unique list of symmetrically equivalent orientations
%

if nargin > 1 && isa(varargin{1},'symmetry')
  CS = varargin{1};
  SS = getClass(varargin(2:end),'symmetry',specimenSymmetry);
else
  CS = o.CS;
  SS = o.SS;
end

if check_option(varargin,'proper')
  CS = CS.properGroup;
  SS = SS.properGroup;
end

if check_option(varargin,'noSym1'), CS = []; end
if check_option(varargin,'noSym2'), SS = []; end

o = symmetrise@rotation(o,CS,SS);

if o.antipodal, o = [o;inv(o)]; end

if check_option(varargin,'unique')
  [~,ind] = unique(o,'noSymmetry');
  o = subSet(o,ind);
end
