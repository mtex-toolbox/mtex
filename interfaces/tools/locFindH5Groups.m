function [ginfo] = locFindH5Groups(fname,pattern)
% modified from loadEBSD_h5 function [ginfo] = locFindEBSDGroups(fname)
% extended to take any string pattern not just 'EBSD'

info = h5info(fname,'/');

ginfo = struct('Name',{},...
  'Groups',{},...
  'Datasets',{},...
  'Datatypes',{},...
  'Links',{},...
  'Attributes',{});

ginfo = locGr(fname, info.Groups,ginfo,pattern);
end

function [ginfo] = locGr(fname,group,ginfo,pattern)

if ~isempty(group)

  for k=1:numel(group)
    attr  = group(k).Attributes;
    name = group(k).Name;

    if (~isempty(attr) && check_option({attr.Value},pattern)) || endsWith(name,pattern)
      ginfo(end+1) = group(k);
    end

    [ginfo] = locGr(fname,group(k).Groups,ginfo,pattern);
  end
end
end