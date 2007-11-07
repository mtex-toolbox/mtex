function d = getdata(odf)
% get weights of all single components of the odf
%
%% Input
%  odf - @ODF
%
%% Output
%  d - [double] weights of all single components of the odf
%
%% See also
% ODF/getweights PoleFigure/calcODF

d = [odf.c];
%odf.c(find(abs(odf.c) <= 1E-10)) = 0;

