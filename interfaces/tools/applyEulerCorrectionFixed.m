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
%  EulerCorrection - explicit correction rotation, overrides defaultCorrection

correction = get_option(varargin,'EulerCorrection',defaultCorrection);

if ~check_option(varargin,'EulerCorrection') && ~check_option(varargin,'wizard')

  [corrTxt,corrCmd] = describeRotation(correction);

  fprintf(2,wraptext(sprintf(['\nWarning: %s files usually come with different ' ...
    'coordinate systems for the Euler angles and the spatial coordinates. ' ...
    'I assumed the relative alignment of these coordinate systems to be %s. ' ...
    'You may want to verify this and specify the correct alignment ' ...
    'explicitely by\n\n' ...
    'ebsd = EBSD.load(fileName,''EulerCorrection'', %s)' ...
    '\n\n' ...
    'Click <a href="matlab:MTEXdoc(''EBSDReferenceFrame'')">here</a> for more information.'...
    '\n'],ext,corrTxt,corrCmd)))

end

ebsd.EulerCorrection = correction;

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
