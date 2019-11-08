function p = mtexExamplePath
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

examplePath = getMTEXpref('ExamplePath');

if exist(examplePath,'dir')
  p = examplePath;
else
  error('Examples not found!');
end
