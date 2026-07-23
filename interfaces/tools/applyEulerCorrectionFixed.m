function ebsd = applyEulerCorrectionFixed(ebsd,ext,defaultCorrection,varargin)
% apply a single fixed default Euler / map reference frame correction
%
% Shared by Oxford-style formats (.crc, .ctf) that always default to the
% same correction rotation (a 180 degree rotation about the z-axis)
% unless the user overrides it.
%
% Syntax
%   ebsd = applyEulerCorrectionFixed(ebsd,ext,defaultCorrection,varargin{:})
%
% Input
%  ebsd              - @EBSD
%  ext                - file extension used in the warning text, e.g. '.ctf'
%  defaultCorrection - @rotation applied unless overridden
%
% Options
%  EulerCorrection - explicit correction rotation, overrides defaultCorrection

correction = get_option(varargin,'EulerCorrection',defaultCorrection);

if ~check_option(varargin,'EulerCorrection') && ~check_option(varargin,'wizard')

  fprintf(2,wraptext(sprintf(['\nWarning: %s files usually come with different ' ...
    'coordinate systems for the Euler angles and the spatial coordinates. ' ...
    'I assumed the relative alignment of these coordinate systems to be a ' ...
    'rotation about the z-axis by 180 degree. You may want to verify this ' ...
    'and specify the correct alignment explicitely by\n\n' ...
    'ebsd = EBSD.load(fileName,''EulerCorrection'', rotation.byAxisAngle(zvector,180*degree))' ...
    '\n\n' ...
    'Click <a href="matlab:MTEXdoc(''EBSDReferenceFrame'')">here</a> for more information.'...
    '\n'],ext)))

end

ebsd.EulerCorrection = correction;

end
