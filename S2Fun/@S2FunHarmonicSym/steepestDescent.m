function [f,v] = steepestDescent(sF, varargin)
% calculates the minimum of a spherical harminc
% Syntax
%   [v,pos] = steepestDescent(sF) % the position where the minimum is atained
%
%   [v,pos] = steepestDescent(sF,'numLocal',5) % the 5 largest local minima
%
%   % with all options
%   [v,pos] = steepestDescent(sF, 'startingnodes')
%
% Output
%  v - double
%  pos - @vector3d
%
% Options
%  STARTINGNODES  -  starting nodes of type @vector3d
%  

% parameters
if ~check_option(varargin, 'startingnodes')
  sR = sF.s.fundamentalSector;
  v = equispacedS2Grid('points', 2^10/sR.volume);
  v = v(sR.checkInside(v));
  varargin = set_option(varargin, 'startingnodes', v);
end

[f, v] = steepestDescent@S2FunHarmonic(sF, varargin{:})

v = Miller(v, sF.s);

end
