function S3G = quantile(SO3F,varargin)
% quantile orientations of an SO3Fun
%
% Syntax
%   S3G = quantile(odf,p)
%
% Input
%  odf - @SO3Fun
%  p   - upper quantile, if negative lower quantile
%
% See also
% PoleFigure/quantile


t = find_type(varargin,'double');
p = varargin{t};

if p < 0 
  c = @(c)~c;
  p = abs(p);
else
  c = @(c)c;
end


S3G = extract_SO3grid(SO3F,varargin{:});

f = eval(SO3F,S3G,varargin{:});
f = f(:);
[f, ndx] = sort(f);

pd = cumsum(f)./sum(f);

S3G = subGrid(S3G, ndx( c(pd >= p) ) );
