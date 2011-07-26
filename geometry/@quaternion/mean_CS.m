function o = mean_CS(q,CS,SS)
% fast mean of 
%
%% Syntax
% m = mean(o)
%
%% Input
%  o        - list of @orientation
%
%% Output
%  m      - mean @orientation
%
%% See also
% orientation/mean

if numel(q) > 1
  q = project2FundamentalRegion(q,CS,SS,q(1));
  q = mean(q);
end

o = orientation(q,CS,SS);
