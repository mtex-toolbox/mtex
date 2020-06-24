function q = accumarray(subs,q,varargin)
% accumarray for quaternion
%
% Syntax
%   q = accumarray(subs,q)
%
% Input
%  subs - 
%  q - @quaternion
%
% Output
%  q - @quaternion

% find a reference quaternion for each class
ref = accumarray(subs,1:length(q),[],@(x) x(1));
q_ref = q.subSet(ref(subs));
  
flip = 1 - 2*(dot(q,q_ref,'noAntipodal') < 0);
  
a = accumarray(subs,q.a .* flip,varargin{:});
b = accumarray(subs,q.b .* flip,varargin{:});
c = accumarray(subs,q.c .* flip,varargin{:});
d = accumarray(subs,q.d .* flip,varargin{:});

% normalize
s = sqrt(a.^2 + b.^2 + c.^2 + d.^2);
q.a = a ./ s; q.b = b ./ s; q.c = c ./ s; q.d = d ./ s;