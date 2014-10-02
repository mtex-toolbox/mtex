function phases = cprproject_read(fname)

cf = file2cell(fname);

phasePos = strmatch('[Phase',cf);

Laue{1}='-1';Laue{2}='2/m';Laue{3}='mmm';Laue{4}='4/m';Laue{5}='4/mmm';
Laue{6}='-3';Laue{7}='-3m';Laue{8}='6/m';Laue{9}='6/mmm';Laue{10}='m3';
Laue{11}='m3m';

phases = cell(0);
for k=1:length(phasePos)
  pos = phasePos(k);
  phase = sscanf(cf{pos},'[Phase%u]');
  if ~isempty(phase)
    mineral = sscanf(cf{pos+2},'StructureName=%100c');
    
    axis = [ ...
      sscanf(cf{pos+5},'a=%f'), ...
      sscanf(cf{pos+6},'b=%f'), ...
      sscanf(cf{pos+7},'c=%f')];
    angle = [...
      sscanf(cf{pos+8},'alpha=%f'),...
      sscanf(cf{pos+9},'beta=%f'),...
      sscanf(cf{pos+10},'gamma=%f')].*degree;
    
    laue =  Laue{ sscanf(cf{pos+11},'LaueGroup=%u') };
    
    phases{phase} = crystalSymmetry(laue,axis,angle,'mineral',mineral);
  end
end
