function S3G = quantile(odf,varargin)
% quantile orientations of an ODF
%
% Syntax
%   SO3 = quantile(odf,p)
%
% Input
%  odf - @ODF
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


S3G = extract_SO3grid(odf,varargin{:});

f = eval(odf,S3G,varargin{:});
[f, ndx] = sort(f);

pd = cumsum(f)./sum(f);

S3G = subGrid(S3G, ndx( c(pd >= p) ) );
