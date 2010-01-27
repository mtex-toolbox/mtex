function [I odf] = transinformation(odf1,odf2,varargin)
% information dependence of two odfs
%
% defined as:
%
% $$ I = \int f(g_{1+2}) \ln \frac{f(g_{1+2})}{f(g_1) * f(g_2)}  dg $$
%
%% Input
%  odf - @ODF 
%
%% Output
%  texture index - double
%
%% Options
%  resolution - resolution of the discretization
%
%% See also
% ODF/entropy ODF/textureindex ODF/calcerror


S3G = extract_SO3grid(odf1,varargin{:});
e1 = eval(odf1,S3G,varargin{:});

if ~check_option([{odf2} varargin],'evaluated'); %second ODF allready evaluated
  e2 = eval(odf2,S3G,varargin{:});
else
  e2 = get_option([{odf2} varargin],'evaluated',[],'double');
end

e12 = (e1+e2)./sum(e1+e2);
ed12 =  e1.*e2./(sum(e1.*e2)^2);
ind = ed12 <= 0;
e12(ind) = []; ed12(ind) = [];

h = e12.*log2(e12./ed12);

I = nansum(h);

if nargout > 1,
  S3G = subGrid(S3G,~ind);
  odf = ODF(S3G,h,extract_kernel(S3G,varargin),...
    get(S3G,'CS'),get(S3G,'SS'),varargin{:});
end
