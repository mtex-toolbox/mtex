function p = mtexDataPath
% returns the default path to mtex sample data
%
%% Syntax 
% mtexDataPath - 
% get_mtex_option('mtex_data_path') - long form of mtexDataPath
% set_mtex_option('mtex_data_path',path) - change the path to mtex data
%
%% See also
% mtexDataPath mtexCifPath mtexEBSDPath mtexPoleFigurePath mtexODFPath
% mtexTensorPath get_mtex_option set_mtex_option

mtex_data_path = get_mtex_option('mtex_data_path');

if exist(mtex_data_path,'dir')
  p = mtex_data_path;
else
  error('Data package not installed!');
end
