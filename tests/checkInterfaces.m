function  checkInterfaces

% find all interfaces
interfaces = dir([mtex_path '/qta/interfaces/loadPoleFigure_*.m']);
interfaces = {interfaces.name};
% do not use interfaces generic
ind = cellfun('isempty',strfind(interfaces,'generic'));
interfaces = interfaces(ind);


files = dir([mtexDataPath filesep 'PoleFigure']);

int = {};

for i = 4:length(files)
  
  try    
    [~,interface] = loadPoleFigure(fullfile(mtexDataPath,'PoleFigure',files(i).name));    
    disp([files(i).name, repmat(' ',1,20-length(files(i).name)), ' - ', interface]);
    interfaces = interfaces(cellfun('isempty',strfind(interfaces,interface)));
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


