files = dir('*.m').';

for f = files
  try
  run(f.name)
  fname = strrep(f.name,'.m','.json');
  C.export(fname);
  catch
    disp(['error converting ' f.name])
  end
end

%% generate a data table

files = dir('*.json').';

clear file mineral symmetry alignment density

for k = 1:length(files)
  
  f = files(k);
  
  C = stiffnessTensor.load(f.name);

  [~,file{k,1}] = fileparts(f.name);
  mineral{k,1} = C.CS.mineral;
  symmetry{k,1} = C.CS.pointGroup;
  a = C.CS.alignment;
  alignment{k,1} = [a{:}];
  
  try 
    density(k,1) = C.density; 
  catch
    density(k,1) = NaN;
  end
  
end

t = table(file,mineral,symmetry,density,alignment)

%%

writetable(t,'MainpricestiffnessTensors.xls')