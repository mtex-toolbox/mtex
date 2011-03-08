function  checkInterfaces

files = dir([mtexDataPath filesep 'PoleFigure']);

for i = 4:length(files)
  
  close all
  disp(files(i).name);
  try
    pf = loadPoleFigure(fullfile(mtexDataPath,'PoleFigure',files(i).name));
  catch
    disp(lasterr);
  end
  plot(pf,'silent');
  
end

end

