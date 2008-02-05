function statusbarHandles = statusbar(varargin)
%statusbar set/get the status-bar of Matlab desktop or a figure
%
%   statusbar sets the status-bar text of the Matlab desktop or a figure.
%   statusbar accepts arguments in the format accepted by the <a href="matlab:doc sprintf">sprintf</a>
%   function and returns the statusbar handle(s), if available.
%
%   Syntax:
%      statusbarHandle = statusbar(handle, text, sprintf_args...)
%
%   statusbar(text, sprintf_args...) sets the status bar text for the
%   current figure. If no figure is selected, then one will be created.
%   Note that figures with 'HandleVisibility' turned off will be skipped
%   (compare <a href="matlab:doc findobj">findobj</a> & <a href="matlab:doc findall">findall</a>).
%   In these cases, simply pass their figure handle as first argument.
%   text may be a single string argument, or anything accepted by sprintf.
%
%   statusbar(handle, ...) sets the status bar text of the figure
%   handle (or the figure which contains handle). If the status bar was
%   not yet displayed for this figure, it will be created and displayed.
%   If text is not supplied, then any existing status bar is erased,
%   unlike statusbar(handle, '') which just clears the text.
%
%   statusbar(0, ...) sets the Matlab desktop's status bar text. If text is
%   not supplied, then any existing text is erased, like statusbar(0, '').
%
%   statusbar([handles], ...) sets the status bar text of all the
%   requested handles.
%
%   statusbarHandle = statusbar(...) returns the status bar handle
%   for the selected figure. The Matlab desktop does not expose its
%   statusbar object, so statusbar(0, ...) always returns [].
%   If multiple unique figure handles were requested, then
%   statusbarHandle is an array of all non-empty status bar handles.
%
%   Notes:
%      1) The format statusbarHandle = statusbar(handle) does NOT erase
%         any existing statusbar, but just returns the handles.
%      2) The status bar is 20 pixels high across the entire bottom of
%         the figure. It hides everything between pixel heights 0-20,
%         even parts of uicontrols, regardless of who was created first!
%      3) Three internal handles are exposed to the user (Figures only):
%         - CornerGrip: a small square resizing grip on bottom-right corner
%         - TextPanel: main panel area, containing the status text
%         - ProgressBar: a progress bar within TextPanel (default: invisible)
%
%   Examples:
%      statusbar;  % delete status bar from current figure
%      statusbar(0, 'Desktop status: processing...');
%      statusbar([hFig1,hFig2], 'Please wait while processing...');
%      statusbar('Processing %d of %d (%.1f%%)...',idx,total,100*idx/total);
%      statusbar('Running... [%s%s]',repmat('*',1,fix(N*idx/total)),repmat('.',1,N-fix(N*idx/total)));
%      existingText = get(statusbar(myHandle),'Text');
%
%   Examples customizing the status-bar appearance:
%      sb = statusbar('text');
%      set(sb.CornerGrip, 'visible','off');
%      set(sb.TextPanel, 'Foreground',[1,0,0], 'Background','cyan', 'ToolTipText','tool tip...')
%      set(sb, 'Background',java.awt.Color.cyan);
%
%      % sb.ProgressBar is by default invisible, determinite, non-continuous fill, min=0, max=100, initial value=0
%      set(sb.ProgressBar, 'Visible','on', 'Minimum',0, 'Maximum',500, 'Value',234);
%      set(sb.ProgressBar, 'Visible','on', 'Indeterminate','off'); % indeterminate (annimated)
%      set(sb.ProgressBar, 'Visible','on', 'StringPainted','on');  % continuous fill
%      set(sb.ProgressBar, 'Visible','on', 'StringPainted','on', 'string',''); % continuous fill, no percentage text
%
%      % Adding a checkbox
%      jCheckBox = javax.swing.JCheckBox('cb label');
%      sb.add(jCheckBox,'West');  % Beware: East also works but doesn't resize automatically
%
%   Notes:
%     Statusbar will probably NOT work on Matlab versions earlier than 6.0 (R12)
%     In Matlab 6.0 (R12), figure statusbars are not supported (only desktop statusbar)
%
%   Warning:
%     This code heavily relies on undocumented and unsupported Matlab
%     functionality. It works on Matlab 7+, but use at your own risk!
%
%   Bugs and suggestions:
%     Please send to Yair Altman (altmany at gmail dot com)
%
%   Change log:
%     2007-May-04: Added partial support for Matlab 6
%     2007-Apr-29: Added internal ProgressBar; clarified main comment
%     2007-Apr-25: First version posted on MathWorks file exchange: <a href="http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=14773">http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=14773</a>
%
%   See also:
%     ishghandle, sprintf, findjobj (on the <a href="http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=14317">file exchange</a>)

% License to use and modify this code is granted freely without warranty to all, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Yair M. Altman: altmany(at)gmail.com
% $Revision: 1.0 $  $Date: 2007/04/25 16:43:24 $

    % Check for available Java/AWT (not sure if Swing is really needed so let's just check AWT)
    if ~usejava('awt')
        error('YMA:statusbar:noJava','statusbar only works on Matlab envs that run on java');
    end

    % Args check
    if nargin < 1 | ischar(varargin{1})  %#ok for Matlab 6 compatibility
        handles = gcf;  % note: this skips over figures with 'HandleVisibility'='off'
    else
        handles = varargin{1};
        varargin(1) = [];
    end

    % Ensure that all supplied handles are valid HG GUI handles (Note: 0 is a valid HG handle)
    if isempty(handles) | ~all(ishandle(handles))  %#ok for Matlab 6 compatibility
        error('YMA:statusbar:invalidHandle','invalid GUI handle passed to statusbar');
    end

    % Retrieve the requested text string (only process once, for all handles)
    if isempty(varargin)
        deleteFlag = (nargout==0);
        updateFlag = 0;
        statusText = '';
    else
        deleteFlag = 0;
        updateFlag = 1;
        statusText = sprintf(varargin{:});
    end

    % Loop over all unique root handles (figures/desktop) of the supplied handles
    rootHandles = [];
    if any(handles)  % non-0, i.e. non-desktop
        try
            rootHandles = ancestor(handles,'figure');
            if iscell(rootHandles),  rootHandles = cell2mat(rootHandles);  end
        catch
            errMsg = 'Matlab version is too old to support figure statusbars';
            % Note: old Matlab version didn't have the ID optional arg in warning/error, so I can't use it here
            if any(handles==0)
                warning([errMsg, '. Updating the desktop statusbar only.']);  %#ok for Matlab 6 compatibility
            else
                error(errMsg);
            end
        end
    end
    rootHandles = unique(rootHandles);
    if any(handles==0), rootHandles(end+1)=0; end
    statusbarObjs = handle([]);
    for rootIdx = 1 : length(rootHandles)
        if rootHandles(rootIdx) == 0
            setDesktopStatus(statusText);
        else
            thisStatusbarObj = setFigureStatus(rootHandles(rootIdx), deleteFlag, updateFlag, statusText);
            if ~isempty(thisStatusbarObj)
                statusbarObjs(end+1) = thisStatusbarObj;
            end
        end
    end

    % If statusbarHandles requested
    if nargout
        % Return the list of all valid (non-empty) statusbarHandles
        statusbarHandles = statusbarObjs;
    end

%end  % statusbar  %#ok for Matlab 6 compatibility

%% Set the status bar text of the Matlab desktop
function setDesktopStatus(statusText)
    try
        % First, get the desktop reference
        try
            desktop = com.mathworks.mde.desk.MLDesktop.getInstance;      % Matlab 7+
        catch
            desktop = com.mathworks.ide.desktop.MLDesktop.getMLDesktop;  % Matlab 6
        end

        % Schedule a timer to update the status text
        % Note: can't update immediately, since it will be overridden by Matlab's 'busy' message...
        try
            t = timer('Name','statusbarTimer', 'TimerFcn',{@setText,desktop,statusText}, 'StartDelay',0.05, 'ExecutionMode','singleShot');
            start(t);
        catch
            % Probably an old Matlab version that still doesn't have timer
            desktop.setStatusText(statusText);
        end
    catch
        %if any(ishandle(hFig)),  delete(hFig);  end
        error('YMA:statusbar:desktopError',['error updating desktop status text: ' lasterr]);
    end
%end  %#ok for Matlab 6 compatibility

%% Utility function used as setDesktopStatus's internal timer's callback
function setText(varargin)
    if nargin == 4  % just in case...
        targetObj  = varargin{3};
        statusText = varargin{4};
        targetObj.setStatusText(statusText);
    else
        % should never happen...
    end
%end  %#ok for Matlab 6 compatibility

%% Set the status bar text for a figure
function statusbarObj = setFigureStatus(hFig, deleteFlag, updateFlag, statusText)
    try
        jFrame = get(hFig,'JavaFrame');
        jFigPanel = get(jFrame,'FigurePanelContainer');
        jRootPane = jFigPanel.getComponent(0).getRootPane;

        % If invalid RootPane, retry up to N times
        tries = 10;
        while isempty(jRootPane) & tries>0  %#ok for Matlab 6 compatibility - might happen if figure is still undergoing rendering...
            drawnow; pause(0.001);
            tries = tries - 1;
            jRootPane = jFigPanel.getComponent(0).getRootPane;
        end
        jRootPane = jRootPane.getTopLevelAncestor;

        % Get the existing statusbarObj
        statusbarObj = jRootPane.getStatusBar;

        % If status-bar deletion was requested
        if deleteFlag
            % Non-empty statusbarObj - delete it
            if ~isempty(statusbarObj)
                jRootPane.setStatusBarVisible(0);
            end
        elseif updateFlag  % status-bar update was requested
            % If no statusbarObj yet, create it
            if isempty(statusbarObj)
               statusbarObj = com.mathworks.mwswing.MJStatusBar;
               jProgressBar = javax.swing.JProgressBar;
               set(jProgressBar, 'Visible','off');
               statusbarObj.add(jProgressBar,'West');  % Beware: East also works but doesn't resize automatically
               jRootPane.setStatusBar(statusbarObj);
            end
            statusbarObj.setText(statusText);
            jRootPane.setStatusBarVisible(1);
        end
        statusbarObj = handle(statusbarObj);

        % Add quick references to the corner grip and status-bar panel area
        if ~isempty(statusbarObj)
            addOrUpdateProp(statusbarObj,'CornerGrip',  statusbarObj.getParent.getComponent(0));
            addOrUpdateProp(statusbarObj,'TextPanel',   statusbarObj.getComponent(0));
            addOrUpdateProp(statusbarObj,'ProgressBar', statusbarObj.getComponent(1).getComponent(0));
        end
    catch
        try
            title = jFrame.fFigureClient.getWindow.getTitle;
        catch
            title = get(hFig,'Name');
        end
        error('YMA:statusbar:figureError',['error updating status text for figure ' title ': ' lasterr]);
    end
%end  %#ok for Matlab 6 compatibility

%% Utility function: add a new property to a handle and update its value
function addOrUpdateProp(handle,propName,propValue)
    try
        if ~isprop(handle,propName)
            schema.prop(handle,propName,'mxArray');
        end
        set(handle,propName,propValue);
    catch
        % never mind...
        lasterr
    end
%end  %#ok for Matlab 6 compatibility