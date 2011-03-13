function [members_ebsd members_grains ids] = assert_checksum(grains,ebsd)


opts = struct(ebsd);

checksum = ['grain_id', dec2hex(grains(1).checksum)];
 
a = grains(1).checksum;
b = get(grains,'checksum');

if any(a ~= b)
	error('operation with grain compositions not supported');
elseif any(strcmpi( checksum, fields(opts(1).options)))
  ids = get(ebsd,checksum);
  gids = get(grains,'id');
 	members_ebsd = ismember(ids,gids);
  if nargout > 1
    ids = ids(members_ebsd);
    members_grains = ismember(gids, ids);
  end
  return
else
  error(['assure that you are operating '...
      'with the correct grains corresponding to your ebsd data']);
end