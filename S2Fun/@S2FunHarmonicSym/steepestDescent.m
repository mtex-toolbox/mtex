function [f,v] = steepestDescent(sF, varargin)
% calculates the minimum of a spherical harminc
% Syntax
%   [f,pos] = steepestDescent(sF) % the position where the minimum is atained
%
%   [f,pos] = steepestDescent(sF,'numLocal',5) % the 5 largest local minima
%
%   % with all options
%   [f,pos] = steepestDescent(sF, 'startingnodes')
%
% Output
%  f - double
%  pos - @vector3d
%
% Options
%  STARTINGNODES  -  starting nodes of type @vector3d
%  

% parameters
if ~check_option(varargin, 'startingnodes')
  
  antipodalFlag = {'','antipodal'};
  sR = sF.s.fundamentalSector(antipodalFlag{sF.antipodal+1});
  v = equispacedS2Grid(sR,'points',min(1000000,2*sF.bandwidth^2));
    
  if isa(sF.s,'crystalSymmetry')
    v = Miller(v, sF.s);
  end
  varargin = set_option(varargin, 'startingnodes', v);
end

[f, v] = steepestDescent@S2FunHarmonic(sF, varargin{:});

end
