function pf = loadPoleFigure_nja(fname,varargin)
% load Seifert nja pole figure file
%
% Syntax
%   pf = loadPoleFigure_nja(fname)
%
% Input
%  fname - file name
%
% Output
%  pf    - @PoleFigure
%
% See also
% PoleFigure.load PoleFigureImport

assertExtension(fname,'.nja');

try
  txt = fileread(fname);

  % the header names the reflection and how many values follow
  key = @(name) str2double(regexp(txt,['&' name '=(\S+)'],'tokens','once'));
  h = Miller(key('H'),key('K'),key('L'),crystalSymmetry('m-3m'));

  % the data block starts after the &NoValues line
  d = sscanf(txt(regexp(txt,'&NoValues=\d+','end','once')+1:end),'%f',[4 inf]).';
  assert(size(d,1) == key('NoValues'));

  r = vector3d.byPolar(d(:,1)*degree,d(:,2)*degree,'antipodal');
  pf = PoleFigure(h,r,d(:,3),'BACKGROUND',d(:,4),varargin{:});
catch
  interfaceError(fname);
end
