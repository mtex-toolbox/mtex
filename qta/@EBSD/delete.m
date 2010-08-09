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
% EBSD/get EBSD/copy EBSD_index

cs = cumsum([0,sampleSize(ebsd)]);
if ~isa(id,'logical'),
  id = sparse(id,1,true,cs(end),1);
end

for i= 1:length(ebsd)
  ind = id(cs(i)+1:cs(i+1));
	
  if ~isempty(ebsd(i).xy), ebsd(i).xy(ind,:) = [];end

  ebsd_fields = fields(ebsd(i).options);  
  for f = 1:length(ebsd_fields)
    if numel(ebsd(i).options.(ebsd_fields{f})) == numel(ebsd(i).orientations)
      ebsd(i).options.(ebsd_fields{f})(ind,:) = [];
    end
  end
  
	ebsd(i).orientations(ind) = [];    
end
