function s = tensorSize(T,varargin)
% overloads size

ss = size(T.M,varargin{:});
ss = ss(1:min(end,T.rank));

s = ones(1,T.rank);
s(1:length(ss)) = ss;