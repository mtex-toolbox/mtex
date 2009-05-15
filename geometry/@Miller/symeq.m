function m = symeq(m1,varargin)
% directions symmetrically equivalent to m1
%% Syntax
%  m = symeq(m1)    - Miller indice symmetrically equivalent to m1
%  e = symeq(m1,m2) - check if vectors symmetrically equivalent
%
%% Input
%  m1, m2 - @Miller
%
%% Output
%  m - @Miller
%  e - logical

if nargin > 1 && isa(varargin{1},'Miller')
  m = isnull(angle(m1,varargin{1},varargin{2:end}));  
else
  m = vec2Miller(symvec(m1,varargin{:}),m1.CS);  
end
