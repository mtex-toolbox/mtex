function p = mtexCifPath

mtex_data_path = get_mtex_option('CIFPath');

if exist(mtex_data_path,'dir')
  p = mtex_data_path;
else
  error('Data package not installed!');
end
