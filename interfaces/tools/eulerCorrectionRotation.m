function rot = eulerCorrectionRotation(setting)
% the Euler <-> map alignment behind an EDAX style "setting"
%
% Description
%
% EDAX style formats (.ang, .osc, .edaxh5) expose the alignment of the
% Euler angle reference frame with the map reference frame as a number 1 to
% 4, which the file does not state. This is the rotation each of them
% stands for, 0 being no correction at all.
%
% Import applies it (see applyEulerCorrectionTable), export has to undo it
% again, so both take it from here.
%
% Syntax
%   rot = eulerCorrectionRotation(2)
%
% Input
%  setting - 0 to 4
%
% Output
%  rot - @rotation

rotCorrection = [rotation.id,...
  rotation.byAxisAngle(xvector+yvector,180*degree),... % setting 1
  rotation.byAxisAngle(xvector-yvector,180*degree),... % setting 2
  rotation.byAxisAngle(xvector,180*degree),...         % setting 3
  rotation.byAxisAngle(yvector,180*degree)];           % setting 4

assert(setting >= 0 && setting <= 4 && mod(setting,1) == 0,...
  'MTEX:eulerCorrectionRotation:setting','The setting has to be 0 to 4.');

rot = rotCorrection(setting+1);

end
