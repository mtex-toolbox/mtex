function  checkInterfaces

files = dir([mtexDataPath filesep 'PoleFigureData']);

for i = 4:length(files)
  
  close all
  disp(files(i).name);
  try
    pf = loadPoleFigure([mtexDataPath filesep 'PoleFigureData' filesep files(i).name]);
  catch
    disp(lasterr);
  end
  plot(pf,'silent');
  
end

end

