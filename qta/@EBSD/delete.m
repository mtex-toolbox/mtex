function ebsd = delete(ebsd,id)
% delete points from EBSD data
%
%% Syntax  
% ebsd  = delete(ebsd,id)
% ebsd  = delete(ebsd,get(ebsd,'phase')~=1)
%
%% Input
%  ebsd   - @EBSD
%  id   - index set 
%
%% Output
%  ebsd - @EBSD
%
%% See also
% EBSD/get EBSD_index

if isa(id,'logical'), id = find(id);end
cs = cumsum([0,length(ebsd)]);

for i= 1:numel(ebsd)
 
	idi = id((id > cs(i)) & (id<=cs(i+1)));
  if ~isempty(ebsd.xy(i)),  ebsd.xy{i}(idi-cs(i),:) = [];end
  %if ~isempty(ebsd(i).phase), ebsd(i).phase(idi-cs(i)) = [];end
	ebsd.orientations(i) = delete(ebsd.orientations(i),idi-cs(i));
  
  vname = fields(ebsd.options);
  for k=1:length(vname)
    ebsd.options(1).(vname{k}){i}(idi-cs(i),:) = [];
  end
end
