function [q,id] = quantile(x,n)
% If n is in (0,1), then q is the n-th quantile of x (n*100 percent quantile)
% If n<0, then q is the (n+1)-th largest entry of x
% If n>1, then q is the n-th smallest entry of x
%
% Syntax
%   q = quantile(x,n)
%
% Input
%  x - double
%  n - double
%
% Output
%  q - double
%
% Example 
%   [~,x]=sort(rand(1,1000));
%   quantile(x,3)    % third smallest entry
%   quantile(x,-2)   % third largest entry
%   quantile(x,0.25) % 25 percent quantile
%

if size(x,1) == 1, x = x.';end
rmId = isnan(x);
[x,id] = sort(x(~rmId));

if isempty(x)
  q = nan;
elseif n <= 0
  pos = max(1,numel(x)+n);
  q = x(pos);
elseif n < 1
  pos = max(1,round(size(x,1)*n));
  q = x(pos,:);
else
  pos = n;
  q = x(min(pos,numel(x)));
end

if nargout > 1
  idFull = 1:numel(rmId);
  idFull(rmId)=[];
  id = idFull(id(pos));
end