function ebsd = applyEulerCorrectionTable(ebsd,ext,varargin)
% apply a 4-setting Euler / map reference frame correction
%
% Shared by EDAX-style formats (.ang, .osc, .edaxh5) that expose the Euler
% <-> map alignment as a "setting" 1 to 4. Since the setting is not stored
% in the file, setting 2 is assumed and a note is printed - unless the user
% states the alignment or the import wizard did it already.
%
% Syntax
%   ebsd = applyEulerCorrectionTable(ebsd,ext,varargin{:})
%
% Input
%  ebsd - @EBSD
%  ext  - file extension used in the note, e.g. '.ang'
%
% Options
%  setting          - 0 (no correction) to 4, default is 2
%  EulerCorrection  - explicit correction rotation, overrides setting
%  wizard           - suppress the note about the assumed setting

% setting 2 is by far the most common one and hence the default
corSetting = get_option(varargin,'setting',2);

% tell the user about it unless the alignment was specified explicitly
isAssumed = ~check_option(varargin,{'setting','EulerCorrection','wizard'});

if corSetting > 0 || check_option(varargin,'EulerCorrection')

  % change reference frame - the table is shared with the exporters, which
  % have to undo exactly this rotation again
  rot = get_option(varargin,'EulerCorrection',eulerCorrectionRotation(corSetting));

  % correct rotations
  ebsd.EulerCorrection = rot;

end

if isAssumed

  mtexWarning('MTEX:eulerCorrectionAssumed', ...
    ['%s files come with different coordinate systems for the Euler angles ' ...
    'and the spatial coordinates. Their relative alignment is chosen when exporting ' ...
    'the data from your EBSD maschine and is labeled as setting 1 to setting 4. ' ...
    'Since it is not stored in the file MTEX assumes the most common setting 2. ' ...
    'If your data was exported with a different alignment specify it when ' ...
    'importing the data using the syntax\n\n' ...
    'ebsd = EBSD.load(fileName,''setting'', 3)' ...
    '\n\n' ...
    'or switch the correction off by ''setting'', 0.\n\n' ...
    'Click %s for more information.'],ext,doclink('EBSDReferenceFrame','here'))

end

end
