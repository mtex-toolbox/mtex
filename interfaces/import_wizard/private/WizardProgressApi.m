function api = WizardProgressApi( api, firstPage )
%IMPORTGUIPROGRESS Summary of this function goes here
%   Detailed explanation goes here

state = {'off','on'};

gui = localCreateGUIControls();

% local progress api
progressApi.currentPage = firstPage;
progressApi.prevPage = {};
progressApi.leavePageCallback  = [];
progressApi.gotoPageCallback   = [];

% global available functions
api.Progress.enableNext   = @enableNext;
api.Progress.enablePrev   = @enablePrev;
api.Progress.enableFinish = @enableFinish;
api.Progress.enablePlot   = @enablePlot;

% some helper
api.initProgressApi       = @showPage;
% api.updateProgressApi     = @updateProgressApi;
api.setLeavePageCallback  = @setLeavePageCallback;
api.setGotoPageCallback   = @setGotoPageCallback;

api.nextCallback  = @localNextCallback;

% set callbacks
set(gui.hPlot   ,'CallBack',@localPlotDataCallback );
set(gui.hPrev   ,'Callback',@localPrevCallback   );
set(gui.hNext   ,'Callback',@localNextCallback   );
set(gui.hFinish ,'CallBack',@localFinishCallback   );

% initalize buttons
api.Progress.enableNext(false);
api.Progress.enablePrev(false);
api.Progress.enablePlot(false);
api.Progress.enableFinish(false);


  function showPage()
    
    api.clearPage();
    
    set(api.hPanel,'visible','off');
    
    progressApi.currentPage(api);
    try
      progressApi.gotoPageCallback();
    catch
    end
    set(api.hPanel,'visible','on');
    
  end

  function setLeavePageCallback(callback)
    
    progressApi.leavePageCallback = callback;
    
  end

  function setGotoPageCallback(callback)
    
    progressApi.gotoPageCallback = callback;
    
  end

  function localPrevCallback(varargin)
    
    if numel(progressApi.prevPage) > 0
      
      progressApi.currentPage = progressApi.prevPage{end};
      progressApi.prevPage(end) = [];
      
      enablePrev(numel(progressApi.prevPage)>0);
      
      showPage();
      
    end
    
  end

  function localNextCallback(varargin)
    
    nextPage = progressApi.leavePageCallback();
    
    if ~isempty(nextPage)
      
      progressApi.prevPage{end+1} = progressApi.currentPage;
      progressApi.currentPage = nextPage;
      
      enablePrev(numel(progressApi.prevPage)>0);
      
      showPage();
      
    end
    
  end

  function localPlotDataCallback(varargin)
    
    data = api.getDataTransformed();
    figure
    
    if isa(data,'EBSD') && strcmp('pageSS',char(progressApi.currentPage)) % && numel(data.indexedPhasesId) == 1
      
      counts = accumarray(data.phaseId,1);
      [~,maxPhaseId] = max(counts(2:end));
      ind = data.phaseId == (1+maxPhaseId);
      ori = data(ind).orientations;
      plot(data(ind),ori);
      set(gcf,'name',['IPF Z map of phase ' data.CSList{maxPhaseId+1}.mineral])
      
      figure
      h = ori.CS.basicHKL;
      plotPDF(ori,h(1:3),'contourf','antipodal');
      set(gcf,'name',['pole figures of phase ' data.CSList{maxPhaseId+1}.mineral])
      
    else
      
      plot(data,'silent');
    end
    
  end

  function localFinishCallback(varargin)
    
    e = WizardFinish(api);
    
    if ~e, close(api.hFigure); end
    
  end


  function gui = localCreateGUIControls()
    
    parent = api.hFigure;
    w    = api.Spacings.Width;
    m    = api.Spacings.Margin;
    
    bW   = api.Spacings.ButtonWidth;
    bH   = api.Spacings.ButtonHeight;
    pH   = api.Spacings.BottomHeight;
    fs   = api.Spacings.FontSize;
    
    
    pos = @(offset) [offset pH-bH-m bW bH];
    
    % navigation
    next =  uicontrol(...
      'Parent',parent,...
      'String','Next >>',...
      'FontSize',fs,...
      'Position',pos(w-2*bW-2*m));
    
    prev = uicontrol(...
      'Parent',parent,...
      'String','<< Previous',...
      'FontSize',fs,...
      'Position',pos(w-3*bW-2*m));
    
    finish = uicontrol(...
      'Parent',parent,...
      'String','Finish',...
      'Enable','off',...
      'FontSize',fs,...
      'Position',pos(w-bW-m));
    
    plot = uicontrol(...
      'Parent',parent,...
      'String','Plot',...
      'FontSize',fs,...
      'Position',pos(m),...
      'Visible','on');
    
    uipanel(...
      'BorderType','line',...
      'BorderWidth',1,...
      'units','pixel',...
      'parent',parent,...
      'FontSize',fs,...
      'HighlightColor',[0 0 0],...
      'Position',[m pH w-2*m 1]);
    
    gui.hNext    = next;
    gui.hPrev    = prev;
    gui.hFinish  = finish;
    gui.hPlot    = plot;
    
  end

  function enableNext(b)
    
    set(gui.hNext,'enable',state{1+b});
    
  end

  function enablePrev(b)
    
    set(gui.hPrev,'enable',state{1+b});
    
  end

  function enableFinish(b)
    
    set(gui.hFinish,'enable',state{1+b});
    
  end

  function enablePlot(b)
    
    set(gui.hPlot,'enable',state{1+b});
    
  end

end
