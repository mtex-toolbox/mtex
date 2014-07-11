%CPRINTF	convert an array of any data type to a 2D character array
%
%		- converts an ND array of any MATLAB data type
%		  to a 2D character array
%		- the input may be a cell array formatted as a table with
%		  row/column labels and row/column separators
%		- any input can be formatted as a table using
%		  any combination of
%		  row/column labels and row/column separators
%		- the result may be written/appended to an ASCII file or
%		  inserted at a user marked position
%
%		  see also: sprintf, fprintf, printmat, cphelp, setpref
%
%SYNTAX
%-------------------------------------------------------------------------------
%		[T,TC,AC,P] = CPRINTF(A,OPT1,...,OPTn)
%				converts A
%		 P          = CPRINTF
%				returns  the engine parameters
%		              CPRINTF
%				displays the help
%
%INPUT
%-------------------------------------------------------------------------------
% A	:	an ND array of
%  		- real and/or complex full   numeric data
%  		- real and/or complex sparse numeric data
%  		- logical data
%  		- char strings
%		- structures
%  		- other objects
%  		an ND cell array of any combination of the above
%
% OPTION	argument	description		default
% ----------------------------------------------------------------
%		SC		a single CHAR
%		CS		a CHAR string
%		FS		a format spec
% ----------------------------------------------------------------
% CELL				data type
% ----------------------------------------------------------------
%    -c	:	FS		character string	'%s'
%    -n	:	FS		numeric real		'%g'
%   -cr	:	FS		numeric complex real	'%g'
%   -ci	:	FS		numeric complex imag	'%+gi'
%   -cd	:	FS		numeric complex delim	' '
%    -s	:	FS		numeric sparse indices	'(%g %g)'
%    -f	:	FS		false			'F'
%    -t	:	FS		true			'T'
%    -E	:	FS		empty CELL		'E(class)'
%    -I	:	FS		�Inf			'�INF'
%    -N	:	FS		NaN			'NAN'
%   -hs	:	T|F		convert to single hex	[F]
%   -hd	:	T|F		convert to double hex	[F]
%  -nex	:	T|F		no char CELL expansion	[F]
%    -O	:	FS		other objects		[built-in]
%   -Or	:	T|F		other objects raw mode	[built-in]
%    -C	:	FS		text surrounding CELLs	'%s'
%   -la	:	T|F		cell content alignment	[F]
%  -cla	:	T|F		complex alignment	[F]
%				F = right align
%				T = left  align
%
% ROW				content
% ----------------------------------------------------------------
%    -L	:	CS		leading   row text	''
%    -T	:	CS		trailing  row text	''
%    -d	:	SC		separator between CELLs	' '
%   -dt	:	SC		separator table columns	' '
%   -nd	:	T|F		show ND page indices	[F]
%
% TABLE				content / processing
% ----------------------------------------------------------------
%   -Ct	:	FS		text surrounding body	'%s'
%				but not label CELLs
%   -nc	:	FS		numeric real col	'%g'
%   -nr	:	FS		numeric real row
%   -Lh	:	{tn}		table  name		{' '}
%   -Lc	:	{c1...cn}	column labels
%   -Lr	:	{r1...rn}	row    labels
%  -Lcs	:	SC		column separator	''
%  -Lrs	:	SC		row    separator	''
%   -it	:	T|F		input is a       table	[F]
%   -mt	:	T|F		convert input to table	[F]
%   -ic	:	T|F		column width		[F]
%				F = max of all  cols
%				T = max of each col
%
% OUTPUT FILES
% ----------------------------------------------------------------
%   -fa	:	name		append to output file	[]
%   -fc	:	name		create    output file	[]
%   -fi	:	name		input  file		[]
%   -fm	:	marker		insert result at marker	[]
%				in file [-fin]
%   -fr	:	{t1,r1,...}	replace token tx with	[]
%				value rx
%
% PROCESSING
% ----------------------------------------------------------------
%    -p	:	T|F		do NOT use preferences	[F]
%  -opt	:	struct		use struct.option	[]
%  -ini	:	name		read options from file	[]
%  -sav	:	name		save options to   file	[]
%  -tab	:	n		use n SPACES/TAB	[8]
% -ntab	:	T|F		keep TABs in CELLs	[F]
%    -q	:	n		do not display result	[F]
%   -so	:	T|F		collect all output in	[F]
%				a structure
%   -db	:	T|F		show processing stages	[F]
%				and timing
%
%OUTPUT
%-------------------------------------------------------------------------------
% T	:	char array with same number of rows and
%		[-d] separated columns as A
% TC	:	cell array of T
% AC	:	cell array of A (useful if A is print as a table)
% P	:	structure with engine parameters
%
%NOTE
%-------------------------------------------------------------------------------
%		- FS a format spec
%		     - a valid SPRINTF/FPRINTF format string
%		     - a function or function handle returning a
%		       character string, eg,
%		       by default, options -E uses the functions
%		       @(x) sprintf('E(%s)',class(x))
%		- by default, other data types are decoded according
%		       to their class (see CPHELP)
%		- by default, CELLs of Mx1 or ND character strings
%		  are expanded unless the [-nex] option is used
%		- all [-Lx] options take a cell of any data type
%		- all [-Lx/-Lxx] options override
%		  preset [-it] or default [-mt] table entries
%		- all [-Lx] label(s) will be repeated or cut
%		  automatically to fit the table size
%		- TC/AC may be used as input into several
%		  spreadsheet applications, eg, xlswrite
%		- at startup, CPRINTF will look for default options set by
%			setpref('cprintf','opt',{OPT1,...,OPTn});
%		     - runtime options will overwrite preferences 
%		     - preferences are preserved between ML sessions
%		- if NO output argument is used, CPRINTF displays
%		  the result even if with a trailing <;>
%
%EXAMPLE
%-------------------------------------------------------------------------------
%	m=reshape(1:3*5,[3,5]);
% %	print M including their binary representation
%	cprintf(m,'-n',@(x) sprintf('%d=%s',x,dec2bin(x,4)),'-d','| ')
% 		 1=0001|  4=0100|  7=0111| 10=1010| 13=1101
% 		 2=0010|  5=0101|  8=1000| 11=1011| 14=1110
% 		 3=0011|  6=0110|  9=1001| 12=1100| 15=1111
%
% %	print M as a table with default labels/separators
%	cprintf(m,'-n',@(x) sprintf('%d=%s',x,dec2bin(x,4)),'-mt',1)
% 		  |       1       2       3       4       5
% 		-------------------------------------------
% 		1 |  1=0001  4=0100  7=0111 10=1010 13=1101
% 		2 |  2=0010  5=0101  8=1000 11=1011 14=1110
% 		3 |  3=0011  6=0110  9=1001 12=1100 15=1111

% created:
%	us	12-Jun-2006 us@neurol.unizh.ch
% modified:
%	us	11-Jun-2009 08:58:55
%
% localid:	us@USZ|ws-nos-36362|x86|Windows XP|7.8.0.347.R2009a
%
% Copyright (c) 2009, urs (us) schwarz
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
% 
%     * Redistributions of source code must retain the above copyright 
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright 
%       notice, this list of conditions and the following disclaimer in 
%       the documentation and/or other materials provided with the distribution
%       
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
% POSSIBILITY OF SUCH DAMAGE.




%-------------------------------------------------------------------------------
function	varargout=cprintf(varargin)

% common parameters
		magic='CPRINTF';
		pver='11-Jun-2009 08:58:55';

% option table
		F=false;
		%femp=@(x) sprintf('E(%s)',class(x));
    femp=@(x) '';
		finf=@(x) upper(sprintf('%+g',x));		% sign!
		foth=@CPRINTF_other;

		opt={
%		opt	{default	isset}	% description
%		----------------------------------------------------------------
% cell
		'-c'	{'%s'		F}	% character	string
		'-n'	{'%g'		F}	% numeric	real
		'-cr'	{'%g'		F}	% numeric	complex real
		'-ci'	{'%+gi'		F}	% numeric	complex imag
		'-cd'	{' '		F}	% numeric	delimiter r/c
		'-s'	{'(%g %g)'	F}	% numeric	sparse
		'-f'	{'F'		F}	% logical	false
		'-t'	{'T'		F}	% logical	true
		'-E'	{femp		F}	% empty		cell
		'-I'	{finf		F}	% numeric	inf
		'-N'	{'NAN'		F}	% numeric	nan
		'-hs'	{F		F}	% numeric	single hex
		'-hd'	{F		F}	% numeric	double hex
		'-nex'	{F		F}	% no expansion	ND char CELLs
		'-O'	{foth		F}	% other
		'-Or'	{F		F}	% other		raw
		'-C'	{''		F}	% surrounding	text
		'-la'	{F		F}	% alignment	left
		'-cla'	{F		F}	% alignment	left complex
% col
		'-hdr'	{{''}		F}	% text		header
		'-ftr'	{{''}		F}	% text		footer
% row
		'-L'	{''		F}	% text		leading
		'-T'	{''		F}	% text		trailing
		'-d'	{' '		F}	% separator
		'-dt'	{' '		F}	% separator	table only
		'-nd'	{''		F}	% ND array	page indices
% table
		'-Ct'	{''		F}	% surrounding	text table only
		'-nc'	{''		F}	% numeric	col labels
		'-nr'	{''		F}	% numeric	row labels
		'-Lh'	{{''}		F}	% name
		'-Lc'	{{''}		F}	% col		group names
		'-Lr'	{{''}		F}	% row		group names
		'-Lcs'	{'-'		F}	% col		separator
		'-Lrs'	{'|'		F}	% row		separator
		'-it'	{F		F}	% assume	table
		'-mt'	{F		F}	% force		table
		'-ic'	{F		F}	% individual	size
% file
		'-fa'	{''		F}	% append	output file
		'-fc'	{''		F}	% create	output file
		'-fi'	{''		F}	% input		file template
		'-fm'	{''		F}	% input		file marker
		'-fr'	{{''}		F}	% replace	tokens
% processing
		'-p'	{F		F}	% remove	preferences
		'-opt'	{F		F}	% use		option structure
		'-ini'	{''		F}	% load		option file
		'-sav'	{''		F}	% save		option file
		'-tab'	{8		F}	% \t		SPACES
		'-ntab'	{F		F}	% TAB		no replacement
		'-q'	{F		F}	% result	not displayed
		'-so'	{F		F}	% output	struct
		'-db'	{F		F}	% debug
% HIDDEN/ENGINE
		'-ce'	{F		F}	% character	strings (empty)
		'-ninf'	{F		F}	% marker	has NAN/INF
		};

% - sort option table
		[opt(:,1),pix]=sort(opt(:,1));
		opt(:,2)=opt(pix,2);
%-------------------------------------------------------------------------------
% check IO
	if	~nargin
	if	nargout
		[ctbl,par]=CPRINTF_setengine(magic,pver,opt,varargin{:});
		varargout{1}=par;
		varargout{2}=opt;			% internal use only
	else
		help(mfilename);
	end
		return;
	end

%-------------------------------------------------------------------------------
%		main engine
%-------------------------------------------------------------------------------

		[ctbl,par]=CPRINTF_setengine(magic,pver,opt,varargin{:});

		par.disp('CP| --------- :');
		t0=clock;
	if	~par.hasopt.ntab
		ctbl(par.in)=strrep(ctbl(par.in),par.tabc,par.tabs);
	end
	if	par.hasopt.c				&&...
		all(par.in)
		[ctbl,par]=CPRINTF_char(par,ctbl);
	end
	if	~all(par.in)
		[ctbl,par]=CPRINTF_cell2ascii(par,ctbl);
	else
	if	par.hasopt.C
		ix=find(par.in(:));
		[ctbl,par]=CPRINTF_cell(par,ctbl,ix,par.opt.C);
	elseif	par.hasopt.Ct
		tf=false(par.pr,par.pc);
		tf(par.tbody(1):par.tbody(2),par.tbody(3):par.tbody(4))=true;
		ix=find(tf(:));
		[ctbl,par]=CPRINTF_cell(par,ctbl,ix,par.opt.Ct);
	else
		par.in=false;
	end
	end
		ctbl=reshape(ctbl,par.pr,par.pc);
		rtbl=ctbl;
		[ctbl,par]=CPRINTF_ascii2string(par,ctbl);
		par.disp('CP| --------- : %10s = %19.6f sec','done',etime(clock,t0));
		par.disp(CPRINTF_repmat('-',[1,52]));
	
		[ctbl,par]=CPRINTF_write(par,ctbl);

	if	nargout >= 1
		varargout{1}=ctbl;
	if	nargout >= 2
		varargout{2}=rtbl;
	if	nargout >= 3
		varargout{3}=par.carg;
	if	nargout >= 4
		varargout{4}=par;
	end
	end
	end
	if	par.hasopt.so
		varargout{1}=par;
		varargout{1}.text=ctbl;
		varargout{1}.cell=rtbl;
	end
	elseif	~par.hasopt.q
		disp(ctbl);
	end
end
%-------------------------------------------------------------------------------
%		low level utility functions
%-------------------------------------------------------------------------------
function	CPRINTF_disp(varargin)
		disp(sprintf(varargin{:}));
end
%-------------------------------------------------------------------------------
function	CPRINTF_nodisp(varargin)
end
%-------------------------------------------------------------------------------
function	m=CPRINTF_macro

% keep workspace of function handles small

		m={
%		macro		function handle
%		-------------------------------------------------------------------
		'getpar'	@(varargin)	CPRINTF_parse_option(0,varargin{:})
		'setpar'	@(varargin)	CPRINTF_struct2opt(0,varargin{:})
		'ini'		@(varargin)	CPRINTF_ini2opt(0,varargin{:})
		'write'		@(varargin)	CPRINTF_ascii2file(varargin{:})
		'other'		@CPRINTF_other
		'comb'		@(varargin)	CPRINTF_comb([varargin{:}])
		'disp'		@CPRINTF_disp
		's2f'		@str2func
		};
end
%-------------------------------------------------------------------------------
function	res=CPRINTF_str2fh(str)

% keep fh.workspace{:} small
		res=@(x) sprintf(str,class(x));
end
%-------------------------------------------------------------------------------
function	res=CPRINTF_fh2fh(par,fh)

		th=functions(fh);
	if	~isempty(th.file)			&&...
		~strcmp(th.file,which(mfilename))
% ********** THE WORST CASE SCENARIO! **********
% - this construct needed due to an error in PUBLISH	!
% - fh from an INI file contains a bad file pointer

  		fn=th.function;
		ix=find(fn=='@',1,'first');
		fn=fn(ix:end);
		res=par.s2f(fn);

	else
		res=fh;
	end
end
%-------------------------------------------------------------------------------
function	res=CPRINTF_opt2cell(opt)

		on=cellfun(@(x) ['-',x],fieldnames(opt),'uni',false);
		res=reshape([on,struct2cell(opt)].',[],1).';
end
%-------------------------------------------------------------------------------
function	[opt,oflg]=CPRINTF_struct2opt(par,varargin)

	if	~nargout
		return;
	end

		opt=[];
		oflg=[];
	if	nargin < 2				||...
		~isstruct(varargin{1})
	if	~nargout
		clear opt;
	end
		return;
	end

	if	~isstruct(par)
		par=cprintf;
	end
		par.opt=par.otbl;
		copt=CPRINTF_opt2cell(varargin{1});
		[opt,oflg]=CPRINTF_parse_option(opt,copt{:});
end
%-------------------------------------------------------------------------------
function	res=CPRINTF_repmat(tok,siz)

% faster repmat replacement
	if	ischar(tok)
		res={tok};
		res=res(ones(siz));
		res=cat(2,res{:});
	else
		res=repmat(tok,siz);
	end
end
%-------------------------------------------------------------------------------
function	[ctbl,par]=CPRINTF_nd2d(par,ctbl)

% force 2D array
		par.ndc=ndims(ctbl);
		par.nsc=size(ctbl);
	if	par.ndc > 2
		ctbl=permute(ctbl,[1,3:numel(par.nsc),2]);
		ctbl=reshape(ctbl,[],par.nsc(2));
	end
		[par.pr,par.pc]=size(ctbl);
		par.nnc=numel(ctbl);
end
%-------------------------------------------------------------------------------
function	[ctbl,par]=CPRINTF_ndchar(par,ctbl)

		id=[];
		ic=0;

% spares numeric are never ND
	if	par.type.sparse
		par.opt.nd=true(size(ctbl,1),1);
		return;
	end

% show ND page indices
% - text
	if	par.hasopt.nd				&&...
		ischar(par.opt.nd)
		hasnd=true;
		larg=par.opt.nd;
		ichr=cellfun(@ischar,ctbl);
	if	any(ichr)
		ctbl=CPRINTF_cell(par,ctbl,find(ichr),@(x) sprintf('''%s''',x));
	end
		ic=~cellfun(@isreal,ctbl);
	if	any(ic(:))
		ttbl=cell(par.pr+prod(par.nsc(3:end)),par.pc+max(sum(ic,2)));
		ix=[false;CPRINTF_repmat(true,[par.nsc(1),1])];
		ix=[CPRINTF_repmat(ix,[prod(par.nsc(3:end)),1]);false(par.nsc(1),1)];
		iv=find(ix);
	for	i=1:numel(iv)
		cx=iv(i);
	for	j=1:par.pc
		ttbl(cx,2*j-1)={real(ctbl{i,j})};
	if	ic(i,j)
		ttbl(cx,2*j)={imag(ctbl{i,j})};
	else
		ttbl(cx,2*j)={0};
	end
	end
	end
		ctbl=ttbl;
		iv=ix;
		par.nsc(2)=size(ctbl,2);

	else
		ix=[false;CPRINTF_repmat(true,[par.nsc(1),1])];
		ix=CPRINTF_repmat(ix,[prod(par.nsc(3:end)),1]);
		iv=true(size(ctbl,1),1);
	end
		ic=max(sum(ic,2));

% - logical
	else
		hasnd=false;
		larg='';
		ix=[false;CPRINTF_repmat(true,[par.nsc(1),1])];
		ix=CPRINTF_repmat(ix,[prod(par.nsc(3:end)),1]);
		iv=true(size(ctbl,1),1);
	end

	if	 par.hasopt.nd				&&...
		(par.ndc > 2				||...
		 hasnd)

	if	strcmp(par.class,'struct')
		[res,id]=CPRINTF_comb(size(par.arg),true);
	else
		[res,id]=CPRINTF_comb(par.nsc,true);
	end

		ac=CPRINTF_repmat({''},[size(ix,1),par.pc+ic]);
		ac(ix,:)=ctbl(iv,:);
		ctbl=ac;
		iv=true(size(ix,1),1);
		ix=find(~ix);
		ix=ix(1:numel(res));
		ctbl(ix,1)=res;
		[par.pr,par.pc]=size(ctbl);
		par.carg=ctbl;
	end
	
% mixed char/other classes
% - ND char arrays
		par.in=cellfun(@ischar,ctbl);
	if	any(par.in(:))
		cd=cellfun(@ndims,ctbl);
		cs=cellfun(@(x) size(x,1),ctbl);
		cs(~par.in)=1;
		ix=find(cd>2&par.in);
%   force 2D
	if	~isempty(ix)
	for	i=1:numel(ix)
		ttbl=ctbl{ix(i)};
		ttbl=CPRINTF_nd2d(par,ttbl);
		ctbl{ix(i)}=ttbl;
	end
		cs=cellfun(@(x) size(x,1),ctbl);
	end

	if	any(cs(:)>1)
	if	par.hasopt.nex
		par.nmod=3;
		ix=find(cs(:)>1);
		[ctbl,par]=CPRINTF_cell(par,ctbl,ix,par.opt.O);
	else
		cx=[1;1+cumsum(max(cs,[],2))];
		ac=CPRINTF_repmat({''},[cx(end)-1,par.pc]);
	for	i=1:numel(cx)-1
		aoff=cx(i);
	for	j=1:size(cs,2)
		ct=ctbl{i,j};
	if	ischar(ct)
	for	k=1:cs(i,j)
		ac(aoff+k-1,j)={ct(k,:)};
	end
	else
		ac(aoff,j)=ctbl(i,j);
	end
	end
	end
		ctbl=ac;
		[par.pr,par.pc]=size(ctbl);
		par.carg=ctbl;
		iv=false;
	end
	end
	end

% set page indices
	if	par.hasopt.nd				&&...
		~isempty(id)

	if	~iv
		par.opt.nd=~strncmp(ctbl(:,1),id,numel(id));
	else
		par.opt.nd=~strncmp(ctbl(:,1),id,numel(id)) & iv;
	end
		ctbl(~par.opt.nd)=strrep(ctbl(~par.opt.nd),id,larg);

	if	hasnd
		par.opt.n=@(x) sprintf('''%s''',num2hex(x));
		par.hasopt.Or=true;
		icarg=iscell(par.arg);
		par.pc=par.pc+1;
		ctbl(:,end+1)={''};

		lsh=')';
		rsh='';
	if	ischar(par.arg)
		lsh=')=[...';
		rsh='];';
	elseif	par.isnumeric				&&...
		icarg
		lsh=')=num2cell(reshape(hex2num({';
		rsh=sprintf('}),[%d,%d]));',par.nsc(1:2));
	elseif	par.isnumeric
		lsh=')=reshape(hex2num({';
		rsh=sprintf('}),[%d,%d]);',par.nsc(1:2));
	elseif	icarg
		lsh=')={';
		rsh='};';
	end

	if	ic
		ix=par.pr-prod(par.nsc(3:end))+1:par.pr;
	for	i=1:numel(ix)
		ctbl{ix(i),1}=sprintf('%s = arrayfun(@(x,y) complex(x,y),%s(%d,1:2:end),%s(%d,2:2:end),''uni'',true);',res{i},larg,i,larg,i);
	end
		ctbl(ix)=strrep(ctbl(ix),id,larg);
	else
	end
		ix=find(~par.opt.nd);
		ix=ix(ix>0);
		ix=ix(1:prod(par.nsc(3:end)));
		ctbl(ix)=regexprep(ctbl(ix),')',lsh);
		ix=ix+prod(par.nsc(3:end))+0;
		ctbl(ix,end)={rsh};
	end

	else
		par.opt.nd=true(par.pr,1);
	end
end
%-------------------------------------------------------------------------------
function	[res,id]=CPRINTF_comb(siz,varargin)

	if	nargin == 1
		noff=0;
	else
		noff=2;
	end

		narg=numel(siz);
		n=narg-noff;
	if	n
		arg=cell(n,1);
		x=cell(n,1);
	for	i=1:n
		arg{i}=1:siz(i+noff);
	end
	else
		arg{1}=1;
	end

	if	n > 1
		[x{1:n,1}]=ndgrid(arg{1:end});
		res=reshape(cat(n+1,x{:}),[],n);
	else
		res=arg{:}.';
	end

% create unique page marker
	if	nargin > 1
		id=sprintf('_$$##%s##$$_',num2hex(rand(1,10)).');
		fmt=sprintf('(%d:%d,%d:%d',1,siz(1),1,siz(2));
		fmt=[id,fmt,CPRINTF_repmat(',%d',[1,n]),')\n'];
		res=sprintf(fmt,res.');
		res=strread(res,'%s','delimiter','\n');
	end
end
%-------------------------------------------------------------------------------
function	[ctbl,par]=CPRINTF_setengine(magic,pver,opt,varargin)

% common engine parameters
		par.magic=magic;
		par.('ver')=pver;
		par.MLver=version;
		par.section_10='---------- INPUT   ------------';
		par.arg={};
		par.class='';
		par.isnumeric=false;
		par.section_20='---------- OPTIONS ------------';
		par.otbl=opt;
		par.hasotbl=false(size(opt));
		par.opt=opt;
		par.hasopt=[];
		par.islog={};
		par.section_30='---------- ENGINE  ------------';
		par.fpar={};
		par.ctbl={};
		par.ndc=0;
		par.nsc=0;
		par.nnc=0;
		par.pr=0;
		par.pc=0;
		par.in=[];
		par.sconv=0;
		par.type=whos('magic');		% assign WHOS table
		par.istbl=false;
		par.hastbl=[false,false];	% row/col table labels/separators
		par.tlabel=[];
		par.tbody=[];
		par.sepr=[];
		par.sepc=[];
		par.fmt=[];
		par.fmts=[];
		par.dels=[];			% spaces: between numbers
		par.delst=[];
		par.tabc=sprintf('\t');
		par.tabs='';
		par.nmod=1;			% number: 1 = real
		par.section_31='---------- macros   -----------';
% assign macros created in a small function to save memory
		mac=CPRINTF_macro;
	for	i=1:size(mac,1)
		par.(mac{i,1})=mac{i,2};
	end
		par.section_40='---------- OUTPUT  ------------';
		par.text='';
		par.cell={};
		par.carg={};


% get input/options
		[ctbl,par]=CPRINTF_parse(par,varargin{:});
% set table labels/separators
		[ctbl,par]=CPRINTF_setlabel(par,ctbl);

% update parameters
	if	~par.istbl
		par.fpar(end-1:end,:)=[];
		par.fpar{end,4}=[];
	else
		par.fpar{5,4}=[1,par.pr,3,par.pc];
		par.fpar{6,4}=[3,par.pr,3,par.pc];
	end
	if	~isempty(ctbl)
		par.in=cellfun(@ischar,ctbl);
		ctbl=ctbl(:);
		par.in=par.in(:);
	end
end
%-------------------------------------------------------------------------------
function	par=CPRINTF_getfpar(par,mode)

% formatting spec
		T=true;
		F=false;
		par.fpar={
%		--------------------------------------------
% - 1 empty
		T	{par.opt.E,par.opt.E}	'empty'	,...
			[]					,...
			@isempty				,...
			@CPRINTF_empty
% - 2 nan/inf
		F	{par.opt.N,par.opt.I}	'naninf'	,...
			[]					,...
			@isnumeric				,...
			@CPRINTF_naninf
% - 3 logical
		T	{par.opt.f,par.opt.t}	'logical'	,...
			[]					,...
			@islogical				,...
			@CPRINTF_logical
% - 4 numeric
		T	{par.opt.n,par.opt.n}	'numeric'	,...
			par.tlabel				,...
			@isnumeric				,...
			@CPRINTF_number
% - 5 numeric
		T	{par.opt.nr,par.opt.nr}	'row label'	,...
			par.tbody				,...
			@isnumeric				,...
			@CPRINTF_number
% - 6 numeric
		T	{par.opt.nc,par.opt.nc}	'col label'	,...
			par.tbody				,...
			@isnumeric				,...
			@CPRINTF_number
		};

	switch	mode
	case	1
		par.fpar(end-1:end,:)=[];
		par.fpar{end,4}=[];
	case	2
	otherwise
	end
end
%-------------------------------------------------------------------------------
function	[ctbl,par]=CPRINTF_parse(par,varargin)

	if	nargin > 1
		arg=varargin{1};
	else
% create complete engine parameter structure
		par=CPRINTF_parse_option(par,varargin{:});
		par=CPRINTF_getfpar(par,2);
		ctbl=[];
		return;
	end
		par.istbl=false;
		par.arg=arg;
		ctbl=arg;

		[par.pr,par.pc]=size(ctbl);
		par.class=class(ctbl);
		par.isnumeric=isnumeric(ctbl);
		par.type=whos('ctbl');

		par=CPRINTF_parse_option(par,varargin{:});

% input class
% - ND struct
	if	isstruct(ctbl)
		cs=size(ctbl);
		sf=fieldnames(ctbl);
		nf=numel(sf);
% - anomalies!
	if	~any(cs)
		ctbl=[sf,CPRINTF_repmat({'[?]'},[nf,1])];
	elseif	~nf
		ctbl=repmat({'?','[?]'},cs);
	else
		ns=ones(size(cs));
		ns(1:2)=[nf,2];
		ttbl=cell(cs.*ns);
		ic=1:cs(1);
		ix=1:nf*cs(1);
		nx=numel(ix);
		ni=numel(ttbl)/nx;
	for	i=1:ni;
		cx=(i-1)*nx+ix;
	if	bitand(i,1)
		ttbl(cx)=CPRINTF_repmat(sf,[cs(1),1]);
	else
		ttbl(cx)=struct2cell(ctbl(ic));
		ic=ic+numel(ic);
	end
	end
		ctbl=ttbl;
	end
	end

	if	isempty(ctbl)
% D		error('%s> invalid/empty input',par.magic);
	if	iscell(ctbl)
		ctbl=CPRINTF_cell(par,{{}},1,par.opt.E);
	else
		ctbl={ctbl};
	end
	end

	if	~iscell(ctbl)
		ttbl=ctbl;
	switch	par.class
% - char array
	case	'char'
		[ttbl,par]=CPRINTF_nd2d(par,ttbl);
		ctbl=cell(par.pr,1);
	for	i=1:par.pr
		ctbl(i,1)={ttbl(i,:)};
	end
	otherwise
% - numeric
	if	par.type.sparse
%   2D sparse
		[cr,cc,cv]=find(ctbl);
	if	isempty(cr)
		cv=0;
		[cr,cc]=size(ctbl);
	end
		ttbl=[cr,cc,cv];
		[par.pr,par.pc]=size(ttbl);
	else
		[ttbl,par]=CPRINTF_nd2d(par,ctbl);
	end

		ctbl=cell(par.pr,par.pc);
		par.nnc=numel(ctbl);

%   numeric/logical
	if	isnumeric(ttbl)				||...
		islogical(ttbl)
	for	i=1:par.nnc
		ctbl(i)={ttbl(i)};
	end
	else
		ctbl={ttbl};
	end

	end	% par.class
	else
% - cell
		par.isnumeric=cellfun(@isnumeric,ctbl);
		par.isnumeric=all(par.isnumeric(:));
		[ctbl,par]=CPRINTF_nd2d(par,ctbl);
%   convert sparse to full
		par.in=cellfun(@issparse,ctbl);
	if	any(par.in(:))
		ctbl(par.in)=cellfun(@(x) full(x),ctbl(par.in),'uni',false);
	end
	end
		[par.pr,par.pc]=size(ctbl);
		par.carg=ctbl;

		[ctbl,par]=CPRINTF_ndchar(par,ctbl);

		par.tlabel=-[1,2,1,2];
		par.tbody=[1,par.pr,1,par.pc];
		par=CPRINTF_getfpar(par,2);
end
%-------------------------------------------------------------------------------
function	[par,opt]=CPRINTF_parse_option(par,varargin)

% simple (fast) option parser
% - default
	if	~isstruct(par)
%   internal use only!
		par=cprintf;
		voff=1;
	else
		voff=2;
	end

		par.opt=par.otbl;
		op=par.opt(:,1);
		hasop=false(size(op));
		par.islog=cat(1,par.opt{:,2});
		par.islog=cellfun(@islogical,par.islog(:,1));
		par.islog=strrep(op(par.islog),'-','');

		narg=numel(varargin);
	if	narg
		
% - display options
		par.hasopt.db=false;
		par.hasopt.q=false;
		ix=strcmp(varargin,'-db');
	if	any(ix(:))
		ix=find(ix,1,'last');
	if	ix < narg
		par.hasopt.db=~isempty(varargin{ix+1});
	end
	end
		ix=strcmp(varargin,'-q');
	if	any(ix(:))
		ix=find(ix,1,'last');
	if	ix < narg
		par.hasopt.q=~isempty(varargin{ix+1});
	end
	end

% - use preferences
		popt={};
	if	~strcmp(varargin,'-p')
		pref=getpref(lower(par.magic));
	if	isfield(pref,'opt')
		popt=pref.opt;
	end
	end

% - use ini file
		iopt={};
		ix=strcmp(varargin,'-ini');
	if	any(ix)

		ix=find(ix,1,'last')+1;
		fini=varargin{ix};
		fout='';
		ix=strcmp(varargin,'-sav');
	if	any(ix)
		ix=find(ix,1,'last')+1;
		fout=varargin{ix};
	end
		[iopt,par]=CPRINTF_ini2opt(par,fini,fout);
		iopt=CPRINTF_opt2cell(iopt);

	end

% - use option struct
		oopt={};
		ix=strcmp(varargin,'-opt');
	if	any(ix)
		ix=find(ix,1,'last')+1;
	if	isstruct(varargin{ix})
		oopt=varargin{ix};
		oopt=CPRINTF_opt2cell(oopt);
		varargin{ix}=true;
	end

	end

% - command line
		arg=[popt,iopt,oopt,varargin(voff:end)];
		narg=numel(arg);
	if	~isempty(arg)
		ix=find(...
			cellfun(@ischar,arg)		&...
			cellfun(@(x) size(x,1)==1,arg));
		[ia,iv]=ismember(op,arg(ix));
		ia=find(ia);
		iv=iv(iv>0);
	for	i=1:numel(ix(iv))
		cix=ix(iv(i));
	if	cix+1 > narg
		error('%s> [%s] argument missing',par.magic,arg{cix});
	end
		cia=ia(i);
		hasop(cia)=~isempty(arg{cix+1});
		par.opt{cia,2}(1)=arg(cix+1);
		par.opt{cia,2}{2}=hasop(cia);
	end
	end

	end	% has arguments

% - finalize option structure
		par.opt(:,1)=strrep(par.opt(:,1),'-','');
%   MACRO call
	if	voff == 1
		par.opt=par.opt(hasop,:);
	end
		par.opt=par.opt.';
		par.opt=struct(par.opt{:});
		par.hasopt=par.opt(2);
		par.opt=par.opt(1);
		par.hasotbl=hasop;

	if	~isempty(varargin)			&&...
		voff == 2
		par=CPRINTF_parse_chkoption(par);
	end

%   MACRO call
	if	nargout					&&...
		voff == 1
		opt=par.hasopt;
		par=par.opt;
	elseif	voff == 1
		clear par;
	end
end
%-------------------------------------------------------------------------------
function	par=CPRINTF_parse_chkoption(par)

% check/adjust	options
% - set		hasopt.xx of logical options xx
	for	clog=par.islog(:).'
		tlog=clog{1};
	if	par.hasopt.(tlog)
		tval=par.opt.(tlog);
		par.hasopt.(tlog)=false;
	if	~isempty(tval)				&&...
		 isscalar(tval)				&&...
		(ischar(tval)				||...
		 isnumeric(tval)			||...
		 islogical(tval))
		par.hasopt.(tlog)=tval~=0;
	end
	end
	end

% - R2009b
		ws=warning('off','all');
	try
		v=par.s2f('@(x) x');			% WARNING only
		v(10);					% ERROR   to catch
	catch	%#ok
		par.s2f=@eval;
	end
		warning(ws);

% - [-db]	debug	: check once only!
	if	par.hasopt.db
		par.disp=@CPRINTF_disp;
	else
		par.disp=@CPRINTF_nodisp;
	end
% - [-tab]	TAB - SPACES replacement
		spc=' ';
	if	~isnumeric(par.opt.tab)
		error('%s> [-tab] must be numeric',par.magic);
	end
		par.tabs=spc(ones([1,par.opt.tab]));
% - [-d]	must be CHAR
	if	~ischar(par.opt.d)
		error('%s> [-d] cell separator must be characters',par.magic);
	end
		par.opt.d=sprintf(par.opt.d);
		par.dels=numel(par.opt.d);
% - [-dt]	must be CHAR
	if	~ischar(par.opt.dt)
		error('%s> [-dt] table cell separator must be characters',par.magic);
	end
		par.opt.dt=sprintf(par.opt.dt);
		par.delst=numel(par.opt.dt);
% - [-cd]	must be CHAR
	if	par.hasopt.cd
	if	~ischar(par.opt.cd)
		error('%s> [-cd] real/complex separator must be characters',par.magic);
	end
		par.opt.cd=sprintf(par.opt.cd);
		par.opt.cd=strrep(par.opt.cd,par.tabc,par.tabs);
	end
% - [-Lcs]	must be CHAR
	if	par.hasopt.Lcs				&&...
		~ischar(par.opt.Lcs)
		error('%s> [-Lcs] col separator must be a character string',par.magic)
	end
% - [-Lrs]	must be CHAR
	if	par.hasopt.Lrs				&&...
		~ischar(par.opt.Lrs)
		error('%s> [-Lrs] col separator must be a character string',par.magic)
	end
% - [-L]	must be CHAR
	if	par.hasopt.L				&&...
		~ischar(par.opt.L)
		error('%s> [-L] leading row text must be a character string',par.magic)
	end
% - [-T]	must be CHAR
	if	par.hasopt.T				&&...
		~ischar(par.opt.T)
		error('%s> [-T] trailing row text must be a character string',par.magic)
	end
% - [-E]	must be function handle created in CPRINTF
%		must return a char string
	if	par.hasopt.E
	if	ischar(par.opt.E)
		par.opt.E=CPRINTF_str2fh(par.opt.E);
	elseif	isa(par.opt.E,'function_handle')
		par.opt.E=CPRINTF_fh2fh(par,par.opt.E);
	end

		par.opt.E({[]});

	end
% - [-O]	must be function handle created in CPRINTF
%		must return a char string
	if	par.hasopt.O
	if	ischar(par.opt.O)
		par.opt.O=CPRINTF_str2fh(par.opt.O);
	elseif	isa(par.opt.O,'function_handle')
		par.opt.O=CPRINTF_fh2fh(par,par.opt.O);
	end

		par.opt.O(cell(1,1));

	end
% - [-fm]
	if	par.hasopt.fm
	if	~ischar(par.opt.fm)
		error('%s> [-fm] file insertion marker must be a character string',par.magic);
	end
	if	size(par.opt.fm,1) > 1
		error('%s> [-fm] file insertion marker must have size 1xN',par.magic);
	end
	end
% - [-fr]	cell of 1xN CHAR strings
	if	par.hasopt.fr
	if	~iscell(par.opt.fr)
		error('%s> [-fr] token replacement strings must be in a cell',par.magic);
	end
	if	any(~cellfun(@ischar,par.opt.fr))
		error('%s> [-fr] all tokens/replacement strings must be character strings',par.magic);
	end
	if	any(cellfun(@(x) size(x,1),par.opt.fr)>1)
		error('%s> [-fr] all token replacement strings must have size 1xN',par.magic);
	end
	end
% - sparse	[-Lc]	must be adjusted
	if	par.type.sparse
	if	par.hasopt.Lc
		par.opt.Lc=[par.opt.Lc,par.opt.Lc{end}];
	end
%		[-it]	cannot be a table
	if	par.hasopt.it
		error('%s> [-it] sparse input cannot be a table: use [-mt]',par.magic);
	end
	end
% - hex		array/table body: all numeric format specs
	if	par.hasopt.hs
		fhx=@(x) sprintf('%s',num2hex(single(x)));
		par.opt.n=fhx;
		par.opt.cr=fhx;
		par.opt.ci=fhx;
	end
	if	par.hasopt.hd
		fhx=@(x) sprintf('%s',num2hex(double(x)));
		par.opt.n=fhx;
		par.opt.cr=fhx;
		par.opt.ci=fhx;
	end
% - [-mt]	overrides [-it]
	if	par.hasopt.mt
		par.hasopt.it=false;
	end
% - [-it]	cannot use [-nd]
	if	par.hasopt.it
		par.hasopt.nd=false;
	end
% - [-N] / [-I]	has any of the option
		par.hasopt.ninf=par.hasopt.N|par.hasopt.I;
end
%-------------------------------------------------------------------------------
function	[ctbl,par]=CPRINTF_setlabel(par,ctbl)


% anatomy of a table
%{
	.hastbl(1) = ROWS:	1 = +label	2 = +separator
	.hastbl(2) = COLS:	1 = +label	2 = +separator

								.hastbl(1)
		nan	|	a	b	c		1
		=========================================	2
		aa	|	e	e	e
		bb	|	e	e	e

	.hastbl(2)
		1
			2

	.tlabel(1:2)	ROW ix
	.tlabel(3:4)	COL ix

	.tbody(1)		-	-	-	ROW_1 ROW_n

	.tbody(2)		|			COL_1 COL_n
				|

%}

% set row/col labels/separators
	if	par.hasopt.it
		[ctbl,par]=CPRINTF_istable(par,ctbl);
	elseif	par.hasopt.mt
		[ctbl,par]=CPRINTF_chklabel(par,ctbl,'col',1,'Lc','-');
		[ctbl,par]=CPRINTF_chklabel(par,ctbl,'row',2,'Lr','|');
		[ctbl,par]=CPRINTF_forcetable(par,ctbl);
	elseif	~par.hasopt.Lc				&&...
		~par.hasopt.Lr
		return;
	end
		[ctbl,par]=CPRINTF_formatlabel(par,ctbl);

		par.hastbl=[0,0];
		[ctbl,par]=CPRINTF_chklabel(par,ctbl,'col',1,'Lc','-');
		[ctbl,par]=CPRINTF_chklabel(par,ctbl,'row',2,'Lr','|');

	if	par.hasopt.it
		par.hastbl=[2,2];
		ctbl(1,:)=par.opt.Lc(:).';
		ctbl(:,1)=par.opt.Lr(:);
	if	par.hasopt.Lrs
		ctbl(:,2)=CPRINTF_repmat({par.opt.Lrs},[par.pr,1]);
	end
	if	par.hasopt.Lcs
		ctbl(2,:)=CPRINTF_repmat({par.opt.Lcs},[1,par.pc]);
	end
	end

		[ctbl,par]=CPRINTF_settable(par,ctbl);
		par.ctbl=ctbl;
		[par.pr,par.pc]=size(ctbl);
end
%-------------------------------------------------------------------------------
function	[ctbl,par]=CPRINTF_chklabel(par,ctbl,ltype,ix,lmod,lsep)

% set field names
		lmods=[lmod,'s'];
		sepm=['sep',lmod(2)];
		cnum=['p',lmod(2)];
		mfmt=par.opt.(['n',lmod(2)]);

	if	par.hasopt.(lmod)

	if	~iscell(par.opt.(lmod))
		error('%s> %s label(s) must be in a CELL',par.magic,ltype);
	else
	if	ix == 2
		cnum=par.(cnum)-numel(find(~par.opt.nd));
	else
		cnum=par.(cnum);
	end
	
	if	numel(par.opt.(lmod)) ~= cnum
	if	par.hasopt.db
		warning('CPRINTF:chklabel','%s> #%s label(s) does not match table size: %d ~= %d',...
			par.magic,ltype,numel(par.opt.(lmod)),cnum);
		disp(sprintf('%s> #%s label(s) does not match table size: %d ~= %d',...
			par.magic,ltype,numel(par.opt.(lmod)),cnum));
	end
		nop=numel(par.opt.(lmod));
	if	nop < cnum
		nop=ceil(cnum./nop);
		par.opt.(lmod)=CPRINTF_repmat(par.opt.(lmod),[1,nop]);
	end
		par.opt.(lmod)=par.opt.(lmod)(1:cnum);
	end
		par.hastbl(ix)=1;
		par.opt.(lmod)=par.opt.(lmod)(:);
	if	par.hasopt.(lmods)
		par.(sepm)={par.opt.(lmods)};
		par.hastbl(ix)=2;
	else
		par.(sepm)={lsep};
	end
	end
	if	~par.hasopt.(lmods)
% D		par.hasopt.(lmods)=true;
		par.opt.(lmods)=par.(sepm){1};
	end
	end

% print numeric labels
	if	~isempty(mfmt)
	if	par.hasopt.(lmod)
		t=par.opt.(lmod);
		in=find(cellfun(@isnumeric,t)		&...
			cellfun(@isscalar,t));
		ie=	cellfun(@isnan,t(in))		|...
			cellfun(@isinf,t(in))		|...
			cellfun(@isempty,t(in))		|...
			cellfun(@islogical,t(in));
		in=in(~ie);
		t=CPRINTF_cell(par,t,in,mfmt);
		par.opt.(lmod)=t;
	end
	end

% separators must be 1 CHAR
	if	par.hasopt.(lmods)
	if	~ischar(par.opt.(lmods))		||...
		numel(par.opt.(lmods)) > 1
		error('%s> %s separator must be a single character',par.magic,ltype);
	end
	end
end
%-------------------------------------------------------------------------------
function	[ctbl,par]=CPRINTF_istable(par,ctbl)

% -it :	is a table

	if	par.pr < 3				||...
		par.pc < 3
		error('%s> table size to small (min size: 3x3): [%d/%d]',par.magic,par.pr,par.pc);
	end

	if	~par.hasopt.Lr
		par.hasopt.Lr=true;			% set T!
		par.opt.Lr=ctbl(:,1);
	else
		par.opt.Lr=[ctbl(1:2,1);par.opt.Lr(:)];
	end
	if	~par.hasopt.Lc				% set T!
		par.hasopt.Lc=true;
		par.opt.Lc=ctbl(1,:);
	else
		par.opt.Lc=[ctbl(1,1:2),par.opt.Lc(:).'];
	end
	if	~par.hasopt.Lrs				% do NOT set T!
		par.opt.Lrs=ctbl{par.pr,2};
	end
	if	~par.hasopt.Lcs				% do NOT set T!
		par.opt.Lcs=ctbl{2,par.pc};
	end
end
%-------------------------------------------------------------------------------
function	[ctbl,par]=CPRINTF_forcetable(par,ctbl)
	
% -mt :	make a table
%	set all HASOPT T

	if	~par.hasopt.Lr
		par.hasopt.Lr=true;
		par.opt.Lr=CPRINTF_repmat({''},[par.pr,1]);
		par.opt.Lr(par.opt.nd)=num2cell(1:numel(find(par.opt.nd)));
	else
		lr=CPRINTF_repmat({''},[par.pr,1]);
		lr(par.opt.nd)=par.opt.Lr;
		par.opt.Lr=lr;
	end
		par.opt.Lr(~par.opt.nd)={'page'};
		par.opt.nd=true(size(par.opt.Lr));

	if	~par.hasopt.Lc
		par.hasopt.Lc=true;
		par.opt.Lc=num2cell(1:par.pc);
	end
	if	~par.hasopt.Lrs
		par.hasopt.Lrs=true;
		par.opt.Lrs='|';
	end
	if	~par.hasopt.Lcs
		par.hasopt.Lcs=true;
		par.opt.Lcs='-';
	end
end
%-------------------------------------------------------------------------------
function	[ctbl,par]=CPRINTF_formatlabel(par,ctbl)

% -nr	row label format
	if	~par.hasopt.nr
		par.hasopt.nr=true;
		mfmt=max([1,ceil(log10(par.pr))]);
		par.opt.nr=sprintf('r:%%%d.%dd',mfmt,mfmt);
	end

% -nc	col label format
	if	~par.hasopt.nc
		par.hasopt.nc=true;
		mfmt=max([1,ceil(log10(par.pc))]);
		par.opt.nc=sprintf('c:%%%d.%dd',mfmt,mfmt);
	end
	
% -Lh	table name
	if	par.hasopt.Lh
	if	~iscell(par.opt.Lh)			||...
		numel(par.opt.Lh) > 1
		error('%s> [-Lh] table name must be a single CELL',par.magic);
	end
		paro=par;
		paro.in=cellfun(@ischar,paro.opt.Lh);
	if	~paro.in
		[paro.pr,paro.pc]=size(paro.opt.Lh);
		paro=CPRINTF_getfpar(paro,1);
		paro.hasopt.Ct=false;
		par.opt.Lh=CPRINTF_cell2ascii(paro,paro.opt.Lh);
	end
	end

% update formatting engine
		par=CPRINTF_getfpar(par,2);
end
%-------------------------------------------------------------------------------
function	[ctbl,par]=CPRINTF_settable(par,ctbl)

% create a full table
%	indices:	tbody/tlabel
% col	1:2
% row	3:4

	if	par.hastbl(2) && ~par.hastbl(1)
		par.opt.Lc=CPRINTF_repmat({'c'},[1,par.pc]);
		par.sepc=CPRINTF_repmat({'c'},[1,par.pc+2]);
	else
		par.sepc=CPRINTF_repmat(par.sepc,[1,par.pc+2]);
	end
	if	par.hastbl(1) && ~par.hastbl(2)
		par.opt.Lr=CPRINTF_repmat({'r'},[par.pr,1]);
		par.sepr=CPRINTF_repmat({'r'},size(par.opt.Lr));
	else
		par.sepr=CPRINTF_repmat(par.sepr,size(par.opt.Lr));
	end

	if	~par.hasopt.it
		ctbl=[[{' ',par.opt.Lrs},par.opt.Lc(:).';par.sepc(:).'];par.opt.Lr(:),par.sepr(:),ctbl];
	end

		[pr,pc]=size(ctbl);

% ROW
	if	par.hastbl(1) == 2
		par.tbody(1:2)=[3,pr];
		par.tlabel(1:2)=[-1,-2];
	elseif	par.hastbl(1) == 1
		par.tbody(1:2)=[2,pr-1];
		par.tlabel(1:2)=[-1,-1];
		ctbl(2,:)=[];
	else
		par.tbody(1:2)=[1,pr-2];
		par.tlabel(1:2)=[0,0];
		ctbl(1:2,:)=[];
	end
% COL
	if	par.hastbl(2) == 2
		par.tbody(3:4)=[3,pc];
		par.tlabel(3:4)=[-1,-2];
	elseif	par.hastbl(2) == 1
		par.tbody(3:4)=[2,pc-1];
		par.tlabel(3:4)=[-1,-1];
		ctbl(:,2)=[];
	else
		par.tbody(3:4)=[1,pc-2];
		par.tlabel(3:4)=[-1,0];
		ctbl(:,1:2)=[];
	end
% NAME
	if	par.hastbl(1)				&&...
		par.hastbl(2)
	if	par.hasopt.Lh
		ctbl(1,1)=par.opt.Lh;
	end
	end

	if	sum(par.hastbl) == 4
		par.istbl=true;
	end
end
%-------------------------------------------------------------------------------
%		printing routines
%-------------------------------------------------------------------------------
function	[ctbl,par]=CPRINTF_cell2ascii(par,ctbl)

		par.disp('CP| format    : %10s   %8d c',' ',numel(ctbl)-sum(par.in));
		t0=clock;
% save memory
% - data type
%   CHAR
		ic=par.in;
	if	par.hasopt.c
	if	any(ic)
		[ctbl,par]=CPRINTF_char(par,ctbl);
	end
	end
%   SCALAR NUMERIC | LOGICAL
		par.in=	 cellfun(@isempty,ctbl)		|...
			 cellfun(@isscalar,ctbl);
		par.in=	 par.in				&...
			(cellfun(@islogical,ctbl)	|...
			 cellfun(@isnumeric,ctbl));
%   OTHER
		ic=~(ic|par.in);
	if	any(ic)
		par.nmod=3;
		[ctbl,par]=CPRINTF_cell(par,ctbl,find(ic),par.opt.O);
	end

	if	any(par.in)

	for	i=1:size(par.fpar,1)
	if	par.fpar{i,1}
		sin=sum(par.in);
	if	sin
		par.sconv=0;
		t1=clock;
		par.disp('CP| type      : %10s = %8d c',par.fpar{i,3},sin);
		fh=par.fpar{i,end};
		[ctbl,par]=fh(par,ctbl,par.fpar(i,:));
		par.disp('CP| type      : %10s = -%7d c %8.6f sec',par.fpar{i,3},par.sconv,etime(clock,t1));
	end
	end
	end

	end

% note to programmers: this should NEVER happen...
	if	any(par.in)
		par.nmod=3;
 		[ctbl,par]=CPRINTF_cell(par,ctbl,find(par.in),par.opt.O);
	end

	if	par.hasopt.C
		ix=1:numel(ctbl);
		[ctbl,par]=CPRINTF_cell(par,ctbl,ix,par.opt.C);
		ctbl=strrep(ctbl,par.tabc,par.tabs);
	elseif	par.hasopt.Ct
		tf=false(par.pr,par.pc);
		tf(par.tbody(1):par.tbody(2),par.tbody(3):par.tbody(4))=true;
		ix=find(tf(:));
		[ctbl,par]=CPRINTF_cell(par,ctbl,ix,par.opt.Ct);
		ctbl(ix)=strrep(ctbl(ix),par.tabc,par.tabs);
	end

		par.disp('CP| format    : %10s = %8d c %8.6f sec','done',sum(par.in),etime(clock,t0));
end
%-------------------------------------------------------------------------------
function	[ctbl,par]=CPRINTF_ascii2string(par,ctbl)

		par.disp('CP| print     : %10s   %8d c',' ',numel(ctbl));
		t0=clock;

		[ctbl,par]=CPRINTF_format(par,ctbl);

% - note: for larger T, this is MUCH faster than
%   sprintf(fmt,t{:});

	for	i=1:par.pr
		ctbl{i,1}=sprintf(par.fmt,ctbl{i,1:par.pc});
		ctbl(i,2:par.pc)={[]};
	end

		par.disp('CP| print     : %10s = %19.6f sec','done',etime(clock,t0));

		ctbl=ctbl(:,1);
		ctbl=char(ctbl);

% set rowcol separators
		nc=size(ctbl,2);
		hastab=	any(strfind(par.opt.d,par.tabc)~=0)	||...
			any(strfind(par.opt.dt,par.tabc)~=0);
	if	par.hasopt.L
		coff=max([1,numel(par.opt.L)]);
	else
		coff=1;
	end

	if	par.istbl
	if	~hastab					&&...
		par.hasopt.Lcs
	if	numel(par.opt.Lcs) == 1
		mrk=par.opt.Lcs;
		ctbl(2,coff:coff+nc-1)=CPRINTF_repmat(mrk,[1,nc]);
	else
		ctbl(2,coff:coff+numel(par.opt.Lcs)-1)=par.opt.Lcs;
		par.hasopt.Lcs=false;
	end
	end
	end
	if	par.hastbl(1) == 2
	if	~hastab					&&...
		par.hasopt.Lcs
		ctbl(2,coff:coff+nc-1)=CPRINTF_repmat(par.opt.Lcs,[1,nc]);
	end
	end
	
% add header/footer
% - undocumented
	if	par.hasopt.hdr
		hdr=cprintf(par.opt.hdr,'-mt',0,'-ic',1);
		ctbl=char([
			{hdr}
			{ctbl}
		]);
	end
	if	par.hasopt.ftr
		hdr=cprintf(par.opt.ftr,'-mt',0,'-ic',1);
		ctbl=char([
			{ctbl}
			{hdr}
		]);
	end
end
%-------------------------------------------------------------------------------
function	[ctbl,par]=CPRINTF_format(par,ctbl)

% create format spec for columns
		mfmt=max(cellfun(@numel,ctbl),[],1);
		mfmt1=mfmt(1);
	if	~par.hasopt.ic
	if	par.istbl				||...
		par.hastbl(2)
		mfmt(3:end)=max(mfmt(3:end));
	else
		mfmt(1:end)=max(mfmt);
	end
	end
	if	any(par.hastbl)
		mfmt(1)=mfmt1;
	end
		par.fmts=mfmt;
		mfmt=CPRINTF_repmat(mfmt,[2,1]);
		mfmt=mfmt(:).';
	if	par.hasopt.la				% do NOT use .hasopt.la
		mfmt=sprintf('-%d.%d ',mfmt);		% left align cells
	else
		mfmt=sprintf('%d.%d ',mfmt);
	end
		mfmt=regexp(mfmt,'\s','split');
		mfmt(end)=[];

% - set col delimiter
	if	par.istbl
		par.fmt=CPRINTF_repmat('%XsY',[1,par.pc]);

	else
		par.fmt=CPRINTF_repmat('Y%Xs',[1,par.pc]);
	end

		par.fmt=regexprep(par.fmt,'X',mfmt,'once');
	if	par.hasopt.dt				&&...
		par.hastbl(2)
	for	i=1:2
		par.fmt=regexprep(par.fmt,'Y',par.opt.d,'once');
	end
		par.fmt=regexprep(par.fmt,'Y',par.opt.dt);
	else
		par.fmt=regexprep(par.fmt,'Y',par.opt.d);
	end
	
% - remove leading/trailing col delimiter
		dels=par.dels;
	if	par.hasopt.dt
		dels=par.delst;
	end
	if	par.istbl
		par.fmt=par.fmt(1:end-dels);
	else
		par.fmt=par.fmt(dels+1:end);
	end
		par.fmt=sprintf('%s%s%s',par.opt.L,par.fmt,par.opt.T);

		[ctbl,par]=CPRINTF_formattable(par,ctbl);
end
%-------------------------------------------------------------------------------
function	[ctbl,par]=CPRINTF_formattable(par,ctbl)

	if	par.hasopt.Lcs				&&...
		par.hastbl(1) == 2
		ctbl(2,:)=arrayfun(@(x) CPRINTF_repmat(par.opt.Lcs,[1,x]),par.fmts,'uni',false);
	end

% - insert col separators if not user defined
	if	par.istbl				&&...
		~par.hasopt.Lcs
		in=cellfun(@numel,ctbl(2,:));
		ix=in==1;
	if	isempty(strfind(par.opt.d,par.tabc))
		dels=par.dels;
	else
		dels=0;
	end
		fmts=par.fmts+dels;
		fmts(1)=par.fmts(1);

	if	any(ix)
		ctbl(2,ix)=cellfun(@(x,y) sprintf('%s',CPRINTF_repmat(x,[1,y])),ctbl(2,ix),num2cell(fmts(ix)),'uni',false);
	end
	if	any(~ix)
		spc=' ';
		fmts=fmts-in;
	if	par.hasopt.la
		ctbl(2,~ix)=cellfun(@(x,y) [sprintf('%s',x),spc(ones([1,y]))],ctbl(2,~ix),num2cell(fmts(~ix)),'uni',false);
	else
		ctbl(2,~ix)=cellfun(@(x,y) [spc(ones([1,y])),sprintf('%s',x)],ctbl(2,~ix),num2cell(fmts(~ix)),'uni',false);
	end
	end
		par.hasopt.Lcs=true;
		par.opt.Lcs=cat(2,ctbl{2,:});
	end
% - table name always left aligned
	if	par.hastbl(1)				&&...
		par.hastbl(2)
	if	par.hasopt.Lh
		hdr=par.opt.Lh{1};
	elseif	~isempty(ctbl{1,1})
		hdr=ctbl{1,1};
	end
		lfmt=sprintf('%%-%d.%ds',par.fmts(1),par.fmts(1));
		ctbl(1,1)={sprintf(lfmt,hdr)};
	end
end
%-------------------------------------------------------------------------------
%		formatting routines
%-------------------------------------------------------------------------------
function	res=CPRINTF_other(varargin)

% default output for non-scalar CELLs

		res=cell(nargin,1);

	for	i=1:nargin
		t=varargin{i};
% - numeric/logical data type
	if	isnumeric(t)				||...
		islogical(t)
		w=whos('t');
		siz=sprintf('%dx',w.size);
		siz(end)='';
	switch	w.class
	case	'logical'
		res{i}=sprintf('L(%d:%s',numel(w.size),siz);
	otherwise
		res{i}=sprintf('N(%d:%s:%s',numel(w.size),siz,w.class);
	end
	if	w.global
		res{i}=sprintf('%s.g',res{i});
	end
	if	w.sparse
		res{i}=sprintf('%s.s',res{i});
	end
	if	w.complex
		res{i}=sprintf('%s.c',res{i});
	end
		res{i}=sprintf('%s)',res{i});

% - other data type
	else
	switch	class(t)
	case	{'cell','struct'}
		w=whos('t');
		siz=sprintf('%dx',w.size);
		siz(end)='';
		res{i}=sprintf('%c(%d:%s)',upper(w.class(1)),numel(w.size),siz);
	case	'function_handle'
		fn=func2str(t);
	if	~(fn(1)=='@')
		fn=sprintf('@%s',fn);
	end
		res{i}=sprintf('F(%s)',fn);
	otherwise
		w=whos('t');
		siz=sprintf('%dx',w.size);
		siz(end)='';
		res{i}=sprintf('O(%d:%s:%s)',numel(w.size),siz,w.class);
	end
	end
	end

	if	nargin == 1
		res=res{i};
	end
end
%-------------------------------------------------------------------------------
function	[t,par]=CPRINTF_char(par,t)

		ic=find(par.in);
	if	par.hasopt.ce				% hidden option
		ix=~cellfun(@isempty,t(ic));
	if	any(ix)
		t=CPRINTF_cell(par,t,ic(ix),par.opt.c);
	end
	else
		t=CPRINTF_cell(par,t,ic,par.opt.c);
	end
end
%-------------------------------------------------------------------------------
function	[t,par]=CPRINTF_empty(par,t,fpar,varargin)

		vfmt=fpar{1,2};
		fun=fpar{1,5};

		isval=cellfun(fun,t);
	if	any(isval)
% keep empty CHARs
		isval=isval&~cellfun(@ischar,t);
		isval=find(isval);
		[t,par]=CPRINTF_cell(par,t,isval,vfmt{1});
	end
end
%-------------------------------------------------------------------------------
function	[t,par]=CPRINTF_logical(par,t,fpar,varargin)

		vfmt=fpar{1,2};
		fun=fpar{1,5};

		isval=cellfun(fun,t);
	if	any(isval)

		ixt=find(isval);
		ixfv=cellfun(@(x) x==false,t(ixt));

	if	any(ixt(ixfv))
		[t,par]=CPRINTF_cell(par,t,ixt(ixfv),vfmt{1});
	end
	if	any(ixt(~ixfv))
		[t,par]=CPRINTF_cell(par,t,ixt(~ixfv),vfmt{2});
	end
	end
end
%-------------------------------------------------------------------------------
function	[t,par]=CPRINTF_naninf(par,t,fpar,varargin)

	if	~par.hasopt.ninf
		return;
	end
	if	isempty(varargin)
		return;
	end

		vfmt=fpar{1,2};
		fun=fpar{1,5};

		isval=cellfun(fun,t);
	if	any(isval)

		isval=find(isval);
		isn=cellfun(@isnan,t(isval));
		isi=cellfun(@isinf,t(isval));

	if	par.hasopt.N
	if	any(isn)
		[t,par]=CPRINTF_cell(par,t,isval(isn),vfmt{1});
	end
	end
	if	par.hasopt.I
	if	any(isi)
		[t,par]=CPRINTF_cell(par,t,isval(isi),vfmt{2});
	end
	end

	end
end
%-------------------------------------------------------------------------------
function	[t,par]=CPRINTF_number(par,t,fpar,varargin)

		vfmt=fpar{1,2};
		fun=fpar{1,5};

		isval=cellfun(fun,t);
	if	any(isval)

	if	~isempty(fpar{4})
		isval=reshape(isval,[par.pr,par.pc]);
		db=fpar{4};
	if	any(sign(db) < 0)
		db=abs(db);
	if	db(1:2)
		isval(db(1):db(2),:)=false;
	end
	if	db(3:4)
		isval(:,db(3):db(3))=false;
	end
	else
		isval(db(1):db(2),db(3):db(4))=false;
	end
		isval=isval(:);
	end

% sparse
	if	par.type.sparse
		paro=par;
		paro.type.sparse=false;
		in=reshape(isval,[paro.pr,paro.pc]);
		in(:,end)=false;
		par.nmod=2;
		[t,par]=CPRINTF_cell(par,t,find(in),paro.opt.s);
	if	~any(par.hastbl)
		t=reshape(t,[par.pr,par.pc]);
		t(:,2)=[];
		t=t(:);
		par.pc=par.pc-1;
	else
		t=reshape(t,[par.pr,par.pc]);
		t(par.hastbl(1)+1:end,par.hastbl(2)+2)=t(par.hastbl(1)+1:end,par.hastbl(2)+3);
		t(:,end)=[];
		t=t(:);
		par.pc=par.pc-1;
	end
		isval=cellfun(fun,t);
		par.in=isval(:);
	end

% real and/or complex
		ixcv=~cellfun(@isreal,t(isval));
		par.nmod=1;
% real only
	if	~any(ixcv)
		[t,par]=CPRINTF_naninf(par,t,par.fpar(2,:),1);
		[t,par]=CPRINTF_cell(par,t,find(isval&par.in),vfmt{1});
% complex
	else
		ixr=find(isval);
		ixc=ixr;
		ixr=ixr(~ixcv);
		ixc=ixc(ixcv);
		paro=par;
		rfmt=[0,0];
% - real part
	if	~isempty(ixr)
		paro.in=true(size(ixr));
		[t(ixr),paro]=CPRINTF_naninf(paro,t(ixr),par.fpar(2,:),2);
		[t(ixr),paro]=CPRINTF_cell(paro,t(ixr),find(paro.in),vfmt{1});
		par.in(ixr)=false;
		rfmt(1)=max(cellfun(@numel,t(ixr)));
	end
% - complex part
		tn=cat(1,t{ixc});
		tr=real(tn);
		ti=imag(tn);
		tt=num2cell([tr,ti]);
		spc=' ';
		vfmt={par.opt.cr,par.opt.ci};
		mfmt=zeros(1,2);

	for	i=1:2
		paro.in=true(size(tt,1),1);
		[tt(:,i),paro]=CPRINTF_naninf(paro,tt(:,i),par.fpar(2,:),3);
		[tt(:,i),paro]=CPRINTF_cell(paro,tt(:,i),find(paro.in),vfmt{i});
		mfmt(i)=max(cellfun(@numel,tt(:,i)));
		mfmt(i)=max([mfmt(i),rfmt(i)]);
	if	par.hasopt.cla
		tt(:,i)=cellfun(@(x) [x,spc(ones(1,mfmt(i)-numel(x)))],tt(:,i),'uni',false);
	else
		tt(:,i)=cellfun(@(x) [spc(ones(1,mfmt(i)-numel(x))),x],tt(:,i),'uni',false);
	end
	end

		z=spc(ones([1,mfmt(2)]));
	if	par.hasopt.cla
		t(ixr)=cellfun(@(x) [x,spc(ones(1,mfmt(1)-numel(x)))],t(ixr),'uni',false);
	else
		t(ixr)=cellfun(@(x) [spc(ones(1,mfmt(1)-numel(x))),x],t(ixr),'uni',false);
	end
		t(ixr)=cellfun(@(x) [x,par.opt.cd,z],t(ixr),'uni',false);
		t(ixc)=cellfun(@(x,y) [x,par.opt.cd,y],tt(:,1),tt(:,2),'uni',false);
		par.in(ixc)=false;
		par.sconv=paro.sconv;
	end
	end
end
%-------------------------------------------------------------------------------
function	[t,par]=CPRINTF_cell(par,t,ix,fmt)

	if	isempty(ix)
		return;
	else
		ix=ix(:).';
	end

		fmtc=class(fmt);

	switch	par.nmod
% full numbers
	case	1
		switch	fmtc
		case	'char'
		for	i=ix
      if isnumeric(t{i}) && t{i}==0, t{i}=0;end
			t{i}=sprintf(fmt,t{i});
		end
		case	'function_handle'
		for	i=ix
			t{i}=fmt(t{i});
		end
		otherwise
			error('%s> invalid format %s',par.magic,upper(fmtc));
		end
% sparse numbers
	case	2
			nx=numel(ix)/2;
		switch	fmtc
		case	'char'
		for	i=1:nx
			ca=ix(i);
			cb=ix(i+nx);
			t{ca}=sprintf(fmt,t{ca},t{cb});
		end
		case	'function_handle'
		for	i=1:nx
			ca=ix(i);
			cb=ix(i+nx);
			t{ca}=fmt(t{ca},t{cb});
		end
		otherwise
			error('%s> invalid format %s',par.magic,upper(fmtc));
		end
% other data types
	case	3
		for	i=ix
			res=fmt(t{i});
		if	par.hasopt.Or
			res=res(3:end-1);
		end
			t{i}=res;
		end
	otherwise
		error('%s> invalid print mode %d',par.magic,par.nmod);
	end

% reset flag to NUMBERS
		par.nmod=1;
% update counters
		par.in(ix)=false;
		par.sconv=par.sconv+numel(ix);
end
%-------------------------------------------------------------------------------
%		file io routines
%-------------------------------------------------------------------------------
function	varargout=CPRINTF_ascii2file(varargin)

% MACRO call
% NOTE:	table mode turned off by default
%	quiet mode turned on  by default

	if	nargout
		[varargout{1:nargout}]={[]};
	end
	if	nargin > 1
		opt=CPRINTF_parse_option(0,varargin{2:end});
	if	isfield(opt,'fc')			||...
		isfield(opt,'fa')
		[varargout{1:nargout}]=cprintf(varargin{1},'-mt',0,'-q',1,varargin{2:end});
		return;
	end
	end
		disp('CPRINTF.write> must have a [-fc] or [-fa] option/value pair');
end
%-------------------------------------------------------------------------------
function	[ctbl,par]=CPRINTF_write(par,ctbl)

	if	~par.hasopt.fa				&&...
		~par.hasopt.fc
		return;
	end

		odisp=par.disp;
	if	par.hasopt.q
		par.disp=@CPRINTF_nodisp;
	else
		par.disp=@CPRINTF_disp;
	end

% writing mode
		fout=[];
	if	par.hasopt.fc
		wmod='wt';
		wspec='create';
		fout=par.opt.fc;
	end
	if	par.hasopt.fa
		wmod='at';
		wspec='append';
		fout=par.opt.fa;
	end
	if	isempty(fout)
		par.disp('CP| no name   : %10s   %s',' ','[-fc] and [-fa] options empty');
		return;
	end

% check
% - token replacement
% - file  insertion
	if	par.hasopt.fi

		[fp,emsg]=fopen(par.opt.fi,'rt');
	if	fp < 0
		error('%s> cannot access input file %s\n%s',par.magic,par.opt.fi,emsg);
	end

%   faster than textread/textscan
		[otxt,nchar]=fread(fp,'*char');
		fclose(fp);
	if	nchar
		otxt=strread(otxt.','%s','delimiter','\n','whitespace','');
	else
		otxt='';
	end

	if	par.hasopt.fr
		ntxt=regexprep(otxt,par.opt.fr(:,1:2:end),par.opt.fr(:,2:2:end));
	else
		ntxt=otxt;
	end

	if	par.hasopt.fm
		ix=regexp(ntxt,par.opt.fm);
		ic=cellfun(@(x) all(~isempty(x)&&x==1),ix);
	if	any(ic)
		wmod='wt';
		wspec='create';
		ic=find(ic,1,'first');
		ntxt(ic)={ctbl};
	elseif	par.hasopt.fa
		wmod='at';
		ntxt=[ntxt;{ctbl}];
	else
		error('%s> marker %s not found in file template %s',par.magic,par.opt.fm,par.opt.fi);
	end
	end

		par.disp('CP| template  : %10s   %s',' ',par.opt.fi);
	else
		ntxt={ctbl};
	end

% write/append output file
	if	~isempty(ntxt)
		ntxt=char(ntxt);
		nspc=size(ntxt,1);
		ntxt=[ntxt,repmat(sprintf('\n'),nspc,1)];

		[fp,msg]=fopen(fout,wmod);
	if	fp > 0
		r=fwrite(fp,ntxt.','char');
		fclose(fp);
		par.disp('CP| %8s  : %10d b %s',wspec,r+nspc,fout);
	else
		error('%s> cannot write/append file %s\n%s',par.magic,fout,msg);
	end
	end

		par.disp(' ');
		par.disp=odisp;
end
%-------------------------------------------------------------------------------
function	[res,copt]=CPRINTF_ini2opt(par,varargin)

		mflg=false;
		copt=par;

	if	~isstruct(par)
		mflg=true;
		par=cprintf;
		par=CPRINTF_parse_option(par,varargin{:});
	end

		odisp=par.disp;
	if	par.hasopt.q
		par.disp=@CPRINTF_nodisp;
	else
		par.disp=@CPRINTF_disp;
	end

		narg=numel(varargin);
	if	narg < 1				||...
		isempty(varargin{1})			||...
		~ischar(varargin{1})
	if	nargout
		res.nop=true;
		copt.nop=false;
	end
		return;
	end

% file id
		ihdr=sprintf('%%%s\toption file',par.magic);
		ilen=numel(ihdr);
		isec=sprintf('%%%%%%\tsection ----------- %s ---------- user data',par.magic);
		nopt=3;
% rex engine
		rex='(?<=(''-))[^-\d+]\w*(?!=,)';
		id=sprintf('tcp_%s',num2hex(rand(1,3)).');
		idc='''-''';

		fnam=which(varargin{1});
	if	~exist(fnam,'file')
		error('%s> ini file not found %s',par.magic,fnam);
	end

	if	narg > 1				&&...
		~isempty(varargin{2})			&&...
		ischar(varargin{2})
		kflg=true;
		fini=varargin{2};
		fout=fini;
		[fini,fini]=fileparts(fini);
	else
		kflg=false;
		fini=id;
		fout='temporary file removed';
	end
		fini=sprintf('%s.m',fini);

		[fp,msg]=fopen(fnam,'rt');
	if	fp < 0
		error('%s> cannot open ini file %s\n',par.magic,fnam,msg);
	end
		d=fread(fp,inf,'uint8=>char');
		fclose(fp);
		d=d(:).';

	if	strncmp(d,ihdr,ilen) == 1
% old ini file
		[topt,par]=CPRINTF_readini(par,fnam);
		nent=numel(fieldnames(topt))-nopt;

		fold=sscanf(d(ilen+2:end),'%[^\n]');
		d=strread(d,'%s','delimiter','\n','whitespace','');
		ix=find(strcmp(d,isec));
	if	numel(ix) < 2
		error('%s> invalid ini file %s',par.magic,fnam);
	end
		par.disp('CP| header    : %10s   %s',' ',fold);
		par.disp('CP| file      : %10d   %s',nent,fnam);
		res=d(ix(1)+1:ix(2)-1);

	else
% new ini file
		par.disp('CP| file      : %10s   %s',' ',fnam);

		d=strrep(d,idc,id);
		d=regexprep(d,'(\s*,\s*)',',');
		d=regexprep(d,'(\s*;\s*)',';');
		d=regexprep(d,',{2,}',',');

		[ftok,fbeg,fend]=regexp(d,rex,'match','start','end');
	if	isempty(ftok)
		error('%s> no options found in %s',par.magic,fnam);
	end
		fend(end+1)=nan;
		fbeg(end+1)=numel(d)+3;
		ntok=numel(fend)-1;
		ctok=cell(ntok,1);

	for	i=1:ntok
		stok=d(fend(i)+3:fbeg(i+1)-3);
	if	isempty(stok)
		stok='[]';
	else
		stok=regexprep(stok,'(\n+$)','');
		stok=regexprep(stok,'[,;]+$','');
	end
		ctok(i)={stok};
	end
		ctok=strrep(ctok,id,idc);

% add ID
		ftok=[
			'magic'
			'ver'
			'MLver'
			ftok.'
		];
		ctok=[
			{
			sprintf('''%s''',par.magic)
			sprintf('''%s''',par.ver)
			sprintf('''%s''',version)
			}
			ctok
		];

		nent=numel(unique(ftok))-nopt;
		ns=max([2;cellfun(@numel,ftok)]);
		fmt=sprintf('\\to.%%%d.%ds = %%s;',ns,ns);
		res=cellfun(@(x,y) sprintf(fmt,x,y),ftok,ctok,'uni',false);
	end

% create INI file
		hdr={
		sprintf('%s %s',ihdr,fini)
		sprintf('%%version	%s',par.ver)
		sprintf('%%created	%s',datestr(clock))
		sprintf('%%options	%-1d unique/user defined',nent)
		sprintf('%%')
		sprintf('%%SYNTAX		opt = %s;',fini)
		sprintf('')
		sprintf('function\to = %s(varargin)\n',fini(1:end-2))
		isec
		};
		ftr={
		isec
		sprintf('end')
		};
		mc=max(cellfun(@numel,hdr(1:8)));
		hdr{7,1}=sprintf(['%%',repmat('-',1,mc-2+8)]);	% 1 TAB

		par.disp('CP| create    : %10s   %s',' ',fout);

		[fp,msg]=fopen(fini,'wt');
	if	fp < 3
		error('%s> cannot create ini file %s',par.magic,fini,msg);
	end
		fprintf(fp,'%s\n',hdr{:});
		fprintf(fp,'%s\n',res{:});
		fprintf(fp,'%s\n',ftr{:});
		fclose(fp);

% read INI file
		[res,par]=CPRINTF_readini(par,fini);
		par.disp('CP| options   : %10d   %s',...
			numel(fieldnames(res))-nopt,'unique/user defined');

% clean up
	if	~kflg
		delete(fini);
	end
	if	~nargout
		clear res;
	elseif	mflg
		copt=CPRINTF_struct2opt(0,res);
	end

		par.disp(' ');
		par.disp=odisp;
end
%-------------------------------------------------------------------------------
function	[res,par]=CPRINTF_readini(par,fini)


		[fpat,frot]=fileparts(fini);
	if	~isempty(fpat)
		ocd=cd(fpat);
	else
		ocd=cd;
	end
		res=feval(frot);
		cd(ocd);

end
%-------------------------------------------------------------------------------
