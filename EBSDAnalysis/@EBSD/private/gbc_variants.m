function criterion = gbc_variants(ori,~,Dl,Dr,ids,varargin)

errorcheck = all(length(ori)==length(ids) & all(floor(ids) == ids));
assert(errorcheck,'Provide a list of valid variant IDs to compute grains from variant Ids');

% all ids need to be the same
criterion = all(ids(Dl,:) == ids(Dr,:),2);