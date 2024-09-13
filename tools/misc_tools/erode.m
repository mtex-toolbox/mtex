function ebsd = erode(ebsd,count, varargin)
% do morphological erosion of pixels based on 
% neighbor counts
%
% Syntax
%
%   ebsd = erode(ebsd,0)
%
%   ebsd = erode(ebsd,2,'titanium')
%
%   ebsd = erode(ebsd,1,{'a' 'b' 'notIndexed'})
%
% Input
%  ebsd   - @EBSD
%  counts - upper threshold of same phase pixels around each pixel to permit erosion
%  phase  - phase name, cell or string
%
% Output
%  ebsd - @EBSD without the eroded pixels
% 
% Examples
%
% mtexdata small
% plot(ebsd); hold on
% plot(ebsd('n'),'FaceColor','k'); hold off;
% mtexTitle('original');  nextAxis
% 
% % erode isolated, nonIndexed points
% ebsd = erode(ebsd,0);
% plot(ebsd); hold on
% plot(ebsd('n'),'FaceColor','k'); hold off;
% mtexTitle('no single nonIndexed pixels');  nextAxis
% 
% % erode isolated, nonIndexed points
% for i=1:10
% ebsd = erode(ebsd,1,{'n' 'D' 'E'});
% end
% 
% plot(ebsd); hold on
% plot(ebsd('n'),'FaceColor','k'); hold off;
% mtexTitle('no n,D,E $\le$ 1 neighbors, 10 iter'); nextAxis
% 
% 
% % erode isolated, nonIndexed points
% 
% for i=1:10
% ebsd = erode(ebsd,2,{'n' 'D' 'E','F'});
% ebsd = ebsd.fill;
% end
% 
% plot(ebsd); hold on
% plot(ebsd('n'),'FaceColor','k'); hold off;
% mtexTitle('no n,D,E $\le$ 2 neighbors, filled,10 iter'); 
% 
% 

% check if already gridified
if any(size(ebsd)==1), ebsd = ebsd.gridify; end

% find the neighbors
if size(ebsd.unitCell,1) == 6
  ind = hexNeighbors(size(ebsd));
else
  ind = squareNeighbors2(size(ebsd));
end

% if varargin is empty use entire map as 1, notIndexed as 0
if isempty(varargin)
  zmap = ~ebsd.isIndexed;
end

% if phase name is supplied use it accordingly
if ~isempty(varargin) && isa(varargin{1},'char')
  uid = unique(ebsd(varargin{1}).phase);
  zmap = ebsd.phase == uid;
end


% if more than one phase is supplied use them all in order
if ~isempty(varargin) && isa(varargin{1},'cell')
  for i=1:length(varargin{1})
    % try only if phase exists
    try
      ebsd = erode(ebsd,count,varargin{1}{i});
    end
  end
end

% pixels to erode must be zmap AND have lower 
% neighbor count than threshold 
if exist('zmap','var')
   candidate = sum(zmap(ind),3) <= count;
   peroded =zmap(:) & candidate(:);
   ebsd(peroded) = [];
end

end
