function hdr = importedHeader(ebsd)
% the header of the file a map was imported from, empty if there is none

hdr = struct();

if isfield(ebsd.opt,'header') && isstruct(ebsd.opt.header)
  hdr = ebsd.opt.header;
end

end
