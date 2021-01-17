function [rgb,ucs,status,RGB,UCS] = maxdistcolor(N,fun,opts,varargin)
% Generate an RGB colormap of maximally distinct colors, using a uniform colorspace.
%
% (c) 2017-2020 Stephen Cobeldick.
%
%%% Syntax:
% rgb = maxdistcolor(N,fun)
% rgb = maxdistcolor(N,fun,opts)
% rgb = maxdistcolor(N,fun,<name-value pairs>)
% [rgb,ucs,status] = maxdistcolor(N,fun,...)
%
% Repeatedly applies a greedy algorithm to search the RGB gamut and
% find the truly maximally distinct set of N colors. Note that requesting
% many colors from a large gamut can require hours/days/.. of processing.
%
%%% Options include:
% * Limit the lightness range of the output colors.
% * Limit the chroma range of the output colors.
% * Colors to be excluded (e.g. background colors).
% * Colors to be included (e.g. corporate colors).
% * Specify a different RGB bit depth (e.g. 8 bits per channel TrueColor).
% * Sort the output colormap (e.g. by hue, lightness, farthest colors, etc.).
%
% If intended for printing then the lightness and chroma ranges must be
% limited to suitable ranges (check the printing device's ICC profile).
%
%% Options %%
%
% The options may be supplied either
% 1) in a scalar structure, or
% 2) as a comma-separated list of name-value pairs.
%
% Field names and string values are case-insensitive. The following field
% names and values are permitted as options (*=default value):
%
% Field  | Permitted  |
% Name:  | Values:    | Description:
% =======|============|====================================================
% Lmin   | 0<=L<=1    | Lightness range limits to exclude light/dark colors.
% Lmax   |            | Scaled so 0==black and 1==white, Lmin=*0, Lmax=*1.
% -------|------------|----------------------------------------------------
% Cmin   | 0<=C<=1    | Chroma range limits to exclude grays and saturated colors.
% Cmax   |            | Scaled so 1==max(gamut chroma), Cmin=*0, Cmax=*1.
% -------|------------|----------------------------------------------------
% inc    | RGB matrix | Mx3 RGB matrix of colors to include, *[] (none).
% -------|------------|----------------------------------------------------
% exc    | RGB matrix | Mx3 RGB matrix of colors to exclude, *[1,1,1] (white).
% -------|------------|----------------------------------------------------
% disp   | 'off'    * | Does not print to the command window.
%        | 'time'     | Print the time required to complete the function.
%        | 'summary'  | Print the status after the completion of main steps.
%        | 'verbose'  | Print the status after every algorithm iteration.
% -------|------------|----------------------------------------------------
% sort   | 'none'   * | The output matrices are not sorted.
%        | 'farthest' | The next color is farthest from the current color.
%        | 'lightness'| Sorted by the lightness value L or J, i.e. ucs(:,1).
%        | 'a' or 'b' | Sorted by the a or b value, i.e. ucs(:,2) or ucs(:,3).
%        | 'hue'      | Sorted by hue, the angle calculated from ucs(:,2:3).
%        | 'zip'      | Sorted by hue, then zip together alternating elements.
%        | 'maxmin'   | Maximize the minimum adjacent color difference. See Note1.
%        | 'minmax'   | Minimize the maximum adjacent color difference. See Note1.
%        | 'longest'  | The longest path joining all color nodes.       See Note1.
%        | 'shortest' | The shortest path joining all color nodes.      See Note1.
% -------|------------|----------------------------------------------------
% path   | 'open'   * | <sort> options 'maxmin', 'minmax', 'longest', & 'shortest':
%        | 'closed'   | select if the path forms a closed loop through all colors.
% -------|------------|----------------------------------------------------
% start  | 0<=A<=360  | Start angle for <sort> options 'hue' & 'zip', *0.
% -------|------------|----------------------------------------------------
% bitR   | 1<=R<=53   | RGB colorspace bits for   Red channel, *6. See Note2.
% bitG   | 1<=G<=53   | RGB colorspace bits for Green channel, *7. See Note2.
% bitB   | 1<=B<=53   | RGB colorspace bits for  Blue channel, *6. See Note2.
% -------|------------|----------------------------------------------------
%
% Note1: These algorithms use an exhaustive search which generates all row
%        permutations of the colormap, an error is thrown for N greater than 9.
% Note2: Using 8 bits per channel requires 64 bit MATLAB with atleast 8 GB RAM.
%        A smaller number of bits gives a smaller RGB gamut (faster), but the
%        greedy algorithm can fail to work for smaller RGB gamuts: user beware!
%
%% Examples %%
%
% >> N = 5;
% >> fun = @(m)sRGB_to_OSAUCS(m,true,true); % recommended OSA-UCS
% >> rgb = maxdistcolor(N,fun)
% rgb =
%     1.0000         0    1.0000
%          0         0    1.0000
%     0.3016         0    0.3492
%     1.0000         0         0
%          0    0.4331         0
% >> axes('ColorOrder',rgb, 'NextPlot','replacechildren')
% >> X = linspace(0,pi*3,1000);
% >> Y = bsxfun(@(x,n)n*sin(x+2*n*pi/N), X(:), 1:N);
% >> plot(X,Y, 'linewidth',4)
%
% >> maxdistcolor(5,fun, 'exc',[0,0,0]) % Exclude black (e.g. background).
% ans =
%     1.0000         0    1.0000
%          0         0    1.0000
%          0    1.0000         0
%     1.0000    0.0315         0
%     0.7619    0.8189    1.0000
%
% >> maxdistcolor(5,fun, 'inc',[1,0,1]) % Include magenta.
% ans =
%     1.0000         0    1.0000 % magenta
%          0         0    1.0000
%     0.3016         0    0.3492
%     1.0000         0         0
%          0    0.4331         0
%
% >> [rgb,Lab] = maxdistcolor(6,@sRGB_to_CIELab, 'Lmin',0.5, 'Lmax',0.7)
% rgb =
%     0.7619         0    1.0000
%     1.0000         0         0
%          0    0.7795         0
%          0    0.5591    1.0000
%     0.8254    0.6457    0.0794
%     0.8254    0.2835    0.5397
% Lab =
%    50.3682   89.7713  -77.4020
%    53.2408   80.0925   67.2032
%    69.9953  -71.4448   68.9550
%    58.7226    9.8163  -64.4545
%    69.9008    5.1696   70.3753
%    52.1421   59.8639   -6.6541
%
%% Input and Output Arguments %%
%
%%% Inputs:
%  N    = Numeric Scalar, the required number of output colors.
%  fun  = Function Handle, a function to convert from RGB to a uniform colorspace.
%         The function must accept an Nx3 RGB matrix with values 0<=RGB<=1, and
%         return an Nx3 matrix in a uniform colorspace (UCS), where the columns
%         represent some version of [lightness,a,b], e.g. [L*,a*,b*] or [J',a',b'].
%  opts = Structure Scalar, with optional fields and values as per 'Options' above.
%  OR
%  <name-value pairs> = a comma-separated list of field names and associated values.
%
%%% Outputs:
%  rgb = Numeric Matrix, size Nx3, the colors in RGB, where 0<=rgb<=1.
%  ucs = Numeric Matrix, size Nx3, the colors in the uniform colorspace.
%  status = Scalar Structure of greedy algorithm status information.
%
% See also MAXDISTCOLOR_VIEW MAXDISTCOLOR_DEMO SRGB_TO_OSAUCS SRGB_TO_CIELAB
% SRGB_TO_CAM02UCS COLORNAMES COLORMAP RGBPLOT AXES SET LINES PLOT

%% Input Wrangling %%
%
tbe = now();
%
assert(isnumeric(N)&&isscalar(N),...
	'SC:maxdistcolor:N:NotNumericScalar',...
	'First input <N> must be a numeric scalar.')
assert(isfinite(N)&&N>=0,...
	'SC:maxdistcolor:N:NotPositiveFinite',...
	'First input <N> must be a finite positive value. Input: %g',N)
assert(isreal(N),...
	'SC:maxdistcolor:N:ComplexValue',...
	'First input <N> cannot be a complex value. Input: %g%+gi',N,imag(N))
%
assert(isa(fun,'function_handle'),...
	'SC:maxdistcolor:fun:NotFunctionHandle',...
	'Second input <fun> must be a function handle.')
map = fun([0,0,0;1,1,1]);
assert(isfloat(map),...
	'SC:maxdistcolor:fun:OutputNotNumericArray',...
	'Second input <fun> must return a floating-point matrix.')
assert(isequal(size(map),2:3),...
	'SC:maxdistcolor:fun:OutputInvalidSize',...
	'Second input <fun> output matrix has an incorrect size.')
assert(all(isfinite(map(:))),...
	'SC:maxdistcolor:fun:OutputNotFiniteValue',...
	'Second input <fun> output matrix values must be finite.')
assert(isreal(map),...
	'SC:maxdistcolor:fun:OutputComplexValue',...
	'Second input <fun> output matrix values cannot be complex.')
%
% Default option values:
stpo = struct('start',0, 'Cmin',0, 'Cmax',1, 'Lmin',0, 'Lmax',1, 'class','double',...
	'exc',[1,1,1], 'inc',[], 'sort','none', 'path','open', 'disp','off',...
	'bitR',6, 'bitG',7, 'bitB',6); % -> work on 32 bit MATLAB, 8bit -> better quality.
%
% Check any user-supplied option fields and values:
if nargin==3
	assert(isstruct(opts)&&isscalar(opts),...
		'SC:maxdistcolor:opts:NotScalarStruct',...
		'When calling with three inputs, the third input <opts> must be a scalar structure.')
	opts = mdcOptions(stpo,opts);
elseif nargin>3 % options as <name-value> pairs
	opts = struct(opts,varargin{:});
	assert(isscalar(opts),...
		'SC:maxdistcolor:opts:CellArrayValue',...
		'Invalid <name-value> pairs: cell array values are not permitted.')
	opts = mdcOptions(stpo,opts);
else
	opts = stpo;
end
stpo = opts;
%
assert(stpo.Lmax>stpo.Lmin,...
	'SC:maxdistcolor:LmaxLessThanLmin',...
	'The value Lmax must be greater than the value Lmin.')
assert(stpo.Cmax>stpo.Cmin,...
	'SC:maxdistcolor:CmaxLessThanCmin',...
	'The value Cmax must be greater than the value Cmin.')
%
%% Generate RGB and UCS Arrays %%
%
stpo.ohm = pow2([stpo.bitR,stpo.bitG,stpo.bitB])-1; % e.g. 8 bits -> 255.
stpo.cyc = strcmp('closed',stpo.path); % closed/open -> true/false.
stpo.mfn = mfilename(); % display: off/time/summary/verbose -> 0/1/2/3.
[~,stpo.tsv] = ismember(stpo.disp,{'time','summary','verbose'});
%
mdcDisplay(stpo,2,'Starting defining the color gamut...')
%
[RGB,UCS] = mdcAllRgb(stpo,fun);
%
% Get user supplied RGB colormaps:
[exc,cxe] = mdcMapMat(stpo,fun,'exc');
[inc,cni] = mdcMapMat(stpo,fun,'inc');
%
assert(size(intersect(exc,inc,'rows'),1)==0,...
	'SC:maxdistcolor:ExcIncOverlap',...
	'Options <exc> and <inc> must not contain the same RGB values')
%
cnt = 0;
nmg = 0+size(RGB,1); % number of color nodes in the RGB gamut.
nmt = N+size(exc,1); % number of color nodes to test (N + excluded colors).
nmf = N-size(inc,1); % number of color nodes to find (N - included colors).
%
dgt = 1+fix(log10(nmf));
%
mdcDisplay(stpo,2,'Finished defining the color gamut (%d colors).',nmg)
%
%% Greedy Algorithm %%
%
if nmf==0
	rgb = inc;
	ucs = cni;
elseif nmf>0
	fmt = ['The specified RGB gamut contains fewer color nodes than the\n',...
		'requested number of colors. This can be avoided in several ways:\n',...
		'* request fewer colors <N> (now: %d),\n',...
		'* decrease the number of <exc> colors (now: %d),\n',...
		'* increase the difference between <Cmax> and <Cmin>,\n',...
		'* increase the difference between <Lmax> and <Lmin>,\n',...
		'* increase the number of bits for any color channel.'];
	assert(nmt<=nmg,'SC:maxdistcolor:GamutTooSmall',fmt,N,size(exc,1))
	%
	idz = zeros(nmf,1);
	win = zeros(nmf,3);
	chk = zeros(nmf,nmf);
	%
	win = [win;cxe;cni];
	%
	mdcDisplay(stpo,2,'Starting the greedy algorithm...')
	%
	%dwn = nmt;
	vec = Inf;
	mxi = Inf;
	err = true;
	while err && cnt<=mxi
		row = 1+mod(cnt,nmf);
		cnt = 1+cnt;
		vec(:) = Inf;
		% Distance between all color nodes (except for the one being moved):
		for k = [1:row-1,row+1:nmt]
			%vec = min(vec,sum(bsxfun(@minus,ucs,win(k,:)).^2,2));
			vec = min(vec,... maybe uses less memory:
				(UCS(:,1)-win(k,1)).^2 + ...
				(UCS(:,2)-win(k,2)).^2 + ...
				(UCS(:,3)-win(k,3)).^2);
		end
		% Move that color node to the farthest point from the other nodes:
		[~,idr]    = max(vec);   % farthest point.
		win(row,:) = UCS(idr,:); % move node.
		idz(row,:) = idr; % Save the index.
		chk(row,:) = idz; % Save the index.
		% Check if any color nodes have changed index:
		tmp = any(diff(chk,1,1),1);
		err = any(tmp);
		%
		%dwn = max(dwn-~err,dwn*err);
		%
		% Display:
		if stpo.tsv>=3
			fprintf('%s: %*d %6d/%d %#9.7g  %s\n', stpo.mfn,...
				dgt, row, cnt, mxi, mdcClosest(win), sprintf('%d',tmp))
		end
	end
	%
	rgb = [inc;RGB(idz,:)];
	ucs = [cni;UCS(idz,:)];
	%
	mdcDisplay(stpo,2,'Finished the greedy algorithm (%i iterations).',cnt)
	%
else
	error('SC:maxdistcolor:IncMoreColorsThanN',...
		'Not enough colors requested: option <inc> must have <N> or fewer rows.')
end
%
%% Sort %%
%
mdcDisplay(stpo,2,'Starting to sort the colormap...')
%
switch lower(stpo.sort)
	case 'none'
		ids = 1:N;
	case 'maxmin'
		ids = mdcBestPerm(ucs,N, stpo, @(v)-min(v));
	case 'minmax'
		ids = mdcBestPerm(ucs,N, stpo, @(v)+max(v));
	case 'longest'
		ids = mdcBestPerm(ucs,N, stpo, @(v)-sum(v));
	case 'shortest'
		ids = mdcBestPerm(ucs,N, stpo, @(v)+sum(v));
	case 'farthest'
		ids = mdcFarthest(ucs,N);
	case 'lightness'
		[~,ids] = sortrows(ucs,1);
	case 'a'
		[~,ids] = sortrows(ucs,2);
	case 'b'
		[~,ids] = sortrows(ucs,3);
	case 'hue'
		[~,ids] = sort(mdcAtan2D(ucs(:,3),ucs(:,2),stpo.start));
	case 'zip'
		[~,ids] = sort(mdcAtan2D(ucs(:,3),ucs(:,2),stpo.start));
		ids([1:2:N,2:2:N]) = ids;
	otherwise
		error('SC:maxdistcolor:sort:UnknownOption',...
			'This <sort> option is not supported: %s',typ)
end
%
rgb = rgb(ids,:);
ucs = ucs(ids,:);
%
mdcDisplay(stpo,2,'Finished sorting the colormap (''%s'' order).',stpo.sort)
%
%% Status and Time %%
%
toa = (now()-tbe)*24*60*60;
%
if nargout>2
	status = struct();
	status.seconds = toa;
	status.options = opts;
	status.gamutSize = nmg;
	status.iterations = cnt;
	status.minDistOutput = mdcClosest(ucs);
	status.minDistAndExc = mdcClosest(win);
	status.minDistNotInc = mdcClosest(UCS(idz,:));
end
%
if ~stpo.tsv
	return
end
%
spl = nan(1,4);
dpf = 100;
toa = ceil(toa*dpf)/dpf;
spl(4) = mod(toa,60); % seconds
toa    = fix(toa/60);
spl(3) = mod(toa,60); % minutes
toa    = fix(toa/60);
spl(2) = mod(toa,24); % hours
toa    = fix(toa/24);
spl(1) =     toa    ; % days
idt = spl~=0 | [false(1,3),~any(spl)];
idp = spl~=1 & idt;
fmt = {' %d day',' %d hour',' %d minute',' %g second';'s','s','s','s'};
str = sprintf([fmt{[idt;idp]}],spl(idt));
%
fprintf('%s: Finished everything in%s.\n',stpo.mfn,str);
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%maxdistcolor
function stpo = mdcOptions(stpo,opts)
% Options check: only supported fieldnames with suitable option values.
%
opts = orderfields(opts);
stpo = orderfields(stpo);
ufc = fieldnames(opts);
dfc = fieldnames(stpo);
uvc = struct2cell(opts);
%
idf = ~cellfun(@(f)any(strcmpi(f,dfc)),ufc);
if any(idf)
	ufn = sprintf(' ''%s'',',ufc{idf});
	dfn = sprintf(' ''%s'',',dfc{:});
	error('SC:maxdistcolor:opts:UnknownOption',...
		'Unknown option:%s\b.\nKey/field names must be:%s\b.',ufn,dfn)
end
%
% Colormap options:
mdcChkRGB('exc');
mdcChkRGB('inc');
%
% Integer options:
mdcChkVal('bitR',false, 1,53); % flintmax
mdcChkVal('bitG',false, 1,53); % flintmax
mdcChkVal('bitB',false, 1,53); % flintmax
%
% Float options:
mdcChkVal('Cmin',true, 0,1);
mdcChkVal('Cmax',true, 0,1);
mdcChkVal('Lmin',true, 0,1);
mdcChkVal('Lmax',true, 0,1);
mdcChkVal('start',true, 0,360);
%
% String options:
mdcChkStr('class','single','double');
mdcChkStr('disp','off','time','summary','verbose');
mdcChkStr('path','open','closed');
mdcChkStr('sort','none',...
	'maxmin','minmax','longest','shortest',...
	'farthest','hue','zip','lightness','a','b');
%
	function idx = mdcField(fld)
		% Options check: throw error for duplicate fieldnames.
		idx = strcmpi(fld,ufc);
		assert(nnz(idx)<2,'SC:maxdistcolor:opts:DuplicateOption',...
			'Duplicate key/field names:%s\b.',sprintf(' ''%s'',',ufc{idx}))
	end
	function mdcChkRGB(fld)
		% Options check: numeric colormap, size Nx3.
		idx = mdcField(fld);
		if any(idx)
			map = uvc{idx};
			S = size(map);
			assert(isnumeric(map),...
				'SC:maxdistcolor:map:NotNumeric',...
				'The <%s> input must be a numeric matrix.',fld)
			assert(numel(S)==2,...
				'SC:maxdistcolor:map:NotMatrix',...
				'The <%s> input must be a numeric matrix ',fld)
			assert(S(2)==3||all(S==0),...
				'SC:maxdistcolor:map:InvalidSize',...
				'The <%s> input must be empty or have size Nx3.',fld)
			assert(all(isfinite(map(:))),...
				'SC:maxdistcolor:map:NotFiniteValue',...
				'The <%s> RGB values must be finite.',fld)
			assert(isreal(map),...
				'SC:maxdistcolor:map:ComplexValue',...
				'The <%s> RGB values cannot be complex.',fld)
			stpo.(fld) = map;
		end
	end
	function mdcChkVal(fld,isf,minV,maxV)
		% Options check: scalar numeric value.
		idx = mdcField(fld);
		if any(idx)
			val = uvc{idx};
			assert(isnumeric(val),...
				'SC:maxdistcolor:val:NotNumeric',...
				'The <%s> input must be numeric. Class: %s',fld,class(val))
			assert(isscalar(val),...
				'SC:maxdistcolor:val:NotScalar',...
				'The <%s> input must be scalar. Numel: %d',fld,numel(val))
			assert(imag(val)==0,...
				'SC:maxdistcolor:val:ComplexValue',...
				'The <%s> value cannot be complex. Input: %g%+gi',fld,val,imag(val))
			assert(isf||(fix(val)==val),...
				'SC:maxdistcolor:val:NotInteger',...
				'The <%s> value must be integer. Input: %g',fld,val)
			assert(val>=minV,...
				'SC:maxdistcolor:val:AboveRange',...
				'The <%s> value must be >=%g. Input: %g',fld,minV,val)
			assert(val<=maxV,...
				'SC:maxdistcolor:val:BelowRange',...
				'The <%s> value must be <=%g. Input: %g',fld,maxV,val)
			stpo.(fld) = double(val);
		end
	end
	function mdcChkStr(fld,varargin)
		% Options check: character row vector.
		idx = mdcField(fld);
		if any(idx)
			tmp = uvc{idx};
			if ~(ischar(tmp)&&isrow(tmp)&&any(strcmpi(tmp,varargin)))
				error('SC:maxdistcolor:str:NotInList',...
					'The <%s> value must be one of:%s',fld,sprintf(' ''%s'',',varargin{:}));
			end
			stpo.(fld) = lower(tmp);
		end
	end
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%mdcOptions
function mdcDisplay(stpo,val,fmt,varargin)
% Display text in the command window.
if stpo.tsv>=val
	fprintf('%s: %s\n',stpo.mfn,sprintf(fmt,varargin{:}))
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%mdcDisplay
function [RGB,UCS] = mdcAllRgb(stpo,fun)
% Generate RGB gamut, and convert to UCS. Select by lightness & chroma.
%
mdcDisplay(stpo,3,'Creating the entire RGB cube...')
% Generate all RGB colors in the RGB gamut:
[R,G,B] = ndgrid(...
	cast(0:stpo.ohm(1),stpo.class),...
	cast(0:stpo.ohm(2),stpo.class),...
	cast(0:stpo.ohm(3),stpo.class));
RGB = bsxfun(@rdivide,[R(:),G(:),B(:)],stpo.ohm);
clear R G B
mdcDisplay(stpo,2,'Created the entire RGB cube (%d colors).',size(RGB,1))
% Convert to uniform colorspace (e.g. L*a*b* or J'a'b'):
mdcDisplay(stpo,3,'Converting from RGB to UCS (call external function)...')
UCS = fun(RGB);
% Identify lightness and chroma values within the requested ranges:
mdcDisplay(stpo,3,'Subsample RGB gamut using lightness and chroma...')
tmp = fun([0,0,0;1,1,1]);
lim = interp1([0;1],tmp(:,1),[stpo.Lmin;stpo.Lmax]);
chr = sqrt(sum(UCS(:,2:3).^2,2));
chr = chr ./ max(chr);
idk = UCS(:,1)>=lim(1) & UCS(:,1)<=lim(2) & chr>=stpo.Cmin & chr<=stpo.Cmax;
% Select only the colors with the required lightness and chroma ranges:
RGB = RGB(idk,:);
UCS = UCS(idk,:);
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%mdcAllRgb
function [rgb,ucs] = mdcMapMat(stpo,fun,fld)
% Check user-supplied include/exclude RGB colormap, convert to UCS.
%
rgb = stpo.(fld);
fmt = 'Input <%s> %s values must be %s';
%
if isempty(rgb)
	rgb = nan(0,3,stpo.class);
elseif isfloat(rgb)
	assert(all(0<=rgb(:)&rgb(:)<=1),...
		'SC:maxdistcolor:map:OutOfRange_FloatingPoint',...
		fmt,fld,'floating point','0<=rgb<=1')
	rgb = cast(rgb,stpo.class);
else
	assert(all(all(0<=rgb&bsxfun(@le,rgb,stpo.ohm))),...
		'SC:maxdistcolor:map:OutOfRange_Integer',...
		fmt,fld,'integer',sprintf('0<=Red<=%d, 0<=Green<=%d, 0<=Blue<=%d',stpo.ohm))
	rgb = bsxfun(@rdivide,cast(rgb,stpo.class),stpo.ohm);
end
ucs = fun(rgb);
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%mdcMapMat
function ang = mdcAtan2D(Y,X,start)
% ATAN2 with an output in degrees.
%
ang = mod(360*atan2(Y,X)/(2*pi)-start,360);
ang(Y==0 & X==0) = 0;
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%mdcAtan2D
function idp = mdcBestPerm(ucs,N,stpo,cost)
% Exhaustive search for the permutation that minimizes the cost function.
%
assert(N<10,'SC:maxdistcolor:sort:TooManyPermutations',...
	'<sort> option ''%s'' requires N<10, as it generates all permutations.',stpo.sort)
%
big = prod(1:N);
cyc = stpo.cyc;
tsv = stpo.tsv>=3;
low = cost(sum(diff([ucs;ucs(cyc,:)],1,1).^2,2));
if tsv
	fprintf('%s: %9d/%-9d  %g\n',stpo.mfn,1,big,low)
end
% Generate permutations using Heap's algorithm:
idx = 1:N;
idp = idx;
idc = ones(1,N);
idi = 1;
cnt = 1;
trk = 1;
while idi<=N
	if idc(idi)<idi
		cnt = cnt+1;
		% Swap indices:
		vec = [idc(idi),1];
		tmp = vec(1+mod(idi,2));
		idx([tmp,idi]) = idx([idi,tmp]);
		% Calculate the cost:
		new = cost(sum(diff(ucs([idx,idx(cyc)],:),1,1).^2,2));
		if new<low
			low = new;
			idp = idx;
			trk = cnt;
		end
		if tsv
			fprintf('%s: %9d/%-9d  %g\n',stpo.mfn,cnt,big,low)
		end
		% Prepare next iteration:
		idc(idi) = 1+idc(idi);
		idi      = 1;
	else
		idc(idi) = 1;
		idi      = 1+idi;
	end
end
%
mdcDisplay(stpo,2,'Checked %d permutations (best=%d, metric=%g).',big,trk,low)
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%mdcBestPerm
function idp = mdcFarthest(ucs,N)
% Permutation where the next color is the farthest of the remaining colors.
%
dst = sum(bsxfun(@minus,permute(ucs,[1,3,2]),permute(ucs,[3,1,2])).^2,3);
[~,idx] = max(sum(dst));
idp = [idx,2:N];
for k = 2:N
	vec = dst(:,idx);
	dst(idx,:) = -Inf;
	dst(:,idx) = -Inf;
	[~,idx] = max(vec);
	idp(k) = idx;
end
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%mdcFarthest
function dst = mdcClosest(ucs)
% Distance between the closest pair of colors.
%
dst = Inf;
for k = 2:size(ucs,1)
	idr = 1:k-1;
	dst = min(dst,min(sqrt(...
		(ucs(k,1)-ucs(idr,1)).^2 + ...
		(ucs(k,2)-ucs(idr,2)).^2 + ...
		(ucs(k,3)-ucs(idr,3)).^2)));
end
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%mdcClosest