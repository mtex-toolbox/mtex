function ebsd = copy(ebsd,id)
% copy selected points from EBSD data
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

smpsz = sampleSize(ebsd);
cs = cumsum([0,smpsz]);
if isa(id,'double'),  
  x = zeros(1,cs(end));
  x(id) = 1;
  id = logical(x);
end


for i=1:length(ebsd)
  idi = id(cs(i)+1:cs(i+1));
 
 	if ~isempty(ebsd(i).xy)
    ebsd(i).xy = ebsd(i).xy(idi,:);
  end

  ebsd_fields = fields(ebsd(i).options);  
  for f = 1:length(ebsd_fields)
     if numel(ebsd(i).options.(ebsd_fields{f})) == smpsz(i)
       ebsd(i).options.(ebsd_fields{f}) = ebsd(i).options.(ebsd_fields{f})(idi,:);
     end
  end
  
	ebsd(i).orientations = copy(ebsd(i).orientations,idi);  
end

% ebsd = ebsd(sampleSize(ebsd)>0); %causes empty ebsd

