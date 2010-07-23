%XML_WRITE  Writes Matlab data structures to XML file
%
% DESCRIPTION
% xml_write( filename, tree) Converts Matlab data structure 'tree' containing
% cells, structs, numbers and strings to Document Object Model (DOM) node
% tree, then saves it to XML file 'filename' using Matlab's xmlwrite
% function. Optionally one can also use alternative version of xmlwrite
% function which directly calls JAVA functions for XML writing without
% MATLAB middleware. This function is provided as a patch to existing
% bugs in xmlwrite (in R2006b).
%
% xml_write(filename, tree, RootName, Pref) allows you to specify
% additional preferences about file format
%
% DOMnode = xml_write([], tree) same as above except that DOM node is
% not saved to the file but returned.
%
% INPUT
%   filename     file name
%   tree         Matlab structure tree to store in xml file.
%   RootName     String with XML tag name used for root (top level) node
%                Optionally it can be a string cell array storing: Name of
%                root node, document "Processing Instructions" data and
%                document "comment" string
%   Pref         Other preferences:
%     Pref.ItemName - default 'item' -  name of a special tag used to
%                     itemize cell or struct arrays
%     Pref.XmlEngine - let you choose the XML engine. Currently default is
%       'Xerces', which is using directly the apache xerces java file.
%       Other option is 'Matlab' which uses MATLAB's xmlwrite and its
%       XMLUtils java file. Both options create identical results except in
%       case of CDATA sections where xmlwrite fails.
%     Pref.CellItem - default 'true' - allow cell arrays to use 'item'
%       notation. See below.
%    Pref.RootOnly - default true - output variable 'tree' corresponds to
%       xml file root element, otherwise it correspond to the whole file.
%     Pref.StructItem - default 'true' - allow arrays of structs to use
%       'item' notation. For example "Pref.StructItem = true" gives:
%         <a>
%           <b>
%             <item> ... <\item>
%             <item> ... <\item>
%           <\b>
%         <\a>
%       while "Pref.StructItem = false" gives:
%         <a>
%           <b> ... <\b>
%           <b> ... <\b>
%         <\a>
%
%
% Several special xml node types can be created if special tags are used
% for field names of 'tree' nodes:
%  - node.CONTENT - stores data section of the node if other fields
%    (usually ATTRIBUTE are present. Usually data section is stored
%    directly in 'node'.
%  - node.ATTRIBUTE.name - stores node's attribute called 'name'.
%  - node.COMMENT - create comment child node from the string. For global
%    comments see "RootName" input variable.
%  - node.PROCESSING_INSTRUCTIONS - create "processing instruction" child
%    node from the string. For global "processing instructions" see
%    "RootName" input variable.
%  - node.CDATA_SECTION - stores node's CDATA section (string). Only works
%    if Pref.XmlEngine='Xerces'. For more info, see comments of F_xmlwrite.
%  - other special node types like: document fragment nodes, document type
%    nodes, entity nodes and notation nodes are not being handled by
%    'xml_write' at the moment.
%
% OUTPUT
%   DOMnode      Document Object Model (DOM) node tree in the format
%                required as input to xmlwrite. (optional)
%
% EXAMPLES:
%   MyTree=[];
%   MyTree.MyNumber = 13;
%   MyTree.MyString = 'Hello World';
%   xml_write('test.xml', MyTree);
%   type('test.xml')
%   %See also xml_tutorial.m
%
% See also
%   xml_read, xmlread, xmlwrite
%
% Written by Jarek Tuszynski, SAIC, jaroslaw.w.tuszynski_at_saic.com


%% =======================================================================
%  === struct2DOMnode Function ===========================================
%  =======================================================================
function [] = struct2DOMnode(xml, parent, s, TagName, Pref)
% struct2DOMnode is a recursive function that converts matlab's structs to
% DOM nodes.
% INPUTS:
%  xml - jave object that will store xml data structure
% %  parent - parent DOM Element
%  s - Matlab data structure to save
%  TagName - name to be used in xml tags describing 's'
%  Pref - preferenced


if nargin < 5
	Pref.ItemName  = 'item'; % name of a special tag used to itemize cell arrays
  Pref.StructItem = false;  % allow arrays of structs to use 'item' notation
  Pref.CellItem   = false;  % allow cell arrays to use 'item' notation
  Pref.XmlEngine  = 'Matlab';  % use matlab provided XMLUtils
  %DPref.XmlEngine  = 'Xerces';  % use Xerces xml generator directly
  Pref.PreserveSpace = false; % 
end

% perform some conversions
if (ischar(s) && min(size(s))>1) % if 2D array of characters
  s=cellstr(s);                  % than convert to cell array
end
% if (strcmp(TagName, 'CONTENT'))
%   while (iscell(s) && length(s)==1), s = s{1}; end % unwrap cell arrays of length 1
% end

TagName = varName2str(TagName);
ItemName = Pref.ItemName;
nItem = length(s);
% == node is a cell ==
if (iscell(s)) % if this is a cell or cell array
  if (~strcmp(TagName, 'CONTENT'))  % not a CONTENT node 
    if (~Pref.CellItem) % do not use 'item' notation use  <a>...<\a> <a>...<\a> instead
      for iItem=1:nItem   % save each cell separatly
        struct2DOMnode(xml, parent, s{iItem}, TagName, Pref); % recursive call
      end
    else % use 'item' notation  <a> <item> ... <\item> <\a>
      node = xml.createElement(TagName);  % create a single tag with TagName
      for iItem=1:nItem                   % save each cell separatly as children of the "node"
        struct2DOMnode(xml, node, s{iItem}, ItemName , Pref); % recursive call
      end
      parent.appendChild(node);           % attach node to the parent node
    end
  else % CONTENT node with cell array  -> then use 'item' notation
%     if (~Pref.CellItem) 
%       for iItem=1:nItem-1   % save each cell separatly
%         parentClone = parent.cloneNode(true);
%         struct2DOMnode(xml, parentClone, s{iItem}, TagName, Pref); % recursive call
%         gradParent.appendChild(parentClone);
%       end
%       struct2DOMnode(xml, parent, s{nItem}, TagName, Pref); % recursive call
%     else
      for iItem=1:nItem   % save each cell separatly
        struct2DOMnode(xml, parent, s{iItem}, ItemName, Pref); % recursive call
      end
%    end
  end
% == node is a struct ==  
elseif (isstruct(s))  % if struct than deal with each field separatly
  fields = fieldnames(s);
  % if array of structs with no attributes than use 'items' notation
  if (nItem>1 && Pref.StructItem && ~isfield(s,'ATTRIBUTE') )
    node = xml.createElement(TagName);
    for iItem=1:nItem
      struct2DOMnode(xml, node, s(iItem), ItemName, Pref ); % recursive call
    end
    parent.appendChild(node);
  else % otherwise save each struct separatelly
    for j=1:nItem
      node = xml.createElement(TagName);
      for i=1:length(fields)
        field = fields{i};
        x = s(j).(field);
        %if (isempty(x)), continue; end
        if (iscell(x) && (strcmp(field, 'COMMENT') || ...
            strcmp(field, 'CDATA_SECTION') || ...
            strcmp(field, 'PROCESSING_INSTRUCTION')))
          for k=1:length(x) % if nodes that should have strings have cellstrings
            struct2DOMnode(xml, node, x{k}, field, Pref ); % recursive call will modify 'node'
          end
        elseif (strcmp(field, 'ATTRIBUTE')) % set attributes of the node
          if (isempty(x)), continue; end
          if (~isstruct(x))
            warning('xml_io_tools:write:badAttribute', ...
              'Struct field named ATTRIBUTE encountered which was not a struct. Ignoring.');
            continue;
          end
          attName = fieldnames(x);       % get names of all the attributes
          for k=1:length(attName)        % attach them to the node
            att = xml.createAttribute(varName2str(attName(k)));
            att.setValue(var2str(x.(attName{k}),Pref.PreserveSpace));
            node.setAttributeNode(att);
          end
        else                             % set children of the node
          struct2DOMnode(xml, node, x, field, Pref ); % recursive call will modify 'node'
        end
      end  % end for i=1:nFields
      parent.appendChild(node);
    end  % end for j=1:nItem
  end
% == node is a leaf node ==  
else  % if not a struct and not a cell than it is a leaf node
  if (strcmp(TagName, 'CONTENT'))
    txt = xml.createTextNode(var2str(s, Pref.PreserveSpace)); % ... than it can be converted to text
    parent.appendChild(txt);
  elseif (strcmp(TagName, 'COMMENT'))   % create comment node
    if (ischar(s))
      com = xml.createComment(s);
      parent.appendChild(com);
    else
      warning('xml_io_tools:write:badComment', ...
        'Struct field named COMMENT encountered which was not a string. Ignoring.');
    end
  elseif (strcmp(TagName, 'CDATA_SECTION'))   % create CDATA Section
    if (ischar(s))
      cdt = xml.createCDATASection(s);
      parent.appendChild(cdt);
    else
      warning('xml_io_tools:write:badCData', ...
        'Struct field named CDATA_SECTION encountered which was not a string. Ignoring.');
    end
  elseif (strcmp(TagName, 'PROCESSING_INSTRUCTION')) % set attributes of the node
    OK = false;
    if (ischar(s))
      n = strfind(s, ' ');
      if (~isempty(n))
        proc = xml.createProcessingInstruction(s(1:(n(1)-1)),s((n(1)+1):end));
        parent.insertBefore(proc, parent.getFirstChild());
        OK = true;
      end
    end
    if (~OK)
      warning('xml_io_tools:write:badProcInst', ...
        ['Struct field named PROCESSING_INSTRUCTION need to be',...
        ' a string, for example: xml-stylesheet type="text/css" ', ...
        'href="myStyleSheet.css". Ignoring.']);
    end
  else % I guess it is a regular text leaf node
    txt  = xml.createTextNode(var2str(s, Pref.PreserveSpace));
    node = xml.createElement(TagName);
    node.appendChild(txt);
    parent.appendChild(node);
  end
end % of struct2DOMnode function
end
%% =======================================================================
%  === var2str Function ==================================================
%  =======================================================================
function str = var2str(s, PreserveSpace)
% convert matlab variables to a sting
if (isnumeric(s) || islogical(s))
  dim = size(s);
  if (min(dim)<1 || length(dim)>2) % if 1D or 3D array
    s=s(:); s=s.';            % convert to 1D array
    str=num2str(s);           % convert array of numbers to string
  else                        % if a 2D array
    s=mat2str(s);             % convert matrix to a string
    str=regexprep(s,';',';\n');
  end
elseif iscell(s)
  str = char(s{1});
  for i=2:length(s)
    str = [str, ' ', char(s{i})]; %#ok<AGROW>
  end
elseif isstruct(s)
  str='';
  warning('xml_io_tools:write:var2str', ...
          'Struct was encountered where string was expected. Ignoring.');
else
  str = char(s);
end
str=str(:); str=str.';            % make sure this is a row vector of char's
if (~isempty(str))
  str(str<32|str==127)=' ';       % convert no-printable characters to spaces
  if (~PreserveSpace)
    str = strtrim(str);             % remove spaces from begining and the end
    str = regexprep(str,'\s+',' '); % remove multiple spaces
  end
end
end
%% =======================================================================
%  === var2Namestr Function ==============================================
%  =======================================================================
function str = varName2str(str)
% convert matlab variable names to a sting
str = char(str);
p   = strfind(str,'0x');
if (~isempty(p))
  for i=1:length(p)
    before = str( p(i)+(0:3) );          % string to replace
    after  = char(hex2dec(before(3:4))); % string to replace with
    str = regexprep(str,before,after, 'once', 'ignorecase');
    p=p-3; % since 4 characters were replaced with one - compensate
  end
end
str = regexprep(str,'_COLON_',':', 'once', 'ignorecase');
str = regexprep(str,'_DASH_' ,'-', 'once', 'ignorecase');
str = regexprep(str,'_SPACE_' ,' ', 'once', 'ignorecase');


end