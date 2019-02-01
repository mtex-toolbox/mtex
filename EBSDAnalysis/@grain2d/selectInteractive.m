function selectInteractive(grains,varargin)
% select interactively a rectangular region of an EBSD data set
%
% Syntax
%   selectInteractive(grains)
%   [ebsd_small,rec,id] = selectInteractive(ebsd)
%
% Input
%  grains - @grain2d
%
% Output
%  ebsd_small - @EBSD
%  rec - the rectangle
%  id  - id's of the selected data


id = false(size(grains)); % no grains selected initially 
id_handle = zeros(size(id)); % id to the graphical selections
mtexFig = gcm;

datacursormode off

set(gcf,'WindowButtonDownFcn',{@spatialSelection});

hold on
boundaryStyle = {'lineWidth',2,'lineColor','w'};

%waitfor(gcf)


  function spatialSelection(src,eventdata)
    
    pos = get(gca,'CurrentPoint');
        
    localId = findByLocation(grains,[pos(1,1) pos(1,2)]);

    if isempty(localId), return; end

    
    if id(localId)
      delete(id_handle(localId));
    else
      id_handle(localId) = plot(grains.subSet(localId).boundary,boundaryStyle{:});
      disp(['Grain selected: ' xnum2str(localId)])
    end
    id(localId) = ~id(localId);
        
  end

end



