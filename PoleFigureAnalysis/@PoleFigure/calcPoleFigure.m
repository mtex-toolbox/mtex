function pf = calcPoleFigure(pf,odf,varargin)
% simulate pole figure
%
% Syntax
%   pf = calcPoleFigure(pf,odf)
%
% Input
%  pf  - meassured @PoleFigure
%  odf - @ODF
%
% Output
%  pf - recomputed @PoleFigure 
%
% See also
% ODF/calcPoleFigure

pf = calcPoleFigure(odf,pf.allH,pf.allR,'superposition',pf.c,varargin{:});

