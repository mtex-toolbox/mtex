function ebsd = applyEulerCorrectionFixed(ebsd,ext,defaultCorrection,varargin)
% apply a single fixed default Euler / map reference frame correction
%
% Shared by Oxford-style formats (.crc, .ctf) that always default to the
% same correction rotation unless the user overrides it. The warning about
% the assumed alignment is generated from that rotation.
%
% Syntax
%   ebsd = applyEulerCorrectionFixed(ebsd,ext,defaultCorrection,varargin{:})
%
% Input
%  ebsd              - @EBSD
%  ext               - file extension used in the warning text, e.g. '.ctf'
%  defaultCorrection - @rotation applied unless overridden
%
% Options
%  EulerCorrection   - explicit correction rotation, overrides defaultCorrection
%  acquisitionEuler  - the acquisition surface orientation stated by the file,
%                      [phi1 Phi phi2] in degree, reported to the user

correction = get_option(varargin,'EulerCorrection',defaultCorrection);

if ~check_option(varargin,'EulerCorrection') && ~check_option(varargin,'wizard')

  [corrTxt,corrCmd] = describeRotation(correction);

  mtexWarning('MTEX:eulerCorrectionAssumed', ...
    ['%s files usually come with different ' ...
    'coordinate systems for the Euler angles and the spatial coordinates. ' ...
    'I assumed the relative alignment of these coordinate systems to be %s. ' ...
    'You may want to verify this and specify the correct alignment ' ...
    'explicitely by\n\n' ...
    'ebsd = EBSD.load(fileName,''EulerCorrection'', %s)' ...
    '\n\n' ...
    'Click %s for more information.'], ...
    ext,corrTxt,corrCmd,doclink('EBSDReferenceFrame','here'))

  % the note refers to the assumption made just above, so it belongs to it -
  % a caller who states the alignment has already made that decision
  reportAcquisitionSurface(get_option(varargin,'acquisitionEuler',[]))

end

ebsd.EulerCorrection = correction;

end

% -----------------------------------------------------------------------

function reportAcquisitionSurface(acq)
% report the acquisition surface orientation the file states
%
% This is the only reference frame information a .ctf or .cpr carries at
% all - AcqE1/2/3 and the [Acquisition Surface] section respectively, the
% same value in both when a map is exported twice. It is *not* applied:
% Oxford's own h5oina specification calls the same quantity
% "Specimen Orientation Euler" and defines it as sample-surface (CS1) to
% sample-primary (CS0), i.e. the specimen frame the Euler angles are
% referred to, not their alignment with the map. A non default value is
% still worth knowing, since it says the acquisition was not set up the
% way the assumed correction above takes for granted.

if isempty(acq) || all(abs(acq) < 1e-4), return; end

% keep the published documentation free of a note that depends on which
% file an example happens to use
if getMTEXpref('generatingHelpMode'), return; end

mtexWarning('MTEX:acquisitionSurface',['the file states an acquisition surface ' ...
  'orientation of (%s) degree. MTEX does not apply it - it describes the ' ...
  'specimen reference frame the Euler angles were referred to, not their ' ...
  'alignment with the map - but a value other than zero tells you that the ' ...
  'acquisition was not set up the way the assumed alignment above takes for ' ...
  'granted, so it is worth verifying. It is kept in ebsd.opt.header.'], ...
  strtrim(xnum2str(acq(:).','delimiter',', ')))

end

% -----------------------------------------------------------------------

function [txt,cmd] = describeRotation(rot)
% describe a rotation in words and as the command that generates it

if rot.angle < 1e-4*degree
  txt = 'the identity, i.e. both coordinate systems coincide';
  cmd = 'rotation.id';
  return
end

ax = normalize(rot.axis);
axNames = {'xvector','yvector','zvector'};

% for a 180 degree rotation the sign of the axis is arbitrary - use the
% representative with a positive leading component
d = ax.xyz;
if abs(rot.angle - pi) < 1e-4 && d(find(abs(d)>1e-6,1)) < 0
  ax = -ax;
end

d = dot([xvector,yvector,zvector],ax);
[dMax,i] = max(abs(d));

if dMax > 1-1e-4 % the axis is one of the coordinate axes
  vz = repmat('-',1,d(i)<0);
  axTxt = [vz axNames{i}(1) '-axis'];
  axCmd = [vz axNames{i}];
else
  axStr = strtrim(xnum2str(ax.xyz,'precision',0.001,'delimiter',','));
  axTxt = ['axis (' axStr ')'];
  axCmd = ['vector3d(' axStr ')'];
end

angStr = strtrim(xnum2str(rot.angle./degree));
txt = sprintf('a rotation about the %s by %s degree',axTxt,angStr);
cmd = sprintf('rotation.byAxisAngle(%s,%s*degree)',axCmd,angStr);

end
