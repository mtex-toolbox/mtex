function ebsd = loadEBSD_h5(fname,varargin)

if ~exist(fname,'file'), error(['File ' fname ' not found!']); end

ginfo = locFindEBSDGroups(fname);
  
if numel(ginfo) > 1
  
  groupNames = {ginfo.Name};
  
  patternMatch = false(size(groupNames));
  for k=1:numel(varargin)
    if ischar(varargin{k})
      patternMatch = patternMatch | strncmpi(groupNames,varargin{k},numel(varargin{k}));
    end
  end
  
  if nnz(patternMatch) == 0
    [sel,ok] = listdlg('ListString',{ginfo.Name},'ListSize',[400 300]);
    
    if ok
      ginfo = ginfo(sel);
    else
      return
    end
  else
    ginfo = ginfo(patternMatch);
  end
end

assert(numel(ginfo) > 1);
  
if check_option(varargin,'check'), ebsd = EBSD; return; end

try
  for k = 1:numel(ginfo)
    kGroup = ginfo(k);
    
    CS = locReadh5Phase(fname,kGroup);
    
    kGroupData = kGroup.Groups(1).Datasets;
    
    props = struct;
        
    for j=1:numel(kGroupData)
      
      if length(kGroupData(j).ChunkSize) > 1, continue; end
      data = double(h5read(fname,[kGroup.Groups(1).Name '/' kGroupData(j).Name]));

      name = strrep(kGroupData(j).Name,' ','_');
      
      name = strrep(name,'X_Position','x');
      name = strrep(name,'Y_Position','y');
      
      props.(name) = data(:);
    end

    rot = rotation('Euler',props.Phi1,props.Phi,props.Phi2);
    phases = props.Phase;
    
    props = rmfield(props,{'Phi','Phi1','Phi2','Phase'});
        
    ebsd = EBSD(rot,phases,CS,'options',props);
     
    ind = props.x > -11111;
    ebsd = ebsd(ind);
    ebsd.unitCell = calcUnitCell([ebsd.prop.x,ebsd.prop.y]);
    
    
  end      
end
  
end

function [ginfo] = locFindEBSDGroups(fname)

info = h5info(fname,'/');

ginfo = struct('Name',{},...
  'Groups',{},...
  'Datasets',{},...
  'Datatypes',{},...
  'Links',{},...
  'Attributes',{});

ginfo = locGr(fname, info.Groups,ginfo);
end

function [ginfo] = locGr(fname,group,ginfo)

if ~isempty(group)
  
  for k=1:numel(group)
    attr  = group(k).Attributes;
    name = group(k).Name;
    
    if (~isempty(attr) && check_option({attr.Value},'EBSD')) || strcmp(name(end-4:end),'/EBSD')
    
      ginfo(end+1) = group(k);
      
    end
    
    [ginfo] = locGr(fname,group(k).Groups,ginfo);
  end
end
end


function CS = locReadh5Phase(fname,group)
% load phase informations from h5 file
  
group = group.Groups(strcmp([group.Name '/Header'],{group.Groups.Name})); 
group = group.Groups(strcmp([group.Name '/Phase'],{group.Groups.Name}));

for iphase = 1:numel(group.Groups)
  
  mineral = strtrim(char(h5read(fname,[group.Groups(iphase).Name '/MaterialName'])));
  formula = strtrim(char(h5read(fname,[group.Groups(iphase).Name '/Formula'])));
  abc(1) = h5read(fname,[group.Groups(iphase).Name '/Lattice Constant a']);
  abc(2) = h5read(fname,[group.Groups(iphase).Name '/Lattice Constant b']);
  abc(3) = h5read(fname,[group.Groups(iphase).Name '/Lattice Constant c']);
  
  abg(1) = h5read(fname,[group.Groups(iphase).Name '/Lattice Constant alpha']);
  abg(2) = h5read(fname,[group.Groups(iphase).Name '/Lattice Constant beta']);
  abg(3) = h5read(fname,[group.Groups(iphase).Name '/Lattice Constant gamma']);
  
  pointGroup = h5read(fname,[group.Groups(iphase).Name '/Point Group']);
  pointGroup = regexp(char(pointGroup),'\[([1-6m/\-]*)\]','tokens');
  pointGroup = pointGroup{1};
  
  try  
    CS{iphase} = crystalSymmetry(pointGroup,double(abc),double(abg)*degree,'mineral',mineral);
  catch
    CS{iphase} = 'notIndexed';
  end
end
  

end