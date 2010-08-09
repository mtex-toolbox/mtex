function ebsd = copy(ebsd,condition)
% copy selected points from EBSD data
%
%% Syntax  
% ebsd  = copy(ebsd,condition)
% ebsd  = copy(ebsd,get(ebsd,'phase')~=1)
%
%% Input
%  ebsd      - @EBSD
%  condition - index set 
%
%% Output
%  ebsd - @EBSD
%
%% See also
% EBSD/get EBSD/copy EBSD_index

smpsz = sampleSize(ebsd);
cs = cumsum([0,smpsz]);
if isa(condition,'double'),  
  x = zeros(1,cs(end));
  x(condition) = 1;
  condition = logical(x);
end


for i=1:length(ebsd)
  idi = condition(cs(i)+1:cs(i+1));
 
 	if ~isempty(ebsd(i).xy)
    ebsd(i).xy = ebsd(i).xy(idi,:);
  end

  ebsd_fields = fields(ebsd(i).options);  
  for f = 1:length(ebsd_fields)
     if numel(ebsd(i).options.(ebsd_fields{f})) == smpsz(i)
       ebsd(i).options.(ebsd_fields{f}) = ebsd(i).options.(ebsd_fields{f})(idi,:);
     end
  end
  
	ebsd(i).orientations = ebsd(i).orientations(idi);  
end

% ebsd = ebsd(sampleSize(ebsd)>0); %causes empty ebsd

