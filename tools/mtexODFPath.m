function p = mtexODFPath
% returns the default path to ODF-files
%
%% Syntax 
% mtexODFPath - 
% get_mtex_option('ODFPath') - long form of mtexODFPath
% set_mtex_option('ODFPath',path) - change the path to ODF files 
%
%% See also
% mtexDataPath mtexCifPath mtexEBSDPath mtexPoleFigurePath mtexODFPath
% mtexTensorPath get_mtex_option set_mtex_option

mtex_data_path = get_mtex_option('ODFPath');

if exist(mtex_data_path,'dir')
  p = mtex_data_path;
else
  error('Data package not installed!');
end
