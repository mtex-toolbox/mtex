function  checkInterfaces(type)

% find all interfaces
interfaces = dir([mtex_path '/interfaces/load' type '_*.m']);
interfaces = {interfaces.name};
% do not use interfaces generic
ind = cellfun('isempty',strfind(interfaces,'generic'));
interfaces = interfaces(ind);


files = dir([mtexDataPath filesep type]);

int = {};

for i = 4:length(files)
  
  try    
    [tmp,interface] = feval([type '.load'  ],fullfile(mtexDataPath,type,files(i).name));    
    disp([files(i).name, repmat(' ',1,20-length(files(i).name)), ' - ', interface]);
    interfaces(strcmpi(interfaces,['load' type '_' interface '.m'])) = [];
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


