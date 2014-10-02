function pf = calcPoleFigure(pf,odf,varargin)
% simulate pole figure
%
% Syntax
%   pf = simulatePoleFigure(pf,odf)
%
% Input
%  pf  - meassured @PoleFigure
%  odf - @ODF
%
% Output
%  pf - simulated PoleFigure 
%
% See also
% ODF/simulatePoleFigure

pf = calcPoleFigure(odf,pf.allH,pf.allR,'superposition',pf.c,varargin{:});

