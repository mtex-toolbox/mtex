function [members_ebsd members_grains ids] = assert_checksum(grains,ebsd)



checksum = (unique([grains.checksum]));  
checksums = strcat('grain_id', cellstr(dec2hex(checksum)));
opts = struct(ebsd);

if length(checksums) > 1  
	error('operation with grain compositions not supported');
elseif any(strcmpi(checksums, fields(opts(1).options)))
  ids = get(ebsd,checksums{:});
  gids = [grains.id];
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