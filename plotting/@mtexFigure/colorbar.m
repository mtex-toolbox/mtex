function h = colorbar(mtexFig,varargin)

if isempty(mtexFig.cBarAxis) % create some new colorbars
    
  if (~mtexFig.keepAspectRatio || equalScale) ...
      && ~check_option(varargin,'multiple') % one new colorbar
  
    mtexFig.cBarAxis = addColorbar(mtexFig.children(end),varargin{:});
    
  else % many new colorbars
    
    mtexFig.cBarAxis = gobjects(numel(mtexFig.children),1);
    for i = 1:numel(mtexFig.children)      
      mtexFig.cBarAxis(i) = addColorbar(mtexFig.children(i),varargin{:});
    end
    
  end  
  
  % adjust width of the colorbars
  pos = {mtexFig.cBarAxis.Position};
  for i = 1:numel(pos)
    if pos{i}(3)<pos{i}(4)
      pos{i}(3) = getMTEXpref('FontSize');
    else
      pos{i}(4) = getMTEXpref('FontSize');
    end    
  end
  [mtexFig.cBarAxis.Position] = deal(pos{:});
  
  if check_option(varargin,'title')
    cBarTitle = ensurecell(get_option(varargin,'title'));
    label = [mtexFig.cBarAxis.Label];
    [label.String] = deal(cBarTitle{:});
  end
  
else % remove old colorbars
  delete(mtexFig.cBarAxis);
  mtexFig.cBarAxis = [];
end

mtexFig.drawNow('keepAxisSize',varargin{:});

if nargout == 1, h = mtexFig.cBarAxis; end

  function h = addColorbar(peer,varargin)
    
    % if lower bound is close to zero - make it exactly zero
    if peer.ColorScale == "linear" && ...
        abs(peer.CLim(1) / diff(peer.CLim)) < 1e-3
      peer.CLim(1) = 0;
    end

    fs = getMTEXpref('FontSize');
    location = ['eastoutside',extract_option(varargin,{'eastoutside','southoutside',...
      'northoutside','westoutside'})];
    h = optiondraw(colorbar('peer',peer,location{end},'units','pixel',...
      'FontSize',fs),varargin{:});
    
    if check_option(varargin,'title')
      h.Label.String = get_option(varargin,'title');
    end
        
  end  

  function eq = equalScale
    
    if numel(mtexFig.children) <= 1, eq = true; return; end
    cl = cell2mat(get(mtexFig.children,'CLim'));
    
    eq = all(cl(1,1)==cl(:,1) & cl(1,2)==cl(:,2));
    
  end

end
