function p = mtexTensorPath
% returns the default path to tensor-files
%
% Syntax
%   mtexTensorPath
%   getMTEXpref('TensorPath') % long form of mtexTensorPath
%   setMTEXpref('TensorPath',path) % change the path to Tensor files
%
% See also
% mtexDataPath mtexCifPath mtexEBSDPath mtexPoleFigurePath mtexODFPath
% mtexTensorPath


DataPath = getMTEXpref('TensorPath');

if exist(DataPath,'dir')
  p = DataPath;
else
  error('Data package not installed!');
end
