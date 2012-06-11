function mtable = createTable(pnContainer,headers,data,buttonsFlag,varargin)
% createTable - create nice-looking table based on javax.swing.JTable
%
% Syntax:
%    [mtable, buttons] = createTable (pnContainer, headers, data, buttonsFlag, 'PropName',PropValue, ...)
%
% Input Parameters:
%    pnContainer - optional handle to container uipanel or figure. If empty/unsupplied then current figure will be used
%    headers     - optional cell array of column header strings. If unsupplied then = {'A','B','C'}
%    data        - optional vector/matrix (either scalar or cell array) of data values
%    buttonsFlag - optional flag indicating whether to create the table-manipulation buttons. Default = true
%    'PropName',PropValue - 
%                  optional list of property pairs (e.g., 'AutoResizeMode',4,'Editable',false,'Position',[.1,.1,.5,.5])
%                  Note: PropName must be either an mtable property ('Visible','Editable','Position','Units',
%                        'DataChangedCallback',...) or otherwise a Javax.swing.JTable property ('ShowGrid','Name',...).
%                        Abbreviated PropNames are unsupported for mtable properties (which are few) - only for JTable
%
% Output parameters:
%    mtable      - handle to mtable object (a Matlab object)
%    buttons     - handles to table manipulation buttons: [<appendRow> <insertRow> <deleteRow> <deleteAll> <printAll>]
%
% Examples:
%    [mtable, buttons] = createTable;
%    [mtable, buttons] = createTable(gcf,'column name');
%    mtable = createTable([],{'a','b','c','d'},{false,1.3,uint16(45),'ert'; true,pi,uint16(-4),'defrgt'})
%    mtable = createTable([],{'a','b','c','d'},magic(4),false,'AutoResizeMode',javax.swing.JTable.AUTO_RESIZE_ALL_COLUMNS)
%    mtable = createTable([],{'rads','sin','cos'},[pi,sin(pi),cos(pi)],'SelectionMode',javax.swing.ListSelectionModel.SINGLE_INTERVAL_SELECTION)
%
% Usage:
%    The table automatically resizes to fill the pnContainer (you may modify this via the 'Position' property).
%    The table automatically sets the columns' cell editor and renderer based on the supplied data. Logical values are
%       given a checkbox, strings are left-aligned (numbers are right-aligned). You can always override the defaults.
%    You can change column widths by dragging the column borders on the header row.
%    You can sort columns by clicking the column header (once to sort descending, once again to sort ascending and once
%       more for the unsorted view). Sorting multiple columns is done by control-clicking all relevant columns (the
%       sorting icon is decreased in size for each additional minor sort col).
%    You can copy/paste any consecutive region of table cells, just as in Excel. You can select entire rows or columns
%       by right-clicking their header. You can also paste Excel data directly, with Ctrl-Shift-V (or use the context
%       menu by right-clicking) at the target table cell.
%    For additional tips about how to set multiple aspects of the table, refer to:
%       <a href="http://java.sun.com/docs/books/tutorial/uiswing/components/table.html">http://java.sun.com/docs/books/tutorial/uiswing/components/table.html</a>
%
% Programming tips/cues/examples:
%    mtable = creatTable(...)
%    jtable = mtable.getTable;
%    mtable.setVisible(false);
%    mtable.setCheckBoxEditor(1);  % Set first column to a checkbox (see Note 2 below)
%    cb = javax.swing.JComboBox({'First','Last'}); cb.setEditable(true);  % prepare an editable drop-down CellEditor
%    editor = javax.swing.DefaultCellEditor(cb);
%    jtable.getColumnModel.getColumn(1).setCellEditor(editor);  % assign this editor to second column (see Note 2)
%    jtable.getColumnModel.getColumn(0).setMaxWidth(20);  % Limit width of first (checkbox) column (see Note 2)
%    mtable.setEditable(0,false);  % Disable editing first column (see note 2 below)
%    renderer = javax.swing.table.DefaultTableCellRenderer;  % or: renderer = jtable.getColumnModel.getColumn(1).getCellRenderer
%    renderer.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);  % useful for numbers rendered as strings e.g.: jtable.setValueAt(sprintf('%.1f',pi,rowIdx,colIdx))
%    jtable.getColumnModel.getColumn(1).setCellRenderer(renderer);  % right-align second column (see note 2)
%    data = cell(mtable.getData);  % a cell matrix (mtable.getData is a java.lang.Object[][] object, using base-1 indexing)
%    data = mtable.getTableModel.getDataVector;  % a java.util.Vector object ([[false, 1.3, 45, ert], [true, 3.14,...]])
%    jtable.setValueAt(value,rowIdx,colIdx);  % 0-based Idx - see Note 2 below
%    jtable.getModel.addRow({true, pi, int16(45), 'test'});  % appends a row to the bottom of the table
%    mtable.DataChangedCallback = [];  % used to temporarily disable data-change callbacks
%    mtable.DataChangedCallback = @myDataChange_Callback;  % myDataChange_Callback is a Matlab function
%
%    % Sample dataChange_Callback function
%    function dataChange_Callback(mtable, eventdata)
%       if ~ishandle(mtable),  return;  end
%          % Prevent re-entry here if the callback is not thread-safe - see Note 3 below
%       eventDetails = eventdata.getEvent;
%       modifiedColIdx = eventDetails.getColumn;
%       modifiedRowIdx = eventDetails.getFirstRow;
%       if modifiedColIdx>=0 && modifiedRowIdx>=0
%          data = mtable.getData;
%          newValue = data(modifiedRowIdx+1,modifiedColIdx+1);  % see Note 2 below
%          switch modifiedColIdx
%            case ...
%          end
%       end
%
% Notes:
%    1. Some (very few) JTable features are inconsistent or unavailable in different jave versions. Type 
%       '<a href="matlab:version -java">version -java</a>' at the command prompt to see your specific java version.
%    2. Note that java uses 0-based indexing, while Matlab is 1-based. The returned mtable parameter is a Matlab object
%       (so use 1-base), while mtable.getXXX returns java objects (0-based). jtable above is an example of a java object.
%    3. Modifying mtable.DataChangedCallback within the callback doesn't work - you need to use some global flag/mutex
%    4. The <Print> button uses Excel to parse and print the table
%    5. Due to Matlab limitations (specifically, of uitable/UitablePeer) the table is created as a direct child of
%       the container figure (although it is visually positioned within pnContainer)
%    6. To enable sorting functionality, the attached TableSorter.jar file must be located in the java classpath.
%       See the Matlab documentation for <a href="matlab:doc javaclasspath">javaclasspath</a>. Note that using 
%       javaaddpath(...) to set the path has a nasty side-effect (at least since Matlab 7.2) of clearing all globals!
%       An alternative is to place the pathname for TableSorter.jar in the <a href="matlab:which classpath.txt">classpath.txt</a> file
%
% Known issues/limitations:
%    - Column alignment not preserved during Print
%    - Print fails if Excel unavailable (maybe directly print tab-separated text data)
%    - Unable to add/delete rows or to print via context menu (right-click)
%    - Table is created as a direct child of figure, not pnContainer (see Note 5 above)
%
% Bugs and suggestions:
%    Please send to Yair Altman (altmany at gmail dot com)
%
% See also:
%    uitable, java, javaclasspath
%
% Release history:
%    1.0 2007-03-09: initial version
%    1.1 2007-03-22: fixed selected row# on deletion of bottom row, main comment, missing option; added header tooltip

% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Yair M. Altman: altmany(at)gmail.com
% $Revision: 1.1 $  $Date: 2007/03/20 09:50:49 $

  %try
      % Ensure that java swing is enabled...
      if ~usejava('swing')
          error('createTable:NeedSwing','Java tables require Java Swing.');
      end

      % Create a panel spanning entire figure area, if panel handle was not supplied
      if (nargin < 1) || isempty(pnContainer) || ~ishandle(pnContainer)
          pnContainer = uipanel('parent',gcf,'tag','TablePanel');
      end
      pnContainerPos = getpixelposition(pnContainer,1);
      if isa(handle(pnContainer), 'figure')
          pnContainerPos(1:2) = 0;
      end

      % Get handle to parent figure
      hFig = ancestor(pnContainer,'figure');

      % Determine whether table manipulation buttons are requested
      if nargin < 4 || isempty(buttonsFlag) || ~(isnumeric(buttonsFlag) || islogical(buttonsFlag))
          if nargin >= 4,  varargin = {buttonsFlag, varargin{:}};  end
          buttonsFlag = true;
      end
      if buttonsFlag
          margins = [1,30,0,-30];  % With buttons
      else
          margins = [1,1,0,0];   % No buttons
      end

      % Get the uitable's required position within pnContainer
      tablePosition = pnContainerPos + margins;    % Relative to the figure

      % Set default header names, if not supplied
      if nargin < 2
          headers = {'A','B','C'};  % 3 columns by default
      elseif isempty(headers)
          headers = {' '};
      elseif ischar(headers)
          headers = {headers};
      end

      % Start with dummy data, just so that uitable can be initialized (or use supplied data, if available)
      if nargin < 3 || isempty(data)
          numRows = 0;
          numCols = length(headers);
          data = zeros(1,numCols);
      else
          numRows = size(data,1);
          numCols = size(data,2);
      end
      % Convert to cell-format (if not so already)
      if ~iscell(data)
          data = mat2cell(data,ones(1,size(data,1)),ones(1,numCols));
      end

      % Create a sortable uitable within pnHandle
      mtable = uitable(hFig, 'position',tablePosition, 'Data',data, 'ColumnNames',headers);
      mtable.setNumRows(numRows);
      set(mtable,'units','normalized');  % this will resize the table whenever its container is resized

      % jtable is the underlying java JTable - access to lots more functionality...
      % Note: actually, jtable is a com.mathworks.hg.peer.UitablePeer$PeerSpreadsheetTable object, but this extends
      % ^^^^  javax.swing.JTable, so for all practical purposes you may use it as a JTable
      jtable = mtable.getTable;

      % Fix for JTable focus bug : see http://bugs.sun.com/bugdatabase/view_bug.do;:WuuT?bug_id=4709394
      % Taken from: http://xtargets.com/snippets/posts/show/37
      jtable.putClientProperty('terminateEditOnFocusLost', java.lang.Boolean.TRUE);

      % Set the header tooltip (no sorting instructions...)
      jtable.getTableHeader.setToolTipText('<html>&nbsp;<b>Click</b> to select entire column<br>&nbsp;<b>Ctrl-click</b> (or <b>Shift-click</b>) to select multiple columns&nbsp;</html>');

      % Store the uitable's handle within the pnContainer's userdata, for later use
      set(pnContainer,'userdata',[get(pnContainer,'userdata'), mtable]);  % add to parent userdata, so we have a handle for deletion

      % Enable multiple row selection, auto-column resize, and auto-scrollbars
      scroll = mtable.TableScrollPane;
      scroll.setVerticalScrollBarPolicy(scroll.VERTICAL_SCROLLBAR_AS_NEEDED);
      scroll.setHorizontalScrollBarPolicy(scroll.HORIZONTAL_SCROLLBAR_AS_NEEDED);
      jtable.setSelectionMode(javax.swing.ListSelectionModel.MULTIPLE_INTERVAL_SELECTION);
%      jtable.setAutoResizeMode(jtable.AUTO_RESIZE_SUBSEQUENT_COLUMNS)

      % Set the jtable name based on the containing panel's tag
      basicTagName = get(pnContainer,'tag');
      jtable.setName([basicTagName 'Table']);

      % Move the selection to first table cell (if any data available)
      if (jtable.getRowCount > 0)
          jtable.changeSelection(0,0,false,false);
      end

      % Process optional args
      for argIdx = 1 : 2 : length(varargin)
          if argIdx<2
              % We need this pause to let java complete all table rendering
              % TODO: We should really use calls to awtinvoke() instead, though...
              pause(0.05);
          end
          if (length(varargin) > argIdx)   % ensure the arg value is there...
              varargin{argIdx}(1) = upper(varargin{argIdx}(1));  % property names always start with capital letters...
              propMethodName = ['set' varargin{argIdx}];
              if ismethod(mtable,propMethodName)
                  set(mtable,varargin{argIdx},varargin{argIdx+1});
              else
                  %javaMethod(propMethodName, jtable, varargin{argIdx+1});
                  set(jtable,varargin{argIdx},varargin{argIdx+1});
              end
          end
      end  % for argIdx

  %catch
      % Insert your code here
      %handleError;
  %end

