function ori = accumarray(subs,ori,varargin)
% accumarray for orientation
%
% Syntax
%   ori = accumarray(subs,ori)
%
% Input
%  subs - 
%  ori - @orientation
%
% Output
%  ori - @orientation

% find a reference orientation for each class
% this assumes that each index 1..n appears at least once
%ref = accumarray(subs,1:length(ori),[],@(x) x(1));
[~,ref] = unique(subs);

ori_ref = ori.subSet(ref(subs));
  
ori = project2FundamentalRegion(ori,ori_ref);
  
a = accumarray(subs,ori.a,varargin{:});
b = accumarray(subs,ori.b,varargin{:});
c = accumarray(subs,ori.c,varargin{:});
d = accumarray(subs,ori.d,varargin{:});

% normalize
s = sqrt(a.^2 + b.^2 + c.^2 + d.^2);
ori.a = a ./ s; ori.b = b ./ s; ori.c = c ./ s; ori.d = d ./ s;

ori.i = ori_ref.i(ref);