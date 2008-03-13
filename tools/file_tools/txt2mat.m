function [A,ffn,num_header,sr_input_ca,hl,fpos] = txt2mat(varargin) %#ok<FNDEF>

% TXT2MAT read an ascii file and convert a data table to matrix
%
% Syntax:
%  A = txt2mat
%  A = txt2mat(fn)
%  [A,ffn,nh,SR,hl,fpos] = txt2mat(fn,nh,nc,cstr,SR,SX)
%  [A,ffn,nh,SR,hl,fpos] = txt2mat(fn,... 'PropertyName',propertyvalue,...)
%
% with
%
% A     output data matrix
% ffn   full file name
% nh    number of header lines
% hl    header lines (as a string)
% fpos  file position of last character read and converted from ascii file
%
% fn    file or path name
% nh    number of header lines
% nc    number of data columns
% cstr  conversion string
% SR    cell array of replacement strings  sr<i>, SR = {sr1,sr2,...}
% SX    cell array of invalid line strings sx<i>, SX = {sx1,sx2,...}
%
% All input arguments are optional. See below for
% PropertyName/PropertyValue-pairs.
%
% TXT2MAT reads the ascii file <fn> and extracts the values found in a 
% data table with <nc> colums to a matrix, skipping <nh> header lines. When
% extracting the data, <cstr> is used as conversion type specifier for each
% line (see sscanf online doc for conversion specifiers). 
%
% If <fn> points to an existing directory rather than a file or is an
% empty string, a file selection dialogue is displayed.
%
% Additional strings <sr1>,<sr2>,.. can be supplied within a cell array
% <SR> to perform single character substitution before the data is
% converted: each of the first n-1 characters of an <n> character string is
% replaced by the <n>-th character.  
% A further optional input argument is a cell array <SX> containing strings
% <sx1>,<sx2>,.. that mark lines containing invalid data. If every line
% containing invalid data can be caught by the <SX>, TXT2MAT will speed up
% significantly (see EXAMPLE 3). Any lines that are recognized to be
% invalid are completely ignored (and there is no corresponding row in A).
%
% If the number of header lines or the number of data columns are not
% provided, TXT2MAT performs some automatic analysis of the file format.
% This will need the numbers to be decimals (with decimal point or comma)
% and the data arrangement to be more or less regular (see also remark 1). 
%
% If some lines of the data table can not be (fully) converted, the
% corresponding rows in A are padded with NaNs. 
%
% For further options and to facilitate the argument assignment, the
% PropertyName/PropertyValue-notation can be used instead of the old syntax
% txt2mat(ffn,nh,nc,cstr,SR,SX)
% The following table lists the PN/PV-pairs and their corresponding input
% arguments, if existing:
%
%   Property         Value      Arg.   Example
%  'NumHeaderLines', Scalar     nh     13
%  'NumColumns',     Scalar     nc     9
%  'ConvString',     String     cstr   ['%i.%i.%i' repmat('%f',1,6)]
%  'ReplaceChar',    Cell       SR     {')Rx ',';: '}
%  'BadLineString'   Cell       SX     {'Warng', 'Bad'}
%  'ReplaceExpr',    Cell       -      {{'True','1'},{'#NaN','#Inf','NaN'}}
%  'DialogString',   String     -      'Now choose a log file'
%  'MemPar',         2x1-Vector -      [2e7, 2e5]
%  'InfoLevel',      Scalar     -      1
%  'ReadMode',       String     -      'auto'
%  'NumericType',    String     -      'single'
%  'RowRange',       2x1-Vector -      [2501 5000]
%  'FilePos',        Scalar     -      0
%
% The PN/PV-pairs may follow the usual arguments in any order, e.g.
% txt2mat('file.txt',13,9,'BadLineString',{'Bad'},'ConvString','%f'), only
% a file name argument must be given as the first input.
%
% PN/PV-pairs with additional functionality:
%
% � The 'ReplaceExpr' argument works similar to the 'ReplaceChar' argument.
%   It just replaces whole expressions instead of single characters. A cell
%   array containing at least one cell array of strings must be provided.
%   Such a cell array of strings consists of <n> strings, each of the first
%   <n-1> strings is replaced by the <n>-th string. 
%   If possible, supply 'ReplaceChar' rather than 'ReplaceExpr' as it is
%   less time consuming.
%   Expression replacements are performed before character replacements.
%
% � The 'DialogString' argument provides the text shown in the title bar of
%   the file selection dialogue that appears if necessary.
%
% � The 'MemPar' argument provides the amount of characters and lines
%   TXT2MAT will try to process simultaneously. [2e7, 2e5] are the default
%   values; you may try to lower them if you encouter memory problems.
%   These settings do not influence the output of TXT2MAT.
%
% � The 'InfoLevel' argument controls the verbosity of TXT2MAT's outputs in
%   the command window and the message boxes. Currently known values are: 
%   0, 1, 2 (default)
%
% � 'ReadMode' is one of 'matrix', 'line', or 'auto' (default). 
%   'matrix': Read and convert a block of multiple lines simultaneously, 
%             requiring each line containing the same number of values.
%             Finding an improper number of values in such a block will
%             cause an error (see also remark 2).
%   'line':   Read and convert text line by line, allowing different
%             numbers of values per line (much slower than in 'matrix'
%             mode).
%   'auto':   Try 'matrix' first, continue with 'line' if an error occurs.
%
% � 'NumericType' is one of 'int8', 'int16', 'int32', 'int64', 'uint8',
%   'uint16', 'uint32', 'uint64', 'single', or 'double' (default),
%   determining the numeric class of the output matrix A. Reduce memory
%   consumption by choosing an appropriate numeric class, if needed.
% 
% � The 'RowRange' value is a sorted positive integer two element vector
%   defining an interval of data rows to be converted (header lines do not
%   count, but lines that will be recognized as invalid - see above - do). 
%   If the vector's second element exceeds the number of valid data rows in
%   the file, the data is extraced up to the end of the file (Inf is
%   allowed as second argument). It may save memory and computation time if
%   only a small part of data has to be extracted from a huge text file. 
% 
% � The 'FilePos' value <fp> is a nonnegative integer scalar. <fp>
%   characters from the beginning of the file will be ignored, i.e. not be
%   read. If you run TXT2MAT with a 'RowRange' argument, you may
%   use the <fpos> output as an 'FilePos' input during the next run in
%   order to continue from where you stopped. By that you can split up the
%   conversion process e.g. when the file is too big to be read as a whole
%   (see EXAMPLE 5). 
% 
% -------------------------------------------------------------------------
%
% REMARKS
%
% 1) prerequisites for the automatic file format analysis (if the number of
% header lines and data columns is not given):
%    � header lines can be detected by either non-numeric characters or
%      a strongly deviating number of numeric items in relation to the
%      data section
%    � the data section must contain decimal numbers only (with decimal 
%      point OR comma)
%    � tab, space, comma, colon, and semicolon are accepted as delimiters
% 
% 2) In matrix mode, txt2mat checks that the conversion string is suitable
%    and that the number of values read from a section of the file is a
%    multiple of the number of columns. Though not likely, this may be true
%    even if the number of values per line is not uniform and txt2mat may
%    be misled. So using matrix mode you should be sure that all lines that
%    can't be sorted out by a bad line marker string contain the same
%    number of values.
%
% -------------------------------------------------------------------------
%
% EXAMPLE 1:
%
% A = txt2mat;      % choose a file and let TXT2MAT analyse its format
%                 
% -------------------------------------------------------------------------
%
% EXAMPLE 2:
%
% Supposed your ascii file C:\mydata.log begins with the following lines: 
%
% 680069	1024	1	186	237	87	4	170	154	233
% 680074	1040	6	123	59	226	0	162	0	233
% 680075	1056	3	48	170	144	3	89	186	234
% 680076	1072	3	44	77	116	0	182	149	234
%
% type
% A = txt2mat('C:\mydata.log',0,10,'%d');
% or just
% A = txt2mat('C:\mydata.log');
%
% -------------------------------------------------------------------------
%
% EXAMPLE 3:
%
% Supposed your ascii file C:\mydata.log begins with the following lines:
% 
% ;$FILEVERSION=1.1
% ;$STARTTIME=38546.6741619815
% ;---+--   ----+----  --+--  ----+---  +  -+ -- -- -- 
%      3)         7,2  Rx         0300  8  01 A3 58 4D 
%      4)         7,3  Rx         0310  8  06 6E 2B 9F 
%      5)         9,5  Warng  FFFFFFFF  4  00 00 00 08  BUSHEAVY 
%      6)        12,9  Rx         0320  8  02 E1 F6 EF 
% 
% you may specify 
% nh   = 3          % header lines, 
% nc   = 12         % data columns,
% cstr = '%f %f %x %x %x %x %x %x'  % as conversion string for floats and
%                                   % hexadecimals,  
% sr1  = ')Rx '     % as first replacement string to blank the characters
%                     ')','R', and 'x' (if you don't want to include them
%                     in the conversion string), and
% sr2  = ',.'       % to replace the decimal comma with a dot, and
% 
% sx1  = 'Warng'    % as a marker for invalid lines
%
% A = txt2mat('C:\mydata.log', nh, nc, cstr, {sr1,sr2}, {'Warng'});
%
%   A =
% 		3    7.2    768      8      1    163     88     77
% 		4    7.3    784      8      6    110     43    159
% 		6   12.9    800      8      2    225    246    239
% 		...
%
% Without the {'Warng'} argument, A would have been
%
% 		3    7.2    768      8      1    163     88     77
% 		4    7.3    784      8      6    110     43    159
% 		5    9.5    NaN    NaN    NaN    NaN    NaN    NaN
% 		6   12.9    800      8      2    225    246    239
% 		...
%
% -------------------------------------------------------------------------
%
% EXAMPLE 4:
%
% Supposed your ascii file C:\mydata.log begins with the following lines:
%
% datetime	%	ppm	%	ppm	Nm
% datetime	real8	real8	real8	
% 30.10.2006 14:24:06,131	6.4459	478.519	6.5343	
% 30.10.2006 14:24:17,400	6.4093	484.959	6.5343	
% 30.10.2006 14:24:17,499	6.4093	484.959	6.5343	
%
% 
% you'll specify 
% nh   = 2          % header lines, 
% nc   = 9          % data columns,
% cstr = ['%i.%i.%i' repmat('%f',1,6)] % as conversion string for
%                                      % integers and hexadecimals,  
% sr1  = ': '       % as first replacement string to blank the ':'
% sr2  = ',.'       % to replace the decimal comma with a dot, and
%
% A = txt2mat('C:\mydata.log',nh,nc, cstr, {sr1,sr2});
%
%   A =
% 		30   10 2006   14   24    6.131  6.4459   478.519   6.5343
% 		30   10 2006   14   24   17.4    6.4093   484.959   6.5343
% 		30   10 2006   14   24   17.499  6.4093   484.959   6.5343
%       ...
%
% -------------------------------------------------------------------------
%
% EXAMPLE 5:
% 
% If you want to process the contents of mydata.log step by step,
% converting one million lines at a time:
%
% fp  = 0;          % File position to start with (beginning of file)
% A   = NaN;        % initialize output matrix
% nhl = 12;         % number of header lines for the first call
% 
% while numel(A)>0
%     [A,ffn,nh,SR,hl,fp] = txt2mat('C:\mydata.log','RowRange',[1,1e6], ...
%                                   'FilePos',fp,'NumHeaderLines',nhl);
%     nhl = 0;      % there are no further header lines
%
%     % process intermediate results...
% end
% 
% -------------------------------------------------------------------------
%
%   See also SSCANF


% --- Author: -------------------------------------------------------------
%   Copyright 2005 A.T�nnesmann
%   $Revision: 5.61 $  $Date: 2008/02/08 13:50:05 $
% --- E-Mail: -------------------------------------------------------------
% x=-2:3;
% disp(char(round([-0.32*x.^5+0.43*x.^4+1.75*x.^3-5.90*x.^2-0.95*x+116,...
%                  -4.44*x.^5+9.12*x.^4+29.8*x.^3-33.6*x.^2-52.9*x+ 98])))
% --- History -------------------------------------------------------------
% 05.61
%   � fixed bug: possible wrong headerlines output when using 'FilePos'
%   � fixed bug: produced an error if a bad line marker string was already
%     found in the first data line 
%   � corrected user information if sscanf fails in matrix mode
%   � added some more help lines
% --- Wish list -----------------------------------------------------------
% � add regexprep input argument?


%% Definitions
%tauint  = uint8( 9);   % Tab
spuint   = uint8(32);   % Space
lfuint   = uint8(10);   % LineFeed
cruint   = uint8(13);   % CarriageReturn

%% Check input argument occurence (Property/Value-pairs)
%  1 'NumHeaderLines',     Scalar,     13
%  2 'NumColumns',         Scalar,     100
%  3 'ConvString',         String,     ['%i.%i.%i' repmat('%f',1,6)]
%  4 'ReplaceChar',        CellAString {')Rx ',';: '}
%  5 'BadLineString'       CellAString {'Warng', 'Bad'}
%  6 'ReplaceExpr',        CellAString {{'True','1'},{'False','0'},{'#Inf','Inf'}}
%  7 'DialogString'        String      'Now choose a Labview-Logfile'
%  8 'MemPar'              2x1-Vector  [2e7, 2e5]
%  9 'InfoLevel'           Scalar      2
% 10 'ReadMode'            String      'Auto'
% 11 'NumericType'         String      'single'
% 12 'RowRange'            2x1-Vector  [1,Inf]
% 13 'FilePos'             Scalar      1e5

v = ver('matlab');
vn= str2double(v.Version);

allargin = varargin;

propnames   = {'NumHeaderLines','NumColumns','ConvString','ReplaceChar',...
               'BadLineString','ReplaceExpr','DialogString','MemPar',...
               'InfoLevel','ReadMode','NumericType','RowRange','FilePos'};
len_pn      = length(propnames);
proppos     = zeros(size(propnames));   % argument-no. Property-String
valpos      = zeros(size(propnames));   % argument-no. Value

% compare the possible property strings to all arguments and save what
% can be found at which argument number to <proppos> and <valpos>
for adx = 2:length(allargin) %nargin    % look at all args but the first
    if ischar(allargin{adx})            % if it is a string...
        for pdx = 1:len_pn
            if isequal(lower(propnames{pdx}),lower(allargin{adx}))
                if proppos(pdx) ~= 0
                   error(['Multiple occurence of ' propnames{pdx} ' argument.']) 
                end
                proppos(pdx) = adx;
                valpos(pdx)  = adx+1;
            end
        end
    end
end

% add argument numbers that have no property string, i.e. that occur
% before the first property string
firstproppos = min(proppos(proppos>0));
if isempty(firstproppos)
    for pdx = 2:length(allargin)
        valpos(pdx-1) = pdx;
    end % for
else
    for pdx = 2:firstproppos-1
        if proppos(pdx-1) ~= 0
            error(['Multiple occurence of ' propnames{pdx-1} ' argument.']) 
        end
        valpos(pdx-1) = pdx;
    end
end


%% Check arguments (by content)
% todo: complete type checking
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
is_argin_num_header= false; % Init., is an argument for the number of header lines given?
if valpos(1) ~= 0
    num_header  = varargin{valpos(1)};
    if ~isempty(num_header)
        is_argin_num_header = true;
    end
else
    num_header = [];
end
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
is_argin_num_colon = false; % Init., is an argument for the number of data columns lines given?
if valpos(2) ~= 0
    num_colon   = varargin{valpos(2)};
    if ~isempty(num_colon)
        is_argin_num_colon = true;
    end
else
    num_colon = [];
end
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%is_argin_conv_str  = false; % Init., conversion string argument given?
if valpos(3) ~= 0
    conv_str    = varargin{valpos(3)};
    if isempty(conv_str)
        conv_str = '%f';
    %else
    %    is_argin_conv_str = true;
    end
else
    %conv_str = {};
    conv_str = '%f';    % standard, as always returned by anatxt
end
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Check for character replacement argument. For compatibility reasons,
% multiple strings as separate arguments are still supported.
has_sr_input_only = false;
sr_input_ca = {};
if valpos(4) ~= 0
    if iscellstr(varargin{valpos(4)})
        sr_input_ca = varargin{valpos(4)};
    elseif ischar(varargin{valpos(4)});
        sr_input_ca = {varargin{valpos(4):end}};
        disp([mfilename ': for future versions, please use a single cell array of strings as an input argument for multiple replacement strings.'])
        has_sr_input_only = true;
    else
        error('replacement string argument must be of type string or cell array of strings')
    end
    num_sr      = length(sr_input_ca);
else
    num_sr      = 0;
end
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if valpos(5) ~= 0 && ~has_sr_input_only     % bad line strings
    if iscellstr(varargin{valpos(5)})
        kl_input_ca = varargin{valpos(5)};      
    elseif ischar(varargin{valpos(5)});
        kl_input_ca = {varargin{valpos(5)}};
        disp([mfilename ': for future versions, please use a single cell array of strings as an input argument for bad line marker strings.'])
    else
        error('bad line marker argument must be of type string or cell array of strings')
    end
    num_kl      = length(kl_input_ca);
else
    num_kl      = 0;
end
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if valpos(6) ~= 0   % 'ReplaceExpression'
    replace_expr = varargin{valpos(6)};
    num_er       = length(replace_expr);
else
    num_er       = 0;
end
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if valpos(7) ~= 0           % 'DialogString'
    dialog_string = varargin{valpos(7)};
else
    dialog_string = 'Choose a data file';
end
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if valpos(8) ~= 0           % 'MemPar'
    mem_par  = varargin{valpos(8)};
    idx_rng  = mem_par(1);
    ldx_rng  = mem_par(2);
else
    idx_rng  = 2E7; % idx_rng  = 2E7; % number of characters to be processed simultaneously (memory-dependent!)
    ldx_rng  = 2E5; % ldx_rng  = 2E5; % number of rows to be processed simultaneously (memory-dependent!)
end
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if valpos(9) ~= 0           % 'InfoLevel'
    infolvl  = varargin{valpos(9)};
else
    infolvl  = 2;
end
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
is_argin_readmode = false;  % 'ReadMode'
if valpos(10) ~= 0   
    readmode = varargin{valpos(10)};
    is_argin_readmode = true;
else
    readmode = 'auto';
end
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if valpos(11) ~= 0          % 'NumericType'
    numerictype = varargin{valpos(11)};
else
    numerictype = 'double';
end
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
is_argin_rowrange = false;	% 'RowRange'
if valpos(12) ~= 0  
    rowrange = varargin{valpos(12)};
    if ~(numel(rowrange)==2) || ~issorted(rowrange) || rowrange(1)<1 || ...
        (rem(rowrange(1),1)~=0) || ( (rem(rowrange(2),1)~=0) && (rowrange(2)~=Inf) )
        error('RowRange argument must be a sorted positive integer 2x1 vector.')
    end
    is_argin_rowrange = true;
else
    rowrange = [1,Inf];
end
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
is_argin_filepos = false;   % 'FilePos'
if valpos(13) ~= 0   
    filepos = varargin{valpos(13)};
    if filepos<0 || (rem(filepos,1)~=0)
        error('FilePos argument must be a nonnegative integer.')
    end
    is_argin_filepos = true;
else
    filepos = 0;
end
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% handle file name argument
if nargin == 0 || isempty(varargin{1})  % no file or path name given?
    [filn,pn] = uigetfile('*.*', dialog_string);    % open file dialogue
    ffn = fullfile(pn,filn);
elseif exist(varargin{1},'dir') == 7    % only path name given
    curcd = cd;
    cd(varargin{1});                    % temporarily change directory
    [filn,pn] = uigetfile('*.*', dialog_string);    % open file dialogue
    ffn = fullfile(pn,filn);
    cd(curcd);
elseif exist(varargin{1},'file')        % file name given
    ffn  = varargin{1};
	[dum_pathstr,name,ext] = fileparts(ffn);
	filn = [name,ext];
else                                    % wrong name
    error([mfilename ': no such file or directory.'])
end
if exist(ffn,'file')~=2                 % check again (e.g. afger ESC in open file dialogue)
    error('No existing file given.')
end

% generate a shortened form of the file name:
if length(filn) < 28
    ffn_short = filn;
else
    ffn_short = ['...' filn(end-17:end)];
end

clear varargin mem_par

%% Analyse data format

% try some automatic data format analysis if needed (by function anatxt)
if ~all([is_argin_num_header, is_argin_num_colon]) %, is_argin_conv_str]); % commented out as so far anatxt's conv_str is only '%f'
    % call subfunction anatxt:
    [ffn, ana_num_header, ana_num_colon, ana_conv_str, ana_sr_input_ca, ana_rm, num_ali, ana_hl, ferrmsg] = anatxt(ffn,filepos);
    % accept required results from anatxt:
    if ~is_argin_num_header
        num_header = ana_num_header;
    end
    if ~is_argin_num_colon
        num_colon = ana_num_colon;
    end
    %if ~is_argin_conv_str      
    %    conv_str = ana_conv_str;
    %end
    if ~is_argin_readmode
        readmode = ana_rm;
    end
    % add new replacement strings from anatxt:
    is_new_sr   = ~ismember(ana_sr_input_ca, sr_input_ca);
    num_sr      = num_sr + sum(is_new_sr);
    sr_input_ca = [sr_input_ca,ana_sr_input_ca(is_new_sr)];
    % display information:
    if infolvl >= 1
        disp(repmat('*',1,length(ffn)+2));
        disp(['* ' ffn]);
        if numel(ferrmsg)==0
            sr_display_str = '';
            for idx = 1:num_sr;
                sr_display_str = [sr_display_str ' �' sr_input_ca{idx} '�']; %#ok<AGROW>
            end
            disp(['* read mode: ' readmode]);
            disp(['* ' num2str(num_ali)    ' data lines analysed' ]);
            disp(['* ' num2str(num_header) ' header line(s)']);
            disp(['* ' num2str(num_colon)  ' data column(s)']);
            disp(['* ' num2str(num_sr)     ' string replacement(s)' sr_display_str]);
        else
            disp(['* fread error: ' ferrmsg]);
        end
        disp(repmat('*',1,length(ffn)+2));
    end % if
    
    % return if anatxt did not detect valid data
    if ana_num_colon==0
        A = [];
        hl = '';
        fpos = filepos;
        return
    end
end

%% Detect line termination character

% www.editpadpro.com/tricklinebreak.html :
% Line Breaks in Windows, UNIX & Macintosh Text Files
% A problem that often bites people working with different platforms, such
% as a PC running Windows and a web server running Linux, is the different
% character codes used to terminate lines in text files. 
% 
% Windows, and DOS before it, uses a pair of CR and LF characters to
% terminate lines. UNIX (Including Linux and FreeBSD) uses an LF character
% only. The Apple Macintosh, finally, uses a CR character only. In other
% words: a complete mess.

if infolvl >= 1
    hw = waitbar(0,'detect line termination character ...');
    set(hw,'Name',[mfilename ' - ' ffn_short]);
end

has_found_lbs = false;
f8 = [];
cntr = -1;
% read until line termination characters are found
logfid = fopen(ffn); 
while ~has_found_lbs && cntr ~= 0
    [f8new,cntr] = fread(logfid,16384,'*uint8');
    f8  = [f8;f8new]; %#ok<AGROW>
    if any([numel(find(f8==cruint)),numel(find(f8==lfuint))]>1)
        has_found_lbs = true;
    end
end
fclose(logfid); 

% detect line termination character
if ~any(f8==lfuint) && any(f8==cruint)
    lbuint = cruint;    % 13, Mac style, only CRs
else
    lbuint = lfuint;    % 10
end

%% Read in ASCII file. Case 1: Portions only, as RowRange is given
% RowRange should be given if file is too huge to be read at once by fread.
% In this case consecutive freads are used.
% A line begins with its first character and ends with its last termination
% character.

if infolvl >= 1
    waitbar(0.0,hw,'reading file ...');
end

logfid = fopen(ffn);
if is_argin_filepos
    fseek(logfid,filepos,'bof');
end

if is_argin_rowrange
    do_read             = true;     % loop condition
    num_lb_prev         = 0;
    read_len            = idx_rng;
    f8                  = [];
    fposhdr             = 0;
    while do_read
        [f8p,lenf8p]  = fread(logfid,read_len,'*uint8');         % current text section

        ldcp_curr       = find(f8p==lbuint);            % line break positions in current text section
        num_lb_curr     = numel(ldcp_curr);

        % to add all header lines to f8
        if num_lb_prev < num_header                 % not all header lines were read at the end of the prev. loop => add more text to f8 
            if num_header>num_lb_curr+num_lb_prev   % header even ends beyond current section
                hdx = lenf8p;                       % end index is length of section => add the whole section to f8
            else                                            % header ends within current section
                num_lines_to_add = num_header-num_lb_prev;  % how many lines to add
                hdx = ldcp_curr(num_lines_to_add);          % corresponding end index
            end
            f8 = [f8; f8p(1:hdx)]; %#ok<AGROW>
            fpos = ftell(logfid)-lenf8p+hdx;        % position of latest used character 
            fposhdr = fpos-filepos;                 % index of end of header in f8
        end

        % to add lines of interest to f8
        if (num_lb_prev < num_header+rowrange(2)) && (num_lb_prev+num_lb_curr >= num_header+rowrange(1)-1)

            if num_header+rowrange(1)-1<=num_lb_prev            % lines of interest started before current section
                sdx = 1;                                        % start index is beginning of section => the part of the section to add to f8 includes the start of the section 
            else                                                % lines of interest start within current section
                num_lines_to_omit = num_header+rowrange(1)-1-num_lb_prev; % how many lines not to add
                sdx = ldcp_curr(num_lines_to_omit)+1;                     % start right after the omitted lines
            end

            if num_header+rowrange(2)>num_lb_curr+num_lb_prev   % lines of interest even end beyond current section
                edx = lenf8p;                                   % end index is length of section => the part of the section to add to f8 includes the end of the section 
            else                                                % lines of interest end within current section
                num_lines_to_add = num_header+rowrange(2)-num_lb_prev;  % how many lines to add
                edx = ldcp_curr(num_lines_to_add);                      % corresponding end index
            end

            f8 = [f8; f8p(sdx:edx)]; %#ok<AGROW>
            fpos = ftell(logfid)-lenf8p+edx;       % position of latest used character 
        end

        % quit loop if all rows of interest are read or if end of file is reached 
        if num_lb_prev >= num_header+rowrange(2) || lenf8p<read_len
            do_read = false;
        end
        num_lb_prev          = num_lb_prev + num_lb_curr;    % absolute number of dectected line breaks
    end
    
    hl = char(f8(1:fposhdr)');
end
%% Read in ASCII file. Case 2: Full file

if ~is_argin_rowrange
    [f8,fpos]  = fread(logfid,Inf,'*uint8'); % das Einlesen

    % simply read header with fgetl
    hl = '';
    if num_header > 0
        fseek(logfid, 0, 'bof');
        for i = 1:num_header
            hl = [hl, fgetl(logfid), char(lbuint)]; %#ok<AGROW>
        end
    end
end

if ftell(logfid) == -1
    error(ferror(fid, 'clear'));
end

fclose(logfid); 

if numel(f8)==0
    A = [];
    close(hw)
    return
end


%% Clean up trailing whitespaces
% replace all trailing whitespaces by spaces and a linebreak
% (quick&dirty)

if infolvl >= 1
    waitbar(0.0,hw,'cleaning up whitespaces ...');
end
cnt_trail_white = 0;
is_ws_at_end = true;

while is_ws_at_end  % step through the endmost characters
    if f8(end-cnt_trail_white) <= spuint        % is it a whitespace?
        cnt_trail_white = cnt_trail_white + 1;
    else
        f8(end-cnt_trail_white+1:end) = spuint;	% fill with spaces
        f8(end+(cnt_trail_white==0))  = lbuint;	% add a final linebreak
        is_ws_at_end = false;
    end
end % while


%% Find linebreak indices and bad line positions
% In what follows the text will repeatedly be processed in consecutive
% sections of length <idx_rng> to help avoid memory problems.

lenf8 = numel(f8);
idx_lo   = 1;   % init., start index of a section processed in a loop
lf_idc   = 0;   % init., will contain the line break indices
kl_idc   = [];  % init., will contain the indices of bad line markers strings
while idx_lo < lenf8
    if infolvl >= 1
        waitbar(0.25*(idx_lo/lenf8),hw,'finding line breaks ...');
    end
    idx_hi = min(idx_lo - 1 + idx_rng,lenf8);   % end index of current section
    
    % Check for possible bad line markers and find line breaks
    if num_kl>0
        f8_akt = f8(idx_lo:idx_hi);         	% current working section 
        for idx = 1:num_kl                      % find positions of all markers
            kl_idx_akt = findstr(kl_input_ca{idx},char(f8_akt'))';
            kl_tdc = [kl_idc; kl_idx_akt + idx_lo-1];
            kl_idc = kl_tdc;
        end % for
        islb   = f8_akt==lbuint;
    else
        islb   = f8(idx_lo:idx_hi)==lbuint;
    end
    
    % collect line break indices
    lf_tdc = [lf_idc; find(islb)+idx_lo-1]; % use lf_tdc temporarily to ...
    lf_idc = lf_tdc;                        % avoid memory fragmentation (?)
    idx_lo = idx_hi + 1;                 	% start index for the following loop
    
end % while
num_lf = numel(lf_idc);
clear lf_tdc islb f8_akt kl_tdc


%% Delete rows marked as bad

% Have we found bad line markers?
if ~isempty(kl_idc)
    if infolvl >= 1
        waitbar(0.25,hw,'deleting rows ...');
    end

    % find indices of line breaks bordering a marker
	[L,R] = neighbours(kl_idc, lf_idc);
    
    % care for multiple markers within a single row
    if any(diff(L) <= 0) && any(diff(R) <= 0)
        L = unique(L);
        R = unique(R);
    end
    
    % delete the bad rows
    f8 = cutvec(f8,L+1,R,false);
    
    % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    % update line break indices (same as above - are there better ways?)
    lenf8 = numel(f8);
    idx_lo   = 1;   % init., start index of a section processed in a loop
    lf_idc   = 0;   % init., will contain the line break indices
    while idx_lo < lenf8
        idx_hi = min(idx_lo - 1 + idx_rng,lenf8);       % end index of current section
        f8_akt = f8(idx_lo:idx_hi);                     % current working section  
        islb   = f8_akt==lbuint;
        lf_tdc = [lf_idc; find(islb)+idx_lo-1];         % use lf_tdc temporarily to ...
        lf_idc = lf_tdc;                                % avoid memory fragmentation (?)
        idx_lo = idx_hi + 1;                            % start index for the following loop
    end % while
    num_lf = numel(lf_idc);
    clear lf_tdc islb f8_akt
    % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
end % if
clear L R kl_idc


%% Replace expressions

f8=char(f8);                % quicker with strrep, required by sscanf
has_length_changed = false; % init. flag for changes of length of f8 by replacements

if num_er > 0
    if infolvl >= 1
        waitbar(0.25,hw,'replacing expressions ...');
    end

    ldx_lo = num_header+1;                                  % start index
    while ldx_lo < num_lf
        ldx_hi = min(ldx_lo - 1 + ldx_rng,num_lf);          % end index
        f8_akt = f8( lf_idc(ldx_lo)+1:lf_idc(ldx_hi))';    	% current working section
        len_f8_akt = (lf_idc(ldx_hi))-(lf_idc(ldx_lo));     % lenght of current section before replacements

        % Replacements:
        % e.g. {'odd','one','1'} replaces 'odd' and 'one' by '1'
        for vdx = 1:num_er                  % step throug replacements arguments
            srarg = replace_expr{vdx};    	% pick a single argument...

            for sdx = 1:(numel(srarg)-1)
                f8_akt = strrep(f8_akt, srarg{sdx}, srarg{end});    % ... and perform replacements
                if ~has_length_changed && (len_f8_akt~=numel(f8_akt))
                    has_length_changed = true;                      % detect a change of length of f8
                end
            end % for

        end % for

        % update f8-sections by f8_akt
        exten = numel(f8_akt) - len_f8_akt;	% extension by replacements
        if exten == 0   
            f8( lf_idc(ldx_lo)+1:lf_idc(ldx_hi)) = f8_akt';
        else            
            f8 = [f8(1:lf_idc(ldx_lo)); f8_akt'; f8(lf_idc(ldx_hi)+1:end)];
            % update linebreak indices of the following sections
            % (but we don't know the lb indices of the current one anymore):
            lf_idc(ldx_hi:end) = lf_idc(ldx_hi:end) + exten;
        end
        
        ldx_lo = ldx_hi; % start index for the following loop 
        if infolvl >= 1
            waitbar(0.25+0.25*(vdx-1+idx_lo/lenf8)/(num_er+num_sr),hw)
        end
    end % while

    clear f8_akt
end % if

%% Update linebreak indices
% see above...

if has_length_changed
    if infolvl >= 1
        waitbar(0.25+0.25*(num_er)/(num_er+num_sr),hw,'finding new line breaks ...')
    end
    f8=uint8(f8);
    lenf8 = numel(f8);
    idx_lo   = 1;   
    lf_idc   = 0;   
    while idx_lo < lenf8
        idx_hi = min(idx_lo - 1 + idx_rng,lenf8);       
        f8_akt = f8(idx_lo:idx_hi);                      
        islb   = f8_akt==lbuint;
        lf_tdc = [lf_idc; find(islb)+idx_lo-1];         
        lf_idc = lf_tdc;                                
        idx_lo = idx_hi + 1;    
    end % while
    num_lf = numel(lf_idc);
    clear lf_tdc islb f8_akt
    f8=char(f8);
end

%% Replace characters
% The character replacements don't change the line break positions. They
% start with the first character following the header. Again the text will
% be processed in consecutive sections of length <idx_rng>.

if infolvl >= 1 && num_sr > 0
    waitbar(0.25+0.25*(num_er)/(num_er+num_sr),hw,'replacing characters ...')
end

for vdx = 1:num_sr                  % step through replacement arguments
    srarg = sr_input_ca{vdx};       % pick a single argument
            % e.g. 'abc ' replaces 'a','b' and 'c' by ' '
            % z.B. ',.'   replaces a comma by a dot
    idx_lo   = 1 + lf_idc(num_header+1);
    while idx_lo < lenf8
        idx_hi = min(idx_lo - 1 + idx_rng,lenf8);
        f8_akt = f8(idx_lo:idx_hi)';
        
        for sdx = 1:(numel(srarg)-1)
            rep_idx = idx_lo-1+strfind(f8_akt,srarg(sdx));
            f8(rep_idx) = srarg(end);   % perform replacement
        end % for
        
        idx_lo = idx_hi + 1;
        if infolvl >= 1
            waitbar(0.25+0.25*(num_er+vdx-1+idx_lo/lenf8)/(num_er+num_sr),hw)
        end
    end % while
end % for
clear f8_akt f8_alt rep_idx


%% Try converting large sections (ReadMode 'Matrix')
% sscanf will be applied to consecutive working sections consisting of
% <ldx_rng> rows. The number of numeric values must then be a multiple of
% the number of columns. Otherwise, or if sscanf produces an error, inform
% the user and eventually proceed to the (slower) line-by-line conversion.

errmsg = '';    % Init. error message variable
if strcmpi(readmode,'auto') || strcmpi(readmode,'matrix') 
    if infolvl >= 1
        waitbar(0.5,hw,'converting large bites ...');
    end
    f8=char(f8);
    if vn>=7
        lf_idc = uint32(lf_idc);    % to save memory...
    end
    try
        % initialize result matrix A depending on matlab version:
        if vn>=7
            A = zeros(num_lf-num_header-1,num_colon,numerictype);
        else
            Ar= zeros(1,num_colon);
            switch lower(numerictype)
                case 'double'
                    A = zeros(num_lf-num_header-1,num_colon);
                case 'single'
                    A = repmat(single(Ar),num_lf-num_header-1,1);
                case 'int8'
                    A = repmat(int8(Ar),num_lf-num_header-1,1);
                case 'int16'
                    A = repmat(int16(Ar),num_lf-num_header-1,1);
                case 'int32'
                    A = repmat(int32(Ar),num_lf-num_header-1,1);
                case 'int64'
                    A = repmat(int64(Ar),num_lf-num_header-1,1);
                case 'uint8'
                    A = repmat(uint8(Ar),num_lf-num_header-1,1);
                case 'uint16'
                    A = repmat(uint16(Ar),num_lf-num_header-1,1);
                case 'uint32'
                    A = repmat(uint32(Ar),num_lf-num_header-1,1);
                case 'uint64'
                    A = repmat(uint64(Ar),num_lf-num_header-1,1);
            end
            clear Ar            
        end
        ldx_lo = num_header+1;  % lower row index
        val_cntr = 0;           % number of values read
        char_cntr = 0;          % number of characters read
        diag_cntr = 0;          % loop counter
        while ldx_lo < num_lf
            ldx_hi = min(ldx_lo - 1 + ldx_rng,num_lf); 	% lower row index of current working section
            [Atmp,count,errmsg,nextindex] = sscanf(f8( lf_idc(ldx_lo)+1:lf_idc(ldx_hi)),conv_str);    % THE conversion
            char_cntr = char_cntr + nextindex - 1;      
            diag_cntr = diag_cntr + 1;                  
            num_lines_loop = ldx_hi-ldx_lo;
            val_cntr = val_cntr + count;
            
            % error 1) current section was not completely read in 
            if ~isempty(errmsg)
                if nextindex <= lf_idc(ldx_hi)-(lf_idc(ldx_lo)+1)+1   
                    % find line break index of the abortion line
                    err_line_idx = min(find(lf_idc-(char_cntr+lf_idc(num_header+1))>0));    %#ok<MXFND> 
                    % give user the location of the error cause
                    if infolvl >= 2
                        disp(['Sscanf error after reading ' num2str(val_cntr) ' numeric values. Critical row (no. ' num2str(err_line_idx-1) '): '])
                        disp(f8(lf_idc(err_line_idx-1)+1:lf_idc(err_line_idx)-1)')
                    end % if
                end % if
                break;
            end

            % error 2) number of numeric values is not a multiple of the number of columns
            % try to provide some hints:
            if numel(Atmp) ~= num_colon * num_lines_loop 
                dlf = diff(lf_idc(ldx_lo:ldx_hi));      % length of each row
                [dlf_sort,dlf_sort_idc] = sort(dlf);
                % We don't know the lines containing the wrong number of
                % values. As a guess, just show the positions of the
                % longest and the shortest rows (simply count characters).
                if infolvl >= 2
                    disp('Warning: number of values is not a multiple of the number of rows.')
                    disp(['Longest  rows: ' num2str( num_header-1+ldx_lo+dlf_sort_idc(end:-1:end-4)', ' %i' ) ' (' num2str( dlf_sort(end:-1:end-4)', ' %i' ) ' characters) '])
                    disp(['Shortest rows: ' num2str( num_header-1+ldx_lo+dlf_sort_idc(1:5)'         , ' %i' ) ' (' num2str( dlf_sort(1:5)'         , ' %i' ) ' characters) '])
                end % if
                error('Number of values is not a multiple of number of rows.')
            end % if

            % put the values to the right dimenions and add them to A
            Atmp = reshape(Atmp,num_colon,num_lines_loop)';
            A(ldx_lo-num_header:ldx_hi-num_header-1,:) = Atmp;

            ldx_lo = ldx_hi;      	% start index for the following loop
            if infolvl >= 1
                waitbar(0.5+0.5*(ldx_lo/num_lf),hw)
            end
        end % while

    catch   % catch further errors
        if ~exist('errmsg','var') || isempty(errmsg)
            errmsg = lasterr;
        end
    end % try
end

% Quit on error if 'matrix'-mode was enforced: 
if strcmpi(readmode,'matrix') && ~isempty(errmsg)
    if infolvl >= 1
        close(hw)
    end
    error(errmsg);
end


%% Converting line-by-line (ReadMode 'Line')

clear Atmp

if strcmpi(readmode,'line') || ~isempty(errmsg) 
    num_data_per_row = zeros(num_lf-num_header-1,1);

    if infolvl >= 2 && ~strcmpi(readmode,'line')
        disp('Due to error')
        disp(strrep(['  ' errmsg],char(10),char([10 32 32])))
        disp('txt2mat will now try to read line by line...')
    end % if

    % initialize result matrix A depending on matlab version:
    if vn>=7
        A = NaN*zeros(num_lf-num_header-1,num_colon,numerictype);
    else
        Ar= NaN*zeros(1,num_colon);
        switch lower(numerictype)
            case 'double'
                A = NaN*zeros(num_lf-num_header-1,num_colon);
            case 'single'
                A = repmat(single(Ar),num_lf-num_header-1,1);
            case 'int8'
                A = repmat(int8(Ar),num_lf-num_header-1,1);
            case 'int16'
                A = repmat(int16(Ar),num_lf-num_header-1,1);
            case 'int32'
                A = repmat(int32(Ar),num_lf-num_header-1,1);
            case 'int64'
                A = repmat(int64(Ar),num_lf-num_header-1,1);
            case 'uint8'
                A = repmat(uint8(Ar),num_lf-num_header-1,1);
            case 'uint16'
                A = repmat(uint16(Ar),num_lf-num_header-1,1);
            case 'uint32'
                A = repmat(uint32(Ar),num_lf-num_header-1,1);
            case 'uint64'
                A = repmat(uint64(Ar),num_lf-num_header-1,1);
        end
        clear Ar            
    end
    
    if infolvl >= 1
        if strcmpi(readmode,'line')
            waitbar(0.5,hw,{'reading line-by-line ...'})
        else
            poshw = get(hw,'Position');
            set(hw,'Position',[poshw(1), poshw(2)-4/7*poshw(4), poshw(3), 11/7*poshw(4)]);
            waitbar(0.5,hw,{'reading line-by-line because of error:';['[' errmsg ']']})
        end
        drawnow
    end
	
	% extract numeric values line-by-line:
	for ldx = num_header+1:(num_lf-1)
        a = sscanf(f8( (lf_idc(ldx)+1) : lf_idc(ldx+1)-1 ),conv_str)';
        num_data_per_row(ldx-num_header) = numel(a);
        A(ldx-num_header,1:min(numel(a),num_colon)) = a(1:min(numel(a),num_colon));
        
        % display waitbar:
        if ~mod(ldx,10000)
            if infolvl >= 1
                waitbar(0.5+0.5*(ldx./(num_lf-1)),hw)
            end
        end % if
	end % for
    
    % display info about number of numeric values per line
    if infolvl >= 2
        disp('Row length info:')
        idc_less_data = find(num_data_per_row<num_colon)+num_header;
        idc_more_data = find(num_data_per_row>num_colon)+num_header;
        num_less_data = numel(idc_less_data);
        num_more_data = numel(idc_more_data);
        num_equal_data = num_lf-num_header-1 - num_less_data - num_more_data;
        info_ca(1:3,1) = {['  ' num2str(num_equal_data)];['  ' num2str(num_less_data)];['  ' num2str(num_more_data)]};
        info_ca(1:3,2) = {[' row(s) found with ' num2str(num_colon) ' values'],...
                           ' row(s) found with less values',...
                           ' row(s) found with more values'};
        info_ca(1:3,3) = {' ';' ';' '};
        if num_less_data>0
            info_ca{2,3} = [' (row no. ', num2str(idc_less_data(1:min(10,num_less_data))'), repmat(' ...',1,num_less_data>10), ')'];
        end
        if num_more_data>0
            info_ca{3,3} = [' (row no. ', num2str(idc_more_data(1:min(10,num_more_data))'), repmat(' ...',1,num_more_data>10), ')'];
        end
        disp(strcatcell(info_ca));

    end % if infolvl >= 2
    
end % if

if infolvl >= 1
    close(hw)
end


%% : : : : : subfunction ANATXT : : : : : 
function [ffn, nh, nc, cstr, SR, RM, llta, hl, ferrmsg] = anatxt(varargin)

% ANATXT analyse data layout in a text file for txt2mat
% 
% Default usage:
% [ffn, nh, nc, cstr, SR, RM, llta, hl, ferrmsg] = anatxt(FFN);
%
% ffn       full file name of analysed file
% nh        number of header lines
% nc        number of columns
% cstr      conversion string (curr. always '%f')
% SR        character replacement string
% RM        recommended read mode
% llta      lines analysed after header
% hl        header line characters
% ferrmsg   file operation error message

%   Copyright 2006 A.T�nnesmann, The PierWorks, Inc. 
%   $Revision: 2.50 $  $Date: 2007/12/10 13:05:08 $

% possible usages:
% anatxt
% anatxt(ffn_string)
% anatxt(ffn_string,replace_expression_cell)
% anatxt(ffn_string,replace_expression_cell,fpos_numeric)
% anatxt(ffn_string,fpos_numeric)               <=== used by internal call
% anatxt(txt_uint8,ffn_string)
% anatxt(txt_uint8,ffn_string,replace_expression_cell)
% anatxt(txt_uint8,ffn_string,replace_expression_cell,fpos_numeric)
% anatxt(txt_uint8,ffn_string,fpos_numeric)


%% Input checking:

% still confusing for historical reasons...
v = ver('matlab');
vn= str2double(v.Version);
has_uint8 = 0;
has_fpos = 0;

% no filename => file open dialogue
if nargin == 0 || isempty(varargin{1})  
    [filn,pn] = uigetfile('*.*', 'Pick a file.');   
    ffn = fullfile(pn,filn);
elseif strcmpi(class(varargin{1}),'uint8') && nargin>1
    f8 = varargin{1};
    ffn = varargin{2};
    has_uint8 = 1;
elseif exist(varargin{1},'dir') == 7    % only a pathname...
    curcd = cd;
    cd(varargin{1});                    
    [filn,pn] = uigetfile('*.*', 'Pick a file.');    
    ffn = fullfile(pn,filn);
    cd(curcd);
elseif exist(varargin{1},'file')        % we have a filename
    ffn  = varargin{1};
else                                    % nonexisting file
    error([mfilename ': no such file or directory.'])
end

if exist(ffn,'file')~=2                 % check again (e.g. after 'cancel' during file open dialogue)
    error('No existing file given.')
end

if nargin>1 && isnumeric(varargin{nargin})
    fpos = varargin{nargin};
    has_fpos = 1;
end

if nargin == 2+has_fpos+has_uint8
    replace_expr = varargin{2+has_uint8};
    num_er       = length(replace_expr);
else
    replace_expr = {};
    num_er       = 0;
end

%% Read in file

% definitions
num_chars_read = 65536; % number of characters to read
has_nuff_n_ratio = 0.1; % this ratio will tell if a row has enough values
cstr     = '%f';        % assume floats only (so far)
lfuint   = uint8(10);   % LineFeed
cruint   = uint8(13);   % CarriageReturn

has_ferror = false; % init
ferrmsg = '';       % init
if ~has_uint8
    logfid = fopen(ffn); 
    if fpos > 0
        status = fseek(logfid,fpos,'bof');
        if status ~= 0
            has_ferror = true;
            ferrmsg = ferror(logfid,'clear');
        end
    end
    if ~has_ferror
        [f8,f8cnt] = fread(logfid,num_chars_read,'*uint8'); % THE read
        if f8cnt < num_chars_read
            did_read_to_end = true;
        else
            did_read_to_end = false;
        end
        f8 = f8';
    end
    fclose(logfid); 
end

if has_ferror || isempty(f8)
    [nh, nc, cstr, llta] = deal(0);
    [cstr, SR, RM, hl]   = deal('');
    return
end


%% Replace expressions, if needed
        
if num_er>0
    f8=char(f8);
    for vdx = 1:num_er                  
        srarg = replace_expr{vdx};    	
        for sdx = 1:(numel(srarg)-1)
            f8 = strrep(f8, srarg{sdx}, srarg{end});
        end % for
    end % for
    f8 = uint8(f8);
end


%% Find linebreaks

% types of characters:
printasc = uint8([32:127, 128+32:255]);             % printable ASCIIs
dec_nr_p = sort(uint8('+-1234567890eE.Na'));        % decimals with NaN, signs and .
dec_nr   = sort(uint8('1234567890'));               % pure decimals
sep_wo_k = uint8([9 32    58 59]);   	% separators excluding comma (Tab Space ,:;) 
sep_wi_k = uint8([9 32 44 58 59]);   	% separators including comma 
komma    = uint8(',');               	% ,
other    = setdiff(printasc, [sep_wi_k, dec_nr_p]); % printables without separators and decimals

% Detect line termination character (see txt2mat)
if ~any(f8==lfuint) && any(f8==cruint)
    lbuint = cruint;    % Mac style, only CRs
    lbstr = char(cruint);
else
    lbuint = lfuint;    % Windows, CR+LF, or Unix, LF only
    if sum(f8==cruint) >= sum(f8==lfuint)-1
        lbstr = char([cruint,lfuint]);
    else
        lbstr = char(lfuint);
    end
end

% if we are sure we read the whole file, add a final linebreak:
if did_read_to_end
    f8 = [f8,lbuint];
end

% preliminary linebreak positions:
idc_lb = find(f8==lbuint);

% position of the endmost number in f8
% (switch to double and use classic find arguments for compatibility)
idx_last_nr = max(find(ismembc(double(f8),double(dec_nr))));  %#ok<MXFND> % new syntax: find(ismembc(f8,dec_nr), 1, 'last' )
                                                       
% trim f8 after the first linebreak after the endmost number, or, if none
% present, after the first linebreak before that number:
if any(idc_lb>idx_last_nr)
    f8 = f8(1:min(idc_lb(idc_lb>idx_last_nr)));
else
    f8 = f8(1:max(idc_lb));
end
    
% Insert a space before every linebreak:
f8 = uint8(strrep(char(f8),lbstr,[' ', lbstr]));
f8c = char(f8);
f8d = double(f8);

% recover linebreak positions
is_lb   = f8==lbuint;
idc_lb  = find(is_lb);
num_lb  = numel(idc_lb);


%% Find character types

% characters not expected to appear in the data lines:
is_othr = ismembc(f8d,double(other));       % switch to double for compatibility 
is_beg_othr = diff([false, is_othr]);       % true where groups of such characters begin
idc_beg_othr = find(is_beg_othr==1);        % start indices of these groups
[S, sidx] = sort([idc_lb,idc_beg_othr]);    % in sidx, the numbers (1:num_lb) representing the linebreaks are placed between the indices of the start indices from above 
num_beg_othr_per_line = diff([0,find(sidx<=num_lb)]) - 1;   % number of character groups per line

% numbers enclosing a dot:
% idc_digdotdig = regexp(f8c, '[\+\-]?\d+\.\d+([eE][\+\-]?\d+)?', 'start');
idc_digdotdig = regexp(f8c, '[\+\-]?\d+\.\d+([eE][\+\-]?\d+)?');
[S, sidx] = sort([idc_lb,idc_digdotdig]);
num_beg_digdotdig_per_line = diff([0,find(sidx<=num_lb)]) - 1;

% numbers enclosing a comma:
% idc_digkomdig = regexp(f8c, '[\+\-]?\d+,\d+([eE][\+\-]?\d+)?', 'start');
idc_digkomdig = regexp(f8c, '[\+\-]?\d+,\d+([eE][\+\-]?\d+)?');
[S, sidx] = sort([idc_lb,idc_digkomdig]);
num_beg_digkomdig_per_line = diff([0,find(sidx<=num_lb)]) - 1;

% numbers without a dot or a comma:
% idc_numbers = regexp(f8c, '[\+\-]?\d+([eE][\+\-]?\d+)?', 'start');
idc_numbers = regexp(f8c, '[\+\-]?\d+([eE][\+\-]?\d+)?');
[S, sidx] = sort([idc_lb,idc_numbers]);
num_beg_numbers_per_line = diff([0,find(sidx<=num_lb)]) - 1;

% commas enclosed by numeric digits
% idc_kombd = regexp(f8c, '(?<=[\d]),(?=[\d])', 'start');
if vn>=7
    idc_kombd = regexp(f8c, '(?<=[\d]),(?=[\d])');  % lookaround new to v7.0??
else
    idc_kombd = 1+regexp(f8c, '\d,\d');
end
[S, sidx] = sort([idc_lb,idc_kombd]);
num_beg_kombd_per_line = diff([0,find(sidx<=num_lb)]) - 1;

% two sequential commas without a (different) separator inbetween
% idc_2kom  = regexp(f8c, ',[^\s:;],', 'start');
idc_2kom  = regexp(f8c, ',[^\s:;],');

% commas:
is_kom  = f8==komma;
idc_kom = find(is_kom);
[S, sidx] = sort([idc_lb,idc_kom]);
num_kom_per_line = diff([0,find(sidx<=num_lb)]) - 1;


%% Analyse

% Determine number of header lines:
nh = max([0, find(num_beg_othr_per_line>0)]); %#ok<MXFND>  	% for now, take the last line containing an 'other'-character 
num_beg_numbers_ph = num_beg_numbers_per_line(nh+1:end);    % number of lines following
% by definition, a line is a valid data line if it contains enough numbers
% compared to the average:
has_enough_numbers = num_beg_numbers_ph>has_nuff_n_ratio.*mean(num_beg_numbers_ph);  
nh = nh + min(find(has_enough_numbers)) - 1; %#ok<MXFND>   	

if nh>0
    f8v_idx1 = idc_lb(nh)+1;
    hl = char(f8(1:idc_lb(nh)));
else
    f8v_idx1 = 1;
    hl = [];
end

f8v = f8(f8v_idx1:end); % valid data section of f8
llta = num_lb - nh;     % number of non-header lines to analyse

% find out decimal character (. or ,)
SR = {};        % Init. replacement character string
SR_idx = 0;     % Init. counter of the above
sepchar = '';   % Init. separator (delimiter) character
decchar = '.';  % Init. decimal character (default)

num_values_per_line = -num_beg_digdotdig_per_line + num_beg_numbers_per_line;

% Are there commas? If yes, are they decimal commas or delimiters?
if any( num_kom_per_line(nh+1:end) > 0 ) 
    sepchar = ',';  % preliminary take comma for delimiter
    % Decimal commas are neighboured by two numeric digits ...
    % and between two commas there has to be another separator
    if  all(num_kom_per_line(nh+1:end) == num_beg_kombd_per_line(nh+1:end)) ... % Are all commas enclosed by numeric digits?
        && ~any(num_beg_digdotdig_per_line(nh+1:end) > 0) ...   % There are no numbers with dots?
        && ~any(idc_2kom(nh+1:end) > 0)                         % There is no pair of commas with no other separator inbetween?

        decchar = ',';
        sepchar = '';
        
        num_values_per_line = -num_beg_digkomdig_per_line + num_beg_numbers_per_line; % number of values per line
    end
end

% replacement string for replacements by spaces
% other separators
is_wo_k_found = ismember(sep_wo_k, f8v);  % Tab Space : ;
is_other_found= ismember(other,f8v);      % other printable ASCIIs

% possible replacement string to replace : and ;
sr1 = [sepchar, char(sep_wo_k([0 0 1 1]&is_wo_k_found))];   
% possible replacement string to replace other characters
sr2 = char(other(is_other_found));        % still obsolete as such lines are treated as header lines

if numel([sr1,sr2])>0
    SR_idx = SR_idx + 1;
    SR{SR_idx} = [sr1, sr2, ' '];
end

% possible replacement string to replace the decimal character
if strcmpi(decchar,',')
    SR_idx = SR_idx + 1;
    SR{SR_idx} = ',.';
end

nc = max(num_values_per_line(nh+1:end));    % number of columns

% suggest a proper read mode depending on uniformity of the number of values per
% line
if numel(unique(num_values_per_line(nh+1:end))) > 1
    RM = 'line';
else
    RM = 'auto';
end

%% : : : : : further subfunctions : : : : : 

function s = strcatcell(C)

% STRCATCELL Concatenate strings of a 1D/2D cell array of strings
%
% C = {'a ','123';'b','12'}
%   C = 
%     'a '    '123'
%     'b'     '12' 
% s = strcatcell(C)
%   s =
%     a 123
%     b 12 

num_col = size(C,2);
D = cell(1,num_col);
for idx = 1:num_col
    D{idx} = char(C{:,idx});
end
s = [D{:}];

function [L,R] = neighbours(a,b)

% NEIGHBOURS find nearest neighbours in a given set of values
% 
% [L,R] = neighbours(a,b)
%
% find neighbours of elements of a in b:
% L(i): b(i) with a(i)-b minimal, a(i)-b >0 (left neighbour)
% R(i): b(i) with b-a(i) minimal, b-a(i)>=0 (right neighbour)
% 
% If no left or right neighbour matching the above criteria can be found
% in b, -Inf or Inf (respectively) will be returned.
%
%
% EXAMPLE:
% [L,R] = neighbours([-5, pi, 101],[-5:2:101])
% 
% L =
%   -Inf
%      3
%     99
% R =
%     -5
%      5
%    101

len_a = length(a);
ab    = [a(:);-Inf;b(:);Inf];

[ab,ix] = sort(ab);
[ix,jx] = sort(ix);

L = ab(max(1,jx(1:len_a)-1));
R = ab(jx(1:len_a)+1);

function [w, newidcoi, do_keep] = cutvec(v,li,hi,keep_flag,varargin)

% CUTVEC cut out multiple sections from a vector by index ranges
%
% USAGE:
%   w = cutvec(v,li,hi,keep_flag)
% OR
%   [w, new_idc_oi, do_keep] = cutvec(v,li,hi,keep_flag,old_idc_oi)
%
% v             input vector
% w             output vector consisting of v-sections
% li            lower limits of ranges (sorted!)
% hi            upper limits of ranges (sorted!)
% keep_flag     true:   cut out values outside the ranges
%               false:  cut out values within the ranges
% old_idc_oi    indices of interest in v
% new_idc_oi    corresponding indices of interest in w
% do_keep       logical matrix with w=v(do_keep)
%
% EXAMPLE:
%
% w = cutvec([1:20],[3,10,16],[7,12,19],1)
%
%   =>  w = [3 4 5 6 7   10 11 12   16 17 18 19]
%
% w = cutvec([1:20]*2,[3,10,16],[7,12,19],0)
%
%   =>  w = [2 4    16 18    26 28 30    40]
%
% tic, w = cutvec([1:5000000]',[100:500:5000000],[200:500:5000000],0); toc
% 
% elapsed_time =
% 
%     0.4380
% v = 1:20;
% li= [10,18];
% hi= [12,19];
% keep_flag = 0;
% idcoi = [1,4,7,10,13,18,20];
% 
% [w, newidcoi, do_keep] = cutvec(v,li,hi,keep_flag,idcoi)

%   $Revision: 1.10 $ 

len_v   = length(v);
len_i   = length(li);
k_flag  = logical(keep_flag);
has_idcoi = false;
newidcoi=[];

if nargin == 5
    idcoi   = int32(varargin{1});
    if ~issorted(idcoi)
        error([mfilename ':vector of indices of interest must be sorted!'])
    end
    has_idcoi = true;
end

% init:
if k_flag
    do_keep = false(len_v,1);
else
    do_keep = true(len_v,1);
end

for i = 1:len_i
    do_keep(li(i):hi(i)) = k_flag;
end
% How to do it without a loop??

if has_idcoi
    remidc   = int32(find(do_keep));
    newidcoi = ismembc2(idcoi,remidc);
end

w = v(do_keep);

% fast and versatile data import, suitable for large ascii text files
