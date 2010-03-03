function odf = diff(odf1,odf2,varargin)
% calculate approximation difference between two ODFs
%
%% Syntax
%  e = calcerror(odf1,odf2)
%
%% Input
%  odf1, odf2 - @ODF
%
%% Output
%  odf - @ODF
%
%% Options
%  resolution - resolution used for calculation of the difference
%  Fourier    - return an Fourier ODF
%
%% See also
% ODF/calcerror ODF/plotDiff

% discretisation
S3G = extract_SO3grid(odf1,varargin{:});
e1 = eval(odf1,S3G,varargin{:});
e2 = eval(odf2,S3G,varargin{:});
d = abs(e1-e2)./numel(e1);

odf = ODF(S3G,d,extract_kernel(S3G,varargin),...
  get(S3G,'CS'),get(S3G,'SS'),varargin{:});

if check_option(varargin,'Fourier')
  odf = calcFourier(odf,max(10,bandwidth(k)));
  odf = FourierODF(odf);
end
