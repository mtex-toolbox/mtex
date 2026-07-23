function ebsd = applyEulerCorrectionTable(ebsd,ext,varargin)
% apply a 4-setting Euler / map reference frame correction
%
% Shared by EDAX-style formats (.ang, .osc) that expose the Euler <-> map
% alignment as a "setting" 1 to 4, plus a fixed default under 'wizard'.
%
% Syntax
%   ebsd = applyEulerCorrectionTable(ebsd,ext,varargin{:})
%
% Input
%  ebsd - @EBSD
%  ext  - file extension used in the warning text, e.g. '.ang'
%
% Options
%  setting          - 0 (no correction, default) to 4
%  EulerCorrection  - explicit correction rotation, overrides setting
%  wizard           - defaults setting to 2 instead of 0

if check_option(varargin,'wizard')
  corSetting = 2;
else
  corSetting = 0;
end
corSetting = get_option(varargin,'setting',corSetting);

if corSetting > 0 || check_option(varargin,'EulerCorrection')

  % change reference frame
  rotCorrection = [rotation.id,...
    rotation.byAxisAngle(xvector+yvector,180*degree),... % setting 1
    rotation.byAxisAngle(xvector-yvector,180*degree),... % setting 2
    rotation.byAxisAngle(xvector,180*degree),...         % setting 3
    rotation.byAxisAngle(yvector,180*degree)];           % setting 4

  rot = get_option(varargin,'EulerCorrection',rotCorrection(corSetting+1));

  % correct rotations
  ebsd.EulerCorrection = rot;

else

  fprintf(2,wraptext(sprintf(['\nWarning: %s files usually come with different coordinate systems for the Euler angles ' ...
    'and the spatial coordinates. The relative alignment of these coordinate ' ...
    'systems files can be specified when exporting the data from your EBSD maschine ' ...
    'and are labeled as setting 1 to setting 4. Please specifiy this setting ' ...
    'when importing the data using the syntax\n\n' ...
    'ebsd = EBSD.load(fileName,''setting'', 2)' ...
    '\n\n' ...
    'Click <a href="matlab:MTEXdoc(''EBSDReferenceFrame'')">here</a> for more information.'...
    '\n'],ext)))

end

end
