function colornames_view(palette,order)
% View the COLORNAMES palettes in an interactive figure. Sort colors by name/color space.
%
% (c) 2014-2019 Stephen Cobeldick
%
%%% Syntax:
%  colornames_view
%  colornames_view(palette)
%  colornames_view(palette,sortorder)
%
% Create a figure displaying all of the colors from any palette supported
% by the function COLORNAMES. The palette and sort order can be selected
% by drop-down menu or by optional inputs. The colors can be sorted:
% - alphabetically by color name.
% - by color space parameters: Lab, LCh, XYZ, YUV, HSV, or RGB.
%
% The figure is resizeable (the colors flow to fit the axes) with a vertical
% scrollbar provided to view all of the colors (if required). A rudimentary
% zoom ability has also been implemented... but this is rather experimental!
%
% Note: Requires the function COLORNAMES and its associated MAT file (FEX 48155).
%
%% Input and Output Arguments %%
%
%%% Inputs (all inputs are optional):
%  palette   = CharRowVector, the name of a palette supported by COLORNAMES.
%  sortorder = CharRowVector, the color space sort parameters in the desired order,
%              eg: 'RGB', 'BRG', 'GRB', 'Lab', 'abL', etc, OR 'Alphabetical'.
%
%%% Outputs:
% none
%
% See also COLORNAMES COLORNAMES_CUBE COLORNAMES_DELTAE MAXDISTCOLOR COLORMAP

%% Figure Parameters %%
%
persistent fgh axh slh pah srh txh txs rgb coh prv
%
% Text lightness threshold:
thr = 0.54;
%
% Text margin, uicontrol and axes gap (pixels):
mrg = 5;
gap = 4;
sid = 20;
%
% Slider position:
yid = 0;
ymx = 0;
%
% Handle of outlined text:
prv = [];
%
pmt = 'Click on a colorname...';
%
%% Get COLORNAME Palettes %%
%
[fnm,csf] = colornames();
%
if nargin<1
	pnm = fnm{1+rem(round(now*1e7),numel(fnm))};
else
	assert(ischar(palette)&&isrow(palette),'First input <palette> must be a 1xN char.')
	idz = strcmpi(palette,fnm);
	assert(any(idz),'Palette ''%s'' is not supported. Call COLORNAMES() to list all palettes.',palette)
	pnm = fnm{idz};
end
%
%% Color Sorting List %%
%
% List of color spaces for sorting:
lst = {'Alphabetical','Lab','XYZ','LCh','YUV','HSV','RGB'};
[tsl,idt] = cellfun(@sort,lst,'UniformOutput',false);
% Get every permutation of the color spaces:
trs = cellfun(@(s)perms(s(end:-1:1)),lst(2:end),'UniformOutput',false);
trs = [lst(1);cellstr(vertcat(trs{:}))];
%
if nargin<2
	srt = lst{1};
else
	assert(ischar(order)&&isrow(order),'Second input <sort> must be a 1xN char.')
	idz = strcmpi(order,trs);
	assert(any(idz),'Second input must be one of:%s\b.',sprintf(' %s,',trs{:}))
	srt = trs{idz};
end
%
% Intial color sorting index:
idx = 1:numel(colornames(pnm));
%
%% Create a New Figure %%
%
if isempty(fgh)||~ishghandle(fgh)
	% Figure with zoom and pan functions:
	fgh = figure('HandleVisibility','callback', 'IntegerHandle','off',...
		'NumberTitle','off', 'Name','ColorNames View', 'Color','white',...
		'Toolbar','figure', 'Units','pixels', 'Tag',mfilename, 'Visible','on');
	%
	fgp = get(fgh,'Position');
	inh = uicontrol(fgh, 'Units','pixels', 'Style','text', 'HitTest','off',...
		'Visible','on',	'String','Initializing the figure... please wait.');
	inx = get(inh,'Extent');
	set(inh,'Position',[fgp(3:4)/2-inx(3:4)/2,inx(3:4)])
	%
	% Axes and scrolling slider:
	slh = uicontrol('Parent',fgh, 'Style','slider', 'Visible','off',...
		'Enable','on', 'Value',1, 'Min',0, 'Max',1,...
		'FontUnits','pixels', 'Units','pixels', 'Callback',@cnvSldClBk);
	axh = axes('Parent',fgh, 'Visible','off', 'Units','pixels',...
		'YDir','reverse', 'XTick',[], 'YTick',[], 'XLim',[0,1], 'YLim',[0,1]);
	% Palette and color sorting method drop-down menus:
	pah = uicontrol('Parent',fgh, 'Style','popupmenu', 'String',fnm,...
		'ToolTip','Color Scheme', 'Units','pixels',...
		'Visible','off', 'Callback',@cnvPalClBk);
	srh = uicontrol('Parent',fgh, 'Style','popupmenu', 'String',trs,...
		'ToolTip','Sort Colors', 'Units','pixels',...
		'Visible','off', 'Callback',@cnvSrtClBk);
	coh = uicontrol('Parent',fgh, 'Style','edit', 'String',pmt,...
		'ToolTip','RGB Value',   'Units', 'pixels', 'Visible','off',...
		'HorizontalAlignment','left', 'Enable','inactive');
else
	set(coh,'String',pmt)
end
set(pah,'Value',find(strcmpi(pnm,fnm)));
set(srh,'Value',find(strcmpi(srt,trs)));
%
fgo = get(fgh, 'Pointer');
set(fgh, 'Pointer','watch')
drawnow()
%
%% Callback Functions %%
%
	function cnvPalClBk(h,~) % Palette Menu CallBack
		% Select a new palette.
		pnm = fnm{get(h,'Value')};
		set(slh, 'Value',1)
		set(coh, 'String',pmt)
		set(fgh, 'Pointer','watch')
		drawnow()
		cnvTxtDraw()
		cnvSortBy()
		cnvResize()
		set(fgh, 'Pointer',fgo)
	end
%
	function cnvSrtClBk(h,~) % Sort-Order Menu CallBack
		% Select the color sorting method.
		srt = trs{get(h,'Value')};
		set(fgh, 'Pointer','watch')
		drawnow()
		cnvSortBy()
		cnvResize()
		set(fgh, 'Pointer',fgo)
	end
%
	function cnvSldClBk(h,~) % Slider CallBack
		% Scroll the axes by changing the axes limits.
		tmp = diff(get(axh,'Ylim'));
		set(axh, 'Ylim',[0,tmp] + (ymx-tmp)*(1-get(h,'Value')));
	end
%
	function cnvZoomClBk(~,~) % Zoom CallBack
		% Change the font and margin sizes.
		tmp = diff(get(axh,'Ylim'));
		set(txh, 'FontSize',txs/tmp);
		set(txh, 'Margin',mrg/tmp);
	end
%
	function cnvPanClBk(~,~) % Pan CallBack
		% Move the scroll-bar to match panning of the axes.
		tmp = get(axh,'Ylim');
		set(slh, 'Value',max(0,min(1,1-tmp(1)/(ymx-diff(tmp)))))
	end
%
%% Color Sorting %%
%
	function cnvSortBy()
		[tmp,ids] = sort(srt);
		idc = strcmp(tmp,tsl);
		ids = ids(idt{idc});
		switch lst{idc}
			case 'Alphabetical'
				idx = 1:numel(txh);
				return
			case 'RGB'
				mat = rgb;
			case 'HSV'
				mat = csf.rgb2hsv(rgb);
			case 'XYZ'
				mat = csf.rgb2xyz(rgb);
			case 'Lab'
				mat = csf.xyz2lab(csf.rgb2xyz(rgb));
			case 'LCh'
				mat = csf.lab2lch(csf.xyz2lab(csf.rgb2xyz(rgb)));
			case 'YUV' % BT.709
				mat = csf.invgamma(rgb) * [...
					+0.2126, -0.19991, +0.61500;...
					+0.7152, -0.33609, -0.55861;...
					+0.0722, +0.43600, -0.05639];
			otherwise
				error('Colorspace "%s" is not supported. How did this happen?',srt)
		end
		[~,idx] = sortrows(mat,ids);
	end
%
%% Re/Draw Text Strings %%
%
txf = @(s,b,c)text('Parent',axh, 'String',s, 'BackgroundColor',b,...
	'Color',c,'Margin',mrg, 'Units','data', 'Interpreter','none',...
	'VerticalAlignment','bottom', 'HorizontalAlignment','right',...
	'Clipping','on', 'ButtonDownFcn',{@txtClBk,s,b},'LineWidth',3);
%
	function txtClBk(hnd,~,s,bgd)
		try %#ok<TRYNC>
			set(prv, 'EdgeColor','none')
		end % setting one object is much faster than setting all objects.
		prv = hnd;
		%
		hxs = sprintf('%02X',round(bgd*255));
		dcs = sprintf(',%.5f',bgd);
		set(coh, 'String',sprintf('#%s [%s] %s',hxs,dcs(2:end),s));
		set(hnd, 'EdgeColor',max(0,min(1,1-bgd)))
		uistack(hnd,'top')
	end
%
	function cnvTxtDraw()
		% Delete any existing colors:
		delete(txh(ishghandle(txh)))
		% Get new colors:
		[cnc,rgb] = colornames(pnm);
		% Calculate the text color:
		baw = (rgb*[0.298936;0.587043;0.114021])<thr;
		% Draw new colors in the axes:
		txh = cellfun(txf,cnc,num2cell(rgb,2),num2cell(baw(:,[1,1,1]),2),'Uni',0);
		txh = reshape([txh{:}],[],1);
		txs = get(txh(1),'FontSize');
		prv = txh(1);
	end
%
%% Resize the Axes and UIControls, Move the Colors %%
%
	function cnvResize(~,~)
		%
		zoom(fgh,'out')
		%
		if nargin
			set(fgh, 'Pointer','watch')
			drawnow()
		end
		%
		ecv = get(prv, 'EdgeColor');
		set(prv, 'EdgeColor','none');
		%
		set(axh, 'Ylim',[0,1])
		set(txh, 'Units','pixels', 'FontSize',txs, 'Margin',mrg)
		txe = cell2mat(get(txh(:),'Extent'));
		top = get(slh,'FontSize')*2;
		fgp = get(fgh,'Position'); % [left bottom width height]
		hgt = round(fgp(4)-3*gap-top);
		wid = fgp(3)-3*gap-sid;
		pos = [gap,gap,wid,hgt];
		%
		% Calculate color lengths from text and margins:
		txw = 2*mrg+txe(idx,3);
		txc = cumsum(txw);
		% Preallocate position array:
		txm = mean(txw);
		out = zeros(ceil(1.1*[txc(end)/pos(3),pos(3)/txm]));
		% Split colors into lines that fit the axes width:
		idb = 1;
		idr = 0;
		tmp = 0;
		while idb<=numel(txc)
			idr = idr+1;
			idp = max([idb,find((txc-tmp)<=pos(3),1,'last')]);
			out(idr,1:1+idp-idb) = txc(idb:idp)-tmp;
			tmp = txc(idp);
			idb = idp+1;
		end
		% Calculate X and Y positions for each color:
		[~,txy,txx] = find(out.');
		yid = txy(end);
		txy = txy*(2*mrg+max(txe(idx,4)));
		ymx = txy(end)/pos(4);
		%
		% Resize the scrollbar, adjust scroll steps:
		nwp = [2*gap+wid,gap,sid,hgt];
		if ymx>1
			set(slh, 'Position',nwp, 'Enable','on', 'Value',1,...
				'SliderStep',max(0,min(1,[0.5,2]/(yid*(ymx-1)/ymx))))
		else
			set(slh, 'Position',nwp, 'Enable','off')
		end
		% Resize the axes and drop-down menus:
		set(axh, 'Position',pos)
		uiw = (fgp(3)-gap)/4-gap;
		txw = 2*uiw+gap;
		lhs = gap+(0:2)*(uiw+gap);
		bot = fgp(4)-top-gap;
		set(pah, 'Position',[lhs(1),bot,uiw,top])
		set(srh, 'Position',[lhs(2),bot,uiw,top])
		set(coh, 'Position',[lhs(3),bot,txw,top])
		% Move text strings to the correct positions:
		arrayfun(@(h,x,y)set(h,'Position',[x,y]),txh(idx),txx-mrg,pos(4)-txy+mrg);
		set(txh, 'Units','data')
		%
		set(prv, 'EdgeColor',ecv);
		%
		if nargin
			set(fgh, 'Pointer',fgo)
		end
		drawnow()
	end
%
%% Initialize the Figure %%
%
cnvTxtDraw()
cnvSortBy()
cnvResize()
set([pah,srh,coh,slh], 'Visible','on')
set(fgh, 'Pointer',fgo, 'ResizeFcn',@cnvResize)
set(zoom(fgh), 'ActionPostCallback',@cnvZoomClBk);
set(pan(fgh),  'ActionPostCallback',@cnvPanClBk);
try %#ok<TRYNC>
	delete(inh)
end
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%colornames_view