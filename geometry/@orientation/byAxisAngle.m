function ori = byAxisAngle(axis,angle,varargin)
% define orientations by rotational axis and rotational angle
%
% Syntax
%   ori = orientation.byAxisAngle(v,omega,CS) % an orientation
%   ori = orientation.byAxisAngle(h,omega) % a misorientation
%
% Input
%  v     - rotational axis @vector3d
%  m     - rotational axis @Miller
%  omega - rotation angle
%  CS    - @crystalSymmetry
%
% Output
%  ori - @orientation
%
% See also
% orientation_index orientation/byEuler orientation/byMatrix orientation/map


ori = orientation(axis2quat(axis,angle),varargin{:});

% copy crystal symmetry if possible
if isa(axis,'Miller'), ori.CS = axis.CS; ori.SS = axis.CS; end
