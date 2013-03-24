function [ebsd,groups] = loadEBSD_h5(fname,varargin)



if ~exist(fname,'file')
  error(['File ' fname ' not found!']);
end


groups = locFindEBSDGroups(fname);


if numel(groups) > 1
  
  if check_option(varargin,groups)
    
    groups = extract_option(varargin,groups);
    
  else
    
    [sel,ok] = listdlg('ListString',groups,'ListSize',[400 300]);
    
    if ok
      groups = groups(sel);
    else
      return
    end
  end
end

if check_option(varargin,'check')
  ebsd = EBSD;
  return
end


for k = 1:numel(groups)
  kGroup = groups{k};
  
  
  CS = locReadh5Phase(fname,kGroup);
  
  kGroupInfo = h5info(fname,kGroup);
  kGroupData = {kGroupInfo.Datasets.Name};
  
  if check_option(kGroupData,'Orientations')
    oinfo = h5info(fname,[kGroup '/Orientations']);
    opts =[{oinfo.Attributes.Name};{oinfo.Attributes.Value}];
    
    data = h5read(fname,[kGroup '/Orientations'])';
    data = mat2cell(data,size(data,1),ones(1,size(data,2)));
    
    q = rotation(get_option(opts,'Parameterization','Euler'),...
      data{:},get_option(opts,'Convention','ZXZ'));
  end
  
  if check_option(kGroupData,'PhaseIndex')
    
    phaseIndex = double(h5read(fname,[kGroup '/PhaseIndex']));
    
  end
  
  props = struct;
  
  if check_option(kGroupData,'SpatialCoordinates')
    
    xyinfo = h5info(fname,[kGroup '/SpatialCoordinates']);
    options = [{xyinfo.Attributes.Name};{xyinfo.Attributes.Value}];
    
    xy = double(h5read(fname,[kGroup '/SpatialCoordinates/']))';
    
    if size(xy,2) >= 2
      props.x = xy(:,1);
      props.y = xy(:,2);
    end
    
    if size(xy,2) == 3
      props.z = xy(:,3);
    end
    
  else
    options = {};
  end
  
  kGroupSub = {kGroupInfo.Groups.Name};
  
  if check_option(kGroupSub,[kGroup '/Properties'])
    propinfo = h5info(fname,[kGroup '/Properties']);
    fn = {propinfo.Datasets.Name};
    
    for j=1:numel(fn)
      props.(fn{j}) = double(h5read(fname,[kGroup '/Properties/' fn{j}]))';
    end
  end
  
  ebsd{k} = EBSD(q,CS,'phase',phaseIndex,'options',props,options{:});
  
end

ebsd = [ebsd{:}];


function groups = locFindEBSDGroups(fname)

info = h5info(fname,'/');


groups = locGr(fname, info,{});


function grps = locGr(fname,group,grps)

if ~isempty(group)
  
  for k=1:numel(group)
    attr  = group(k).Attributes;
    
    if ~isempty(attr) && check_option({attr.Value},'EBSD')
        grps{end+1} = group(k).Name;
    end
    
    grps = locGr(fname,group(k).Groups,grps);
  end
end



function CS = locReadh5Phase(fname,group)

ph_info = h5info(fname,[group '/Phase']);

data = ph_info.Datasets;

for k=1:numel(data)
  attr = [{data(k).Attributes.Name}; {data(k).Attributes.Value}];
  
  
  name = get_option(attr,'Name','-1');
  
  if check_option(attr,{'laue','a','b','c'})
    
    axes = [get_option(attr,'a',1); get_option(attr,'b',1);get_option(attr,'c',1)];
    ang  = [get_option(attr,'alpha',1); get_option(attr,'beta',1);get_option(attr,'gamma',1)];
    
    mineral = get_option(attr,'mineral');
    %   get_option(attr,'color')
    alignment  =get_option(attr,'Alignment');
    
    CS{k} = symmetry(name,axes,ang,alignment,'mineral',mineral);
    
  else
    
    CS{k} = 'not indexed';
    
  end
end


