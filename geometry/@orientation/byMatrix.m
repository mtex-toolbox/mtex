function ori = byMatrix(varargin)
% define orientations by a matrix
%
% Syntax
%   ori = orientation.byMatrix(R,CS)
%
% Input
%  R - 3x3 matrix
%  CS     - @crystalSymmetry
%
% Output
%  ori - @orientation
%
% See also
% orientation/orientation orientation/byEuler orientation/byAxisAngle

rot = rotation.byMatrix(varargin{:});
ori = orientation(rot,varargin{:});