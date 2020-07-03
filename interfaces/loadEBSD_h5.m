function [ebsd, header] = loadEBSD_h5(fname,varargin)

if ~exist(fname,'file'), error(['File ' fname ' not found!']); end

ginfo = locFindEBSDGroups(fname);

if numel(ginfo) > 0

  groupNames = {ginfo.Name};

  patternMatch = false(size(groupNames));
  for k=1:numel(varargin)
    if ischar(varargin{k})
      patternMatch = patternMatch | strncmpi(groupNames,varargin{k},numel(varargin{k}));
    end
  end

  if nnz(patternMatch) == 0
    if length(ginfo) > 1
      [sel,ok] = listdlg('ListString',{ginfo.Name},'ListSize',[400 300]);

      if ok
        ginfo = ginfo(sel);
      else
        return
      end
    end
  else
    ginfo = ginfo(patternMatch);
  end
end

assert(numel(ginfo) > 0);
  
if check_option(varargin,'check'), ebsd = EBSD; header = {}; return; end

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
      name = strrep(name,'X_SAMPLE','x');
      name = strrep(name,'Y_SAMPLE','y');

      name = regexprep(name,'phi','Phi','ignorecase');
      name = regexprep(name,'phi1','phi1','ignorecase');
      name = regexprep(name,'phi2','phi2','ignorecase');

      props.(name) = data(:);
    end

    
    % sometimes not indexed orientations are marked as 4*pi
    notIndexed = isappr(props.phi1,4*pi,1e-5);
    if all(props.phi1(~notIndexed)<=2.001*pi) ...
        && all(props.Phi(~notIndexed)<=1.001*pi) ...
        && all(props.phi2(~notIndexed)<=2.001*pi)
          
      props.phi1(notIndexed) = NaN;
      props.phi2(notIndexed) = NaN;
      props.Phi(notIndexed) = NaN;
      
      isDegree = 1;
      
    else    
      isDegree = degree;
    end
      
    rot = rotation.byEuler(props.phi1*isDegree,props.Phi*isDegree,props.phi2*isDegree);
    phases = props.Phase;

    props = rmfield(props,{'Phi','phi1','phi2','Phase'});

    ebsd = EBSD(rot,phases,CS,props);

    ind = props.x > -11111;
    ebsd = ebsd(ind);
    ebsd.unitCell = calcUnitCell([ebsd.prop.x,ebsd.prop.y]);

    if length(kGroup.Groups) > 1
      header = h5group2struct(fname,kGroup.Groups(2));
    else
      header = [];
    end

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
token = [group.Name '/Phase'];
group = group.Groups(strncmp(token,{group.Groups.Name},length(token)));

for iphase = 1:numel(group.Groups)

  try
    mineral = strtrim(char(h5read(fname,[group.Groups(iphase).Name '/MaterialName'])));
  catch
    mineral = strtrim(char(h5read(fname,[group.Groups(iphase).Name '/Name'])));
  end
  formula = strtrim(char(h5read(fname,[group.Groups(iphase).Name '/Formula'])));

  try
    lattice(1) = h5read(fname,[group.Groups(iphase).Name '/Lattice Constant a']);
    lattice(2) = h5read(fname,[group.Groups(iphase).Name '/Lattice Constant b']);
    lattice(3) = h5read(fname,[group.Groups(iphase).Name '/Lattice Constant c']);

    lattice(4) = h5read(fname,[group.Groups(iphase).Name '/Lattice Constant alpha']);
    lattice(5) = h5read(fname,[group.Groups(iphase).Name '/Lattice Constant beta']);
    lattice(6) = h5read(fname,[group.Groups(iphase).Name '/Lattice Constant gamma']);

    pointGroup = h5read(fname,[group.Groups(iphase).Name '/Point Group']);
    pointGroup = regexp(char(pointGroup),'\[([1-6m/\-]*)\]','tokens');
    spaceGroup = pointGroup{1};

  catch
    lattice = h5read(fname,[group.Groups(iphase).Name '/LatticeConstants']);

    spaceGroup = h5read(fname,[group.Groups(iphase).Name '/SpaceGroup']);
    spaceGroup = strrep(spaceGroup,'#ovl','-');
    spaceGroup = strrep(spaceGroup,'#sub','');
  end

  try
    CS{iphase} = crystalSymmetry(spaceGroup,double(lattice(1:3)),double(lattice(4:6))*degree,'mineral',mineral);
  catch
    CS{iphase} = 'notIndexed';
  end
end


end
