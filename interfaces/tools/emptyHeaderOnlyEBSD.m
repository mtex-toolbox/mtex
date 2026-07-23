function ebsd = emptyHeaderOnlyEBSD(CSList,header,varargin)
% build an empty EBSD carrying only symmetry and header metadata
%
% Used by import interfaces' 'headerOnly' option to return an EBSD with
% no positions/orientations but a populated CSList/opt.header, without
% paying for the (potentially large) per-pixel/binary data read.
%
% Syntax
%   ebsd = emptyHeaderOnlyEBSD(CSList,header)
%   ebsd = emptyHeaderOnlyEBSD(CSList,header,'unitCell',unitCell)

% mirror phaseList.init's behaviour of ensuring at least one notIndexed
% phase is present, since that path is bypassed below
if all([CSList.isIndexed])
  CSList = [notIndexed, CSList(:).'];
end

% bypass phaseList.init (it mishandles an empty phase list together with
% more than one symmetry) by supplying phaseMap directly
phaseMap = (0:numel(CSList)-1)';

ebsd = EBSD(vector3d,rotation,[],CSList,struct(),'phaseMap',phaseMap,varargin{:});
ebsd.opt.header = header;

end
