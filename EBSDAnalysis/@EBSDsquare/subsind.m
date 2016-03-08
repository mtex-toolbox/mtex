function ind = subsind(ebsd,subs)
% subindexing of EBSD data
%

% ordinary indexing by id
if (ischar(subs{1}) && subs{1}(1) == ':') || ...
    (isnumeric(subs{1}) && ~islogical(subs{1}))
  ind = reshape(1:length(ebsd),size(ebsd));
  
  ind = subsref(ind,struct('type','()','subs',{subs}));
  return
  
end

ind = subsind@EBSD(ebsd,subs);
