function  checkInterfaces(type)

if nargin == 1
  % find all interfaces
  interfaces = dir([mtex_path '/interfaces/load' type '_*.m']);
  interfaces = {interfaces.name};
  % do not use interfaces generic
  ind = cellfun('isempty',strfind(interfaces,'generic'));
  interfaces = interfaces(ind);

  path = [mtexDataPath filesep type];
  
else
  interfaces = {};
  path = pwd;
  type = 'EBSD';
end

files = dir(path);
files = files(~[files.isdir]);
int = {};

for i = 1:length(files)
  
  try    
    [tmp,interface] = feval([type '.load'  ],fullfile(path,files(i).name),'wizard');    
    disp([files(i).name, repmat(' ',1,20-length(files(i).name)), ' - ', interface]);
    if ~isempty(interfaces)
      interfaces(strcmpi(interfaces,['load' type '_' interface '.m'])) = [];
    end
  catch
    disp([files(i).name, repmat(' ',1,20-length(files(i).name)), ' - FAILED']);
    %disp(lasterr);
  end  
end

if ~isempty(interfaces)  
  disp(' ');
  disp('There are unused interfaces:');  
  cprintf(interfaces.')
end

end


