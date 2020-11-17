function [sS,id] = symmetrise(sS,varargin)
% find all symmetrically equivalent slips systems
%
% Syntax
%
%   sSAll = sS.symmetrise
%   [sSAll,id] = symmetrise(sS)
%
% Input
%  sS - @slipSystem
%
% Output
%  sSAll - @slipSystem
%  id    - id of the slipSystem before symmetrisation
%

if ~isa(sS.b,'Miller'), return; end

b = [];
n =  [];
CRSS = [];
id = [];
for i = 1:length(sS)

  % find all symmetrically equivalent
  mm = symmetrise(sS.b(i),'unique',varargin{:});
  nn = symmetrise(sS.n(i),'unique','antipodal'); %#ok<*PROP>
  
  % find those which have the same angles as the original system
  % for slip system this is of course 90 degree
  [r,c] = find(isnull(dot(sS.n(i),sS.b(i),'noSymmetry')-...
    dot_outer(mm,nn,'noSymmetry')));

  % restricht to the orthogonal ones
  b = [b;mm(r(:))]; %#ok<*AGROW>
  n = [n;nn(c(:))];
  CRSS = [CRSS;repmat(sS.CRSS(i),length(r),1)];
  id = [id;repmat(i,length(r),1)];
end

sS.b = b;
sS.n = n;
sS.CRSS = CRSS;  

end
