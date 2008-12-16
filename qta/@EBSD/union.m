function ebsd = union(ebsd)
% merges ebsd objects

phases = {unique(cell2mat(ebsd.phase))};
if length(ebsd.phase) > 1,
  warning('mtex:EBSD:differentPhases','phases missmatch, this might affect crystal symmetry'); 
 % return
end;

ebsd.phase = phases;
ebsd.orientations = union(ebsd.orientations);
if ~isempty(ebsd.xy)
  ebsd.xy =   mat2cell(cell2mat(ebsd.xy),size(ebsd,2),2);
end
if ~isempty(ebsd.grainid), ebsd.grainid = mat2cell(cell2mat(ebsd.grainid),size(ebsd,2),1);end

vname = fields(ebsd.options);
for k=1:length(vname)
  ebsd.options(1).(vname{k}) = mat2cell(cell2mat(ebsd.options(1).(vname{k})),size(ebsd,2),1);end
end