function q = cumprod(q,varargin)
% overloads cumprod(q)
%
% computes the cumulative product along the first non-singleton dimension 
% of q.
%
% Syntax
%   q = cumprod(q)
%   q = cumprod(q,dim)
%   q = cumprod(q,dim,'reverse','omitnan')
%
% Input
%  q - @quaternion
%
% Output
%  q - @quaternion
%
% Flags
%  'reverse' - use the reverse direction, from end to beginning
%  'omitmissing' / 'omitnan' - NaN values are ignored (they are treated as identity quaternions)
%

if nargin>1 && isnumeric(varargin{1})
  dim = varargin{1};
else
  dim = find(size(q)>1,1);
end
if size(q,dim)==1
  return
end

if check_option(varargin,'reverse')
  q = flip(q,dim);
  varargin = delete_option(varargin,'reverse');
  q = cumprod(q,varargin{:});
  q = flip(q,dim);
  return
end

if check_option(varargin,{'omitmissing','omitnan'})
  q(isnan(q)) = quaternion.id;
end


% compute the cumulative product
q = permute(q,[dim,1:dim-1,dim+1:length(size(q))]);
for i = 2:size(q,dim)
  a = q.subSet(i-1,':').*q.subSet(i,':');
  s = struct('type','()','subs',{{i  ':'}});
  q = subsasgn(q,s,a);
end
q = ipermute(q,[dim,1:dim-1,dim+1:length(size(q))]);

