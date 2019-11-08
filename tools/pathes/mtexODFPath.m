function p = mtexODFPath
% returns the default path to ODF-files
%
% Syntax
%   mtexODFPath %
%   getMTEXpref('ODFPath') % long form of mtexODFPath
%   setMTEXpref('ODFPath',path) % change the path to ODF files
%
% See also
% mtexDataPath mtexCifPath mtexEBSDPath mtexPoleFigurePath mtexODFPath
% mtexTensorPath

DataPath = getMTEXpref('ODFPath');

if exist(DataPath,'dir')
  p = DataPath;
else
  error('Data package not installed!');
end
