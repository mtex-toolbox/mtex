function [ output_args ] = interfaceError( fname,fid )
%

[st] = dbstack(1);
i = find(strncmp('load',{st.name},4),1,'first');
interface = regexp(lower(st(i).name),'(?<=[a-z]*_)\w*','match');

try
  fclose(fid); 
catch
end

error('mtex:wrongInterface',...
  ['File not found or format ' upper(interface{1}) ' does not match the data\n file: ' fname]);