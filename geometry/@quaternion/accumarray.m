function [q, GOS] = accumarray(subs,q,varargin)
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

isRobust = check_option(varargin,'robust');
varargin = delete_option(varargin,'robust');

% find a reference quaternion for each class
%ref = accumarray(subs,1:length(q),[],@(x) x(1));
% this assumes that each index 1..n appears at least once
[~,ref] = unique(subs);

q_ref = q.subSet(ref(subs));
  
flip = 1 - 2*(dot(q,q_ref,'noAntipodal') < 0);
  
a = accumarray(subs,q.a .* flip,varargin{:});
b = accumarray(subs,q.b .* flip,varargin{:});
c = accumarray(subs,q.c .* flip,varargin{:});
d = accumarray(subs,q.d .* flip,varargin{:});

% normalize
s = sqrt(a.^2 + b.^2 + c.^2 + d.^2);

if isRobust
  % compute the fit
  omega = real(acos(flip./s(subs) .* ...
    (q.a .* a(subs) + q.b .* b(subs) + q.c .* c(subs) + q.d .* d(subs))));

  % compute the threshold
  threshold = 2.5*accumarray(subs,omega,size(a),@(x) quantile(x,0.8));
  ind = omega <= threshold(subs) | (isnan(threshold(subs)) & isnan(omega)) ;

  Rsubs = subs(ind);
  Rflip = flip(ind);
  a = accumarray(Rsubs,q.a(ind) .* Rflip,varargin{:});
  b = accumarray(Rsubs,q.b(ind) .* Rflip,varargin{:});
  c = accumarray(Rsubs,q.c(ind) .* Rflip,varargin{:});
  d = accumarray(Rsubs,q.d(ind) .* Rflip,varargin{:});

  % normalize
  s = sqrt(a.^2 + b.^2 + c.^2 + d.^2);
end

% compute spread for each cluster
if nargout == 2
  omega = 2*real(acos(flip./s(subs) .* ...
    (q.a .* a(subs) + q.b .* b(subs) + q.c .* c(subs) + q.d .* d(subs))));
  
  GOS = accumarray(subs,omega,size(a)) ./ accumarray(subs,1,size(a));

end

q.a = a ./ s; q.b = b ./ s; q.c = c ./ s; q.d = d ./ s;
if isa(q,'rotation'), q.i = q_ref.i(ref); end