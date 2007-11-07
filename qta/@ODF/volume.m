function v = volume(odf,center,radius,varargin)
% ratio of orientations with a certain orientation
%
%% Description
% returns the ratio of mass of the odf with that is close to 
% one of the orientations as radius
%
%% Syntax
%  v = volume(odf,center,radius,<options>)
%
%% Input
%  odf    - @ODF
%  center - @quaternion
%  radius - double
%
%% Options
%  resolution - resolution of discretization
%
%% See also
% ODF/entropy ODF/textureindex

% get resolution
res = get_option(varargin,'RESOLUTION',2.5*degree);

% discretisation
S3G = SO3Grid(res,odf(1).CS,odf(1).SS);
subS3G = subGrid(S3G,center,radius);


% eval odf
v = sum(eval(odf,subS3G))/GridLength(S3G);
