function convertFigureRGB2ind(cmaplength)

% default resolution
if nargin < 1, cmaplength = 0.03;end

% get all CData
childs = findobj(gcf,'-property','CData');
CData = ensurecell(get(childs,'CData'));
  
% take only CData with RGB values
ind = cellfun(@(x) size(x,3)==3,CData);

childs = childs(ind);

if isempty(childs), return;end
    
CData = CData(ind);
  
% concatenate all CData to a big N x 1 x 3 matrix
combined = cellfun(@(x) reshape(x,[],1,3),CData,'uniformOutput',false);

combined = cat(1,combined{:});

% convert RGB data to colormap indexed data
[map,tmp,data] = unique(squeeze(combined),'rows');
if size(map,1) > 100
  [data, map] = rgb2ind(combined, cmaplength,'nodither');
end  

% NaN values should be white
ind = any(isnan(combined),3);
if any(ind(:))
  data(ind) = size(map,1)+1;
  map(end+1,1:3) = 1;
end

% set data back to graphic objects
pos = 1;
for ind = 1:numel(CData)
    
  s = size(CData{ind});
  set(childs(ind),'CDataMapping','direct','CData',...
    reshape(double(data(pos:pos+prod(s(1:2))-1)),s(1:2)));
  
  pos = pos + prod(s(1:2));
end

%set new colormap
set(gcf,'colormap',map);

end