function p = mtexCifPath
% returns the default path to crystallographic information files (CIF)
%
%% Syntax 
% mtexCifPath - 
% get_mtex_option('CIFPath') - long form of mtexCifPath
% set_mtex_option('CIFPath',path) - change the path to CIF files 
%
%% See also
% mtexDataPath mtexCifPath mtexEBSDPath mtexPoleFigurePath mtexODFPath
% mtexTensorPath get_mtex_option set_mtex_option

mtex_data_path = get_mtex_option('CIFPath');

if exist(mtex_data_path,'dir')
  p = mtex_data_path;
else
  error('Data package not installed!');
end
