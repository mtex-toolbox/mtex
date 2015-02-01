function h = colorbar(mtexFig,varargin)

if isempty(mtexFig.cBarAxis) % create some new colorbars
    
  if ~mtexFig.keepAspectRatio || equalScale % one new colorbar
  
    mtexFig.cBarAxis = addColorbar(mtexFig.children(end),varargin{:});
            
  else % many new colorbars
    
    for i = 1:numel(mtexFig.children)      
      mtexFig.cBarAxis(i) = addColorbar(mtexFig.children(i),varargin{:});
    end
    
  end
  
  % adjust width of the colorbars
  pos = ensurecell(get(mtexFig.cBarAxis,'position'));
  for i = 1:numel(pos)
    if pos{i}(3)<pos{i}(4)
      pos{i}(3)=getMTEXpref('FontSize');
    else
      pos{i}(4)=getMTEXpref('FontSize');
    end
    set(mtexFig.cBarAxis(i),'position',pos{i});
  end
  
else % remove old colorbars
  delete(mtexFig.cBarAxis);
  mtexFig.cBarAxis = [];
end

mtexFig.drawNow('keepAxisSize',varargin{:});

if nargout == 1, h = mtexFig.cBarAxis; end

  function h = addColorbar(peer,varargin)
    
    % if lower bound is close to zero - make it exactly zero
    c = get(peer,'CLim');
    if abs(c(1) / (c(2)-c(1)))<1e-3;
      set(peer,'CLim',[0,c(2)]);
    end
    
    fs = getMTEXpref('FontSize');  
    h = optiondraw(buildinColorbar('peer',peer,'eastoutside','units','pixel',...
      'FontSize',fs),varargin{:});
        
  end  

  function eq = equalScale
    
    if numel(mtexFig.children) <= 1, eq = true; return; end
    cl = cell2mat(get(mtexFig.children,'CLim'));
    
    eq = all(cl(1,1)==cl(:,1) & cl(1,2)==cl(:,2));
    
  end

end
