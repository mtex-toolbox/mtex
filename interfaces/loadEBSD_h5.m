function [ebsd,groups] = loadEBSD_h5(fname,varargin)


try
  
  if ~exist(fname,'file')
    error(['File ' fname ' not found!']);
  end
  
  
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
  
  if check_option(varargin,'check')
    ebsd = EBSD;
    groups = {ginfo.Name};
    return
  end
  
  
  for k = 1:numel(ginfo)
    kGroup = ginfo(k);
    
    CS = locReadh5Phase(fname,kGroup);
    
    kGroupData = kGroup.Datasets;
    
    props = struct;
    options = {};
    
    for j=1:numel(kGroupData)
      switch kGroupData(j).Name
        case 'Orientations'
          
          opts =[{kGroupData(j).Attributes.Name};{kGroupData(j).Attributes.Value}];
          
          data = h5read(fname,[kGroup.Name '/Orientations'])';
          data = mat2cell(data,size(data,1),ones(1,size(data,2)));
          
          q = rotation(get_option(opts,'Parameterization','Euler'),...
            data{:},get_option(opts,'Convention','ZXZ'));
          
        case 'PhaseIndex'
          
          phaseIndex = double(h5read(fname,[kGroup.Name '/PhaseIndex']))';
          
        case 'SpatialCoordinates'
          
          options = [{kGroupData(j).Attributes.Name};{kGroupData(j).Attributes.Value}];
          
          xy = double(h5read(fname,[kGroup.Name '/SpatialCoordinates']))';
          
          if size(xy,2) >= 2
            props.x = xy(:,1);
            props.y = xy(:,2);
          end
          
          if size(xy,2) == 3
            props.z = xy(:,3);
          end
          
        otherwise
          
      end
      
    end
    
    kSubGroup = kGroup.Groups;
    
    for j=1:numel(kSubGroup)
      switch kSubGroup(j).Name
        case [kGroup.Name '/Phase']
          
        case [kGroup.Name '/Properties']
          kSubGroupData = kSubGroup(j).Datasets;
          
          for l=1:numel(kSubGroupData)
            kField = kSubGroupData(l).Name;
            props.(kField) = double(h5read(fname,[kGroup.Name '/Properties/' kField]))';
          end
          
        otherwise
          
          
      end
      
    end
    
    % TODO
    ebsd{k} = EBSD(q,phaseIndex,CS,'options',props,'comment',kGroup.Name,options{:});
    
  end
  
  if ~check_option(varargin,'cellEBSD')
    ebsd = [ebsd{:}];
  end
  
catch
  interfaceError(fname)
end


function [ginfo] = locFindEBSDGroups(fname)

info = h5info(fname,'/');

ginfo = struct('Name',{},...
  'Groups',{},...
  'Datasets',{},...
  'Datatypes',{},...
  'Links',{},...
  'Attributes',{});

ginfo = locGr(fname, info,ginfo);


function [ginfo] = locGr(fname,group,ginfo)

if ~isempty(group)
  
  for k=1:numel(group)
    attr  = group(k).Attributes;
    
    if ~isempty(attr) && check_option({attr.Value},'EBSD')
      ginfo(end+1) = group(k);
      
    end
    
    [ginfo] = locGr(fname,group(k).Groups,ginfo);
  end
end



function CS = locReadh5Phase(fname,group)


phaseGroup = group.Groups(strcmp([group.Name '/Phase'],{group.Groups.Name}));


data = phaseGroup.Datasets;

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


