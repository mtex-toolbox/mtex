function colorbar(mtexFig,varargin)

if isempty(mtexFig.cBarAxis) % create some new colorbars
    
  if ~mtexFig.keepAspectRatio
  
    mtexFig.cBarAxis = colorbar('peer',mtexFig.children(end),'eastoutside','units','pixel');
    return
    
  elseif equalScale % one new colorbar
      
    mtexFig.cBarAxis = addColorbar(mtexFig.children(end),varargin{:});
    
  else % many new colorbars
    
    for i = 1:numel(mtexFig.children)      
      mtexFig.cBarAxis(i) = addColorbar(mtexFig.children(i),varargin{:});
    end
    
  end
  
else % remove old colorbars
  delete(mtexFig.cBarAxis);
  mtexFig.cBarAxis = [];
end

mtexFig.drawNow(varargin{:});

  function h = addColorbar(peer,varargin)
    
    % if lower bound is close to zero - make it exactly zero
    c = get(peer,'CLim');
    if abs(c(1) / (c(2)-c(1)))<1e-3;
      set(peer,'CLim',[0,c(2)]);
    end
    
    fs = getMTEXpref('FontSize');  
    h = optiondraw(colorbar('peer',peer,'eastoutside','units','pixel',...
      'FontSize',fs),varargin{:});
    
    pos = get(h,'position');
    if pos(3)<pos(4)
      pos(3)=getMTEXpref('FontSize');
    else
      pos(4)=getMTEXpref('FontSize');
    end
    set(h,'position',pos);
  end  

  function eq = equalScale
    
    if numel(mtexFig.children) <= 1, eq = true; return; end
    cl = cell2mat(get(mtexFig.children,'CLim'));
    
    eq = all(cl(1,1)==cl(:,1) & cl(1,2)==cl(:,2));
    
  end

end
