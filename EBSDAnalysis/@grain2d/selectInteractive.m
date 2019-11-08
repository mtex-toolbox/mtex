function selectInteractive(grains,varargin)
% select interactively a rectangular region of an EBSD data set
%
% Syntax
%   selectInteractive(grains)
%
%   global indSelected
%   plot(grains(indSelected))
%
% Input
%  grains - @grain2d
%
% Output
%  idSelected - id's of the selected grains, global variable
%
% See also
% EBSD/selectInteractive

id = false(size(grains)); % no grains selected initially 
id_handle = zeros(size(id)); % id to the graphical selections

datacursormode off

set(gcf,'WindowButtonDownFcn',{@spatialSelection});

hold on
boundaryStyle = [{'lineWidth',4,'lineColor','w'},extract_argoption(varargin,{'linewidth','linecolor'})];

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
    global indSelected;
    indSelected = find(id);
    %assignin('caller','indSelected',);
    
  end

end
