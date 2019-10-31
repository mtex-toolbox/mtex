function pf = rotate_outer(pf,rot,varargin)
% is called by rot * pf
%
% Syntax  
%   pf = rotate_outer(pf,rot)
% 
% Input
%  pf  - @PoleFigure
%  rot - @rotation
%
% Output
%  pf - rotated @PoleFigure
%
% See also
% rotation/rotation ODF/rotate

pf = rotate(pf,rot,varargin{:});
