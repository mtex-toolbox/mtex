function e = calcerror(rec,orig,varargin)
% calculate approximation error between a true and a recalculated ODF
%
%% Input
%  rec  - reconstructed @ODF
%  orig - true @ODF
%  S3G  - @SO3Grid of quadrature nodes (optional)
%
%% Options
%  L1 - l^1 error (default)
%  L2 - l^2 error
%
%% See also
% PoleFigure/calcODF PoleFigure/calcerror 

S3G = get_option(varargin,'SO3Grid',getgrid(rec),'SO3Grid');

d1 = eval(rec,S3G,varargin{:});
if isa(orig,'double')
  d2 = orig;
else
  d2 = eval(orig,S3G,'EXACT');
end

if check_option(varargin,'L2')
  e = sqrt(sum((d1-d2).^2)) / sqrt(sum(d2.^2));
else
  e = sum(abs(d1-d2)) / length(d1) /2;
end
