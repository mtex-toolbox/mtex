function  checkInterfaces

files = dir([mtexDataPath filesep 'PoleFigureData']);

for i = 3:length(files)
  
  close all
  disp(files(i).name);
  pf = loadPoleFigure([mtexDataPath filesep 'PoleFigureData' filesep files(i).name]);
  
  plot(pf,'silent');
  
end

end

