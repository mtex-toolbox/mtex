function [ output_args ] = interfaceError( fname,fid )
%

if ~exist(fname,'file')
  e = MException('mtex:fileNotFound',...
    ['File ''' fname ''' not found']);
  throwAsCaller(e);
end


[st] = dbstack(1);
i = find(strncmp('load',{st.name},4),1,'first');
name = st(i).name;

type = regexp(name,'(?<=load)(\w*)(?=_)','match');
interface = regexp(lower(name),'(?<=[a-z]*_)\w*','match');

if nargin > 1
  try
    fclose(fid);
  catch
  end
end


fname = regexprep(fname,'\','/');

e = MException('mtex:wrongInterface',...
  [type{1} ' format ''' upper(interface{1}) ''' does not match the data\n file: ''' fname '''']);
throwAsCaller(e);
