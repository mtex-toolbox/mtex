function pf = loadPoleFigure_inel(fname,varargin)
% import pole figure data from an INEL "Fdt File" (*.int)
%
% Description
% The file lists one record per measured direction: the number, 2theta,
% theta, the tilt khi, three translations, the rotation phi and the
% intensity. The polar angle of the direction is the absolute tilt, its
% azimuth phi. The file names no reflection: pass it as a Miller, else it
% is read from the file name.
%
% Syntax
%   pf = loadPoleFigure_inel(fname,Miller(1,1,1,cs))
%
% Input
%  fname - file name
%  h     - @Miller, the reflection
%
% Output
%  pf - @PoleFigure
%
% See also
% PoleFigure.load

fid = efopen(fname);
cleanup = onCleanup(@() fclose(fid));

% the header begins with the file kind and ends with the column names
first = fgetl(fid);
assert(ischar(first) && startsWith(strtrim(first),'Fdt File'),'no INEL file');

line = '';
while ischar(line) && ~contains(line,'Khi')
  line = fgetl(fid);
end
assert(ischar(line),'no INEL data block');

if check_option(varargin,'check'), pf = PoleFigure; return; end

% NB 2Theta Theta Khi Tr.X Tr.Y Tr.Z Phi Value
d = textscan(fid,'%f %f %f %f %f %f %f %f %f');
khi = d{4}; phi = d{8}; I = d{9};

r = vector3d.byPolar(abs(khi)*degree,phi*degree,'antipodal');

% the reflection, given or guessed from the file name
h = getClass(varargin,'Miller');
if isempty(h)
  h = string2Miller(fname);
  warning('MTEX:loadPoleFigure_inel:noReflection',...
    'The INEL file names no reflection; %s is guessed from its file name. Pass a Miller to state it.',char(h));
end

pf = PoleFigure(h,r,I,varargin{:});

end
