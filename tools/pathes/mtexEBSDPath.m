function p = mtexEBSDPath
% returns the default path to EBSD data files
%
% Syntax
%   mtexEBSDPath 
%   getMTEXpref('EBSDPath') % long form of mtexEBSDPath
%   setMTEXpref('EBSDPath',path) % change the path to EBSD files
%
% See also
% mtexDataPath mtexCifPath mtexEBSDPath mtexPoleFigurePath mtexODFPath
% mtexTensorPath

DataPath = getMTEXpref('EBSDPath');

if exist(DataPath,'dir')
  p = DataPath;
else
  error('Data package not installed!');
end
