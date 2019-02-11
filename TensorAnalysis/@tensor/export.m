function export(t,fname,varargin)
% export tensor to json file
%
% Syntax
%   m = matrix(T)
%   m = matrix(T,'voigt')
%
% Input
%  T - @tensor
%
% Output
%  m - matrix
%
% Options
%  voigt - give a 4 rank tensor in voigt notation, i.e. as a 6 x 6 matrix
%
% See also
%

CS.abg = [t.CS.alpha,t.CS.beta,t.CS.gamma]./degree;
CS.abc = norm([t.CS.aAxis,t.CS.bAxis,t.CS.cAxis]);
CS.pointGroup = t.CS.pointGroup;
CS.mineral = t.CS.mineral;
CS.alignment = t.CS.alignment;
warning off
data = struct(t);
warning on
data.M = matrix(t,'voigt');
data.CS = CS;

savejson(class(t),data,fname);
