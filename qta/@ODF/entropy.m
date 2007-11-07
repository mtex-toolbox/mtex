function e = entropy(odf,varargin)
% caclulate entropy of ODF
%
% The entropy of an ODF f is defined as:
%
% $$ e = - \int f(g) \ln f(g) dg$$
%
%
%% Input
%  odf - @ODF 
%
%% Output
%  entropy - double
%
%% Options
%  resolution - resolution of the discretization
%% See also
% ODF/textureindex ODF/volume


% get resolution
res = get_option(varargin,'RESOLUTION',2.5*degree);

% discretisation
S3G = SO3Grid(res,odf(1).CS,odf(1).SS);

% eval odf
e = eval(odf,S3G);
e = e(e>0);
e = - sum(e .* log(e))/GridLength(S3G);
