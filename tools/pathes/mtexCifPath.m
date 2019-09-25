function p = mtexCifPath
% returns the default path to crystallographic information files (CIF)
%
% Syntax
%   mtexCifPath 
%   getMTEXpref('CIFPath') % long form of mtexCifPath
%   setMTEXpref('CIFPath',path) % change the path to CIF files
%
% See also
% mtexDataPath mtexCifPath mtexEBSDPath mtexPoleFigurePath mtexODFPath
% mtexTensorPath

DataPath = getMTEXpref('CIFPath');

if exist(DataPath,'dir')
  p = DataPath;
else
  error('Data package not installed!');
end
