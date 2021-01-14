function [rgb,ucs,status,RGB,UCS] = maxdistcolor_view(N,fun,varargin)
% Create a figure for interactive generation and display of MAXDISTCOLOR colors.
%
% (c) 2017-2020 Stephen Cobeldick
%
% This function has exactly the same inputs and outputs as MAXDISTCOLOR.
% See MAXDISTCOLOR for descriptions of the required and optional arguments.
%
% See also MAXDISTCOLOR MAXDISTCOLOR_DEMO SRGB_TO_CAM02UCS SRGB_TO_CIELAB
% SRGB_TO_OSAUCS COLORNAMES COLORMAP RGBPLOT AXES SET LINES PLOT

%% New Figure %%
%
figH = figure('Units','pixels', 'ToolBar','figure', 'NumberTitle','off',...
	'HandleVisibility','off', 'Name',mfilename(), 'Visible','on');
figP = get(figH, 'Position');
figY = get(figH, 'Pointer');
set(figH, 'Pointer','watch')
%
iniH = uicontrol(figH, 'Units','pixels', 'Style','text', 'HitTest','off',...
	'Visible','on',	'String','Initializing the figure... please wait.');
iniX = get(iniH,'Extent');
set(iniH,'Position',[figP(3:4)/2-iniX(3:4)/2,iniX(3:4)])
%
drawnow()
%
% First call to check input arguments and define all output arguments:
[bgr,ucs,status,RGB,UCS] = maxdistcolor(N,fun,varargin{:});
%
opts = status.options;
%
inw = true;
ohm = pow2([opts.bitR,opts.bitG,opts.bitB])-1;
%
if isempty(opts.exc)
	opts.exc = nan(0,3);
end
if isempty(opts.inc)
	opts.inc = nan(0,3);
end
%
delete(iniH)
%
%% Parameters %%
%
gap = 7;
% UI colors:
[R,G,B] = ndgrid(0:1/8:1);
smp = [R(:),G(:),B(:)];
clear R G B
txc = [0.7,0.3,0.2];
bgd = [];
fgd = [];
fBackFore(false)
% Slider steps:
bStp = [1,2]; % bits
cStp = [0.005,0.1]; % chroma
lStp = [0.005,0.1]; % lightness
% Number properties:
nRng = [1,64];
nStp = [1,5];
nFun = @(n) max(nRng(1),min(nRng(2),n));
% Table properties:
tTxt = {'exc'; 'inc'};
% Menu properties:
mTxt = {'plot'; 'sort'; 'path'; 'disp'};
mSrt = {{'none','farthest','hue','zip','lightness','a','b'},{'maxmin','minmax','longest','shortest'}};
mStr = {''; [mSrt{:}]; {'open','closed'}; {'off','time','summary','verbose'}};
% Slider properties:
sTxt = {'Cmax'; 'Cmin'; 'Lmax'; 'Lmin'; 'bitR'; 'bitG'; 'bitB'; 'start'};
sInt = [ false;  false;  false;  false;   true;   true;   true;   false];
sRng = [   0,1;    0,1;    0,1;    0,1;    1,8;    1,8;    1,8;   0,360];
sStp = [  cStp;   cStp;   lStp;   lStp;   bStp;   bStp;   bStp;    1,10];
sTwo = [    +1;     -1;     +2;     -2;      0;      0;      0;       0];
sFun = @(n,k) max(sRng(k,1),min(sRng(k,2),n));
sStr = @(x) sprintf('%.4g',round(1000*x)/1000);
% Colorspace axes:
f2s = upper(regexp(func2str(fun),'(?<=_to_)\w+','match','once'));
tmp = struct('CAM02UCS',{'J''','a''','b'''}, 'CIELAB',{'L*','a*','b*'},...
	'DIN99',{'L_{99}','a_{99}','b_{99}'}, 'OSAUCS',{'L','j','g'});
if isfield(tmp,f2s)
	zyx = {tmp.(f2s)};
else
	zyx = {'L?','a?','b?'};
	f2s = '???';
end
% Maximum chroma:
tmp = fun(smp);
mxc = max(max(abs(tmp(:,2:3))));
%
%% 3D Axes %%
%
az = [];
el = [];
%
%% Interactive Graphics Objects %%
%
% Get text width:
cnc = {'Red','Green','Blue'};
tmp = uicontrol(figH, 'Style','text', 'Units','pixels', 'String',cnc);
txw = get(tmp,'Extent');
txh = txw(4)/numel(cnc);
txw = num2cell(ones(1,3)*(7+txw(3)));
delete(tmp)
% Add drop-down menus:
mTxN = numel(mTxt);
mAxH = axes('Parent',figH, 'Units','pixels', 'Visible','off', 'View',[0,90],...
	'HitTest','off', 'Xlim',[0,1], 'Ylim',[0,2*mTxN]);
mTxH = text(zeros(1,mTxN),2*mTxN-1:-2:1, mTxt, 'parent',mAxH, 'Color',txc,...
	'VerticalAlignment','bottom','HorizontalAlignment','left');
set(mTxH(1),'Color',txc([3,2,1]));
for k = mTxN:-1:1
	if k>1
		idm = find(strcmpi(opts.(mTxt{k}),mStr{k}));
	else
		idm = 1;
	end
	mUiH(k) = uicontrol(figH, 'Style','popupmenu', 'Units','pixels',...
		'String',mStr{k}, 'Callback',{@fOptMenu,k}, 'Value',idm);
end
% Add horizontal sliders:
sTxN = numel(sTxt);
for k = sTxN:-1:1
	val = opts.(sTxt{k});
	sTxH(k) = uicontrol(figH, 'Units','pixels', 'Style','text',...
		'String',sTxt{k}, 'HorizontalAlignment','left', 'ForegroundColor',txc);
	sVaH(k) = uicontrol(figH, 'Units','pixels', 'Style','edit',...
		'String',sStr(val), 'HorizontalAlignment','left', 'Callback',{@fOptEdit,k});
	sUiH(k) = uicontrol(figH, 'Units','pixels', 'Style','slider', 'Value',1,...
		'Min',sRng(k,1), 'Max',sRng(k,2), 'Value',sFun(val,k),...
		'SliderStep',sStp(k,:)./diff(sRng(k,:)), 'Callback',@fUpDtMap);
	addlistener(sUiH(k), 'Value', 'PostSet',@(o,e)fOptSlide(o,e,k));
end
% Add tables:
tTxN = numel(tTxt);
for k = tTxN:-1:1
	tmp = opts.(tTxt{k});
	tmp(end+1:N,:) = NaN;
	tUiH(k) = uitable(figH, 'Units','pixels', 'Data',tmp, 'ColumnWidth',txw,...
		'ColumnName',cnc, 'ColumnEditable',true, 'CellEditCallback',{@fCellEdit,k});
	tTxH(k) = uicontrol(figH, 'Style','text', 'Units','pixels','ForegroundColor',txc,...
		'String',tTxt{k}, 'HorizontalAlignment','left');
	tCbH(k) = uicontrol(figH, 'Style','checkbox', 'Units','pixels','String','X',...
		'Callback',{@fCheckBox,k});
end
% Add colorbar:
bAxH = axes('Parent',figH, 'Units','pixels', 'Visible','off',...
	'HitTest','off', 'Xlim',[0.5,1.4], 'Ylim',[0,N]+0.5, 'View',[0,90],...
	'YDir','normal', 'XTick',[], 'YTick',1:N, 'Box','off');
bImH = image('CData',permute(bgr,[1,3,2]), 'Parent',bAxH);
% Add number slider:
nVaH = uicontrol(figH, 'Units','pixels', 'Style','edit', 'String',sprintf('%d',N),...
	'HorizontalAlignment','center', 'Callback',@fNumEdit);
nUiH = uicontrol(figH, 'Units','pixels', 'Style','slider', 'Value',nFun(N),...
	'Min',nRng(1), 'Max',nRng(2), 'SliderStep',nStp./diff(nRng), 'Callback',@fUpDtMap);
addlistener(nUiH, 'Value', 'PostSet',@fNumSlide);
% Add EVAL button:
eUiH = uicontrol(figH, 'Units','pixels', 'Style','pushbutton',...
	'String','pause', 'ForegroundColor',txc([3,2,1]), 'Callback',@fEvalFun);
eUiX = true;
eUiC = get(eUiH,'BackgroundColor');
%
%% Main Plot Objects %%
%
ndx = 'Colormap Index';
eds = sprintf('Euclidean Distance (%s)',f2s);
%
axp = {'Units','normalized', 'NextPlot','replacechildren', 'Clipping','off',...
	'Color','none', 'XColor',fgd, 'YColor',fgd, 'ZColor',fgd, 'UserData'};
pnp = {figH, 'Units','pixels', 'BorderType','none', 'Title','', 'BackgroundColor',bgd};
%
pAxH(10) = axes('Parent',uipanel(pnp{:}), axp{:},4);
pAxS(10) = struct('title','RGB Gamut (alphashape) [slow]',...
	'X',zyx{3}, 'Y',zyx{2}, 'Z',zyx{1}, 'fun',@fAlphaTry);
%
pAxH(9) = axes('Parent',uipanel(pnp{:}), axp{:},3);
pAxS(9) = struct('title','RGB Gamut (point cloud) [fast]',...
	'X',zyx{3}, 'Y',zyx{2}, 'Z',zyx{1}, 'fun',@fPointCloud);
%
pAxH(8) = axes('Parent',uipanel(pnp{:}), axp{:},3);
pAxS(8) = struct('title','Colors with RGB Cube',...
	'X',zyx{3}, 'Y',zyx{2}, 'Z',zyx{1}, 'fun',@fCubeRGB);
%
pAxH(7) = axes('Parent',uipanel(pnp{:}), axp{:},3);
pAxS(7) = struct('title','Colors with Sort Path',...
	'X',zyx{3}, 'Y',zyx{2}, 'Z',zyx{1}, 'fun',@fSortPath);
%
pAxH(6) = axes('Parent',uipanel(pnp{:}), axp{:},2, 'Visible','off');
pAxS(6) = struct('title','Matrix Scatter Plot',...
	'X','', 'Y','', 'Z','', 'fun',@fScatterMat);
%
pAxH(5) = axes('Parent',uipanel(pnp{:}), axp{:},2);
pAxS(5) = struct('title','Adjacent Color Matrix',...
	'X',ndx, 'Y',ndx, 'Z','', 'fun',@fAdjaNode);
%
pAxH(4) = axes('Parent',uipanel(pnp{:}), axp{:},2, 'XTick',[]);
pAxS(4) = struct('title','Bands with RGB Values',...
	'X','', 'Y',ndx, 'Z','', 'fun',@fRgbValues);
%
pAxH(3) = axes('Parent',uipanel(pnp{:}), axp{:},2, 'XTick',[]);
pAxS(3) = struct('title','Bands with Color Names',...
	'X','', 'Y',ndx, 'Z','', 'fun',@fBandName);
%
pAxH(2) = axes('Parent',uipanel(pnp{:}), axp{:},3);
pAxS(2) = struct('title','Euclidean Distance (3D Plot)',...
	'X',ndx, 'Y',ndx, 'Z',eds, 'fun',@fEuclDist);
%
pAxH(1) = axes('Parent',uipanel(pnp{:}), axp{:},2);
pAxS(1) = struct('title','Euclidean Distance (2D Plot)',...
	'X',ndx, 'Y',eds, 'Z','', 'fun',@fEuclDist);
%
pPnH = get(pAxH,'Parent');
pPnH = [pPnH{:}];
pScH = [];
%
for k = 1:numel(pAxH)
	xlabel(pAxH(k), pAxS(k).X, 'Color',fgd)
	ylabel(pAxH(k), pAxS(k).Y, 'Color',fgd)
	zlabel(pAxH(k), pAxS(k).Z, 'Color',fgd)
	title( pAxH(k), pAxS(k).title, 'Color',fgd, 'Visible','on')
	if get(pAxH(k), 'UserData')>2
		% Axes 3D view:
		view(pAxH(k),3)
		% Zlabel orientation for short strings:
		if numel(pAxS(k).Z)<7
			set(get(pAxH(k), 'ZLabel'), 'Rotation',0, 'HorizontalAlignment','right')
		end
	end
end
%
% Optional linking of 3D axes:
xud = cellfun(@(m)isequal(m,zyx{3}),{pAxS.X});
linkprop(pAxH(xud), 'View');
%
%% Initialize GUI %%
%
rgb2str = @(f,d,m)cellfun(@(v)sprintf(f,v),reshape(num2cell(round(m*d)/d,2),1,[]),'uni',0);
arrayfun(@(s,a) s.fun(a), pAxS, pAxH)
set(pPnH(:), 'Visible','off', 'HitTest','off')
set(pPnH(1), 'Visible','on', 'HitTest','on')
set(mUiH(1), 'String',{pAxS.title})
set(figH, 'Pointer',figY, 'ResizeFcn',@fSizeObj)
fNumTick()
fSizeObj()
%
%% Main Plot Functions %%
%
	function fOrient3D(axh,az,el)
		axis(axh,'equal')
		grid(axh,'on')
		view(axh,az,el)
		mat = fun([0,0,0;1,1,1]);
		set(axh, 'XGrid','on', 'YGrid','on', 'ZGrid','on',...
			'XLim',[-mxc,mxc], 'YLim',[-mxc,mxc], 'ZLim',[mat(1),mat(2)])
	end
%
	function fAlphaTry(~) % ALPHASHAPE is slow, run only on demand.
		plv = get(mUiH(strcmpi('plot',mTxt)), 'Value');
		if eUiX && inw && 4==get(pAxH(plv), 'UserData')
			set(figH, 'Pointer','watch')
			drawnow()
			fAlphaRGB(pAxH(plv))
			set(figH, 'Pointer',figY)
			inw = false;
		end
	end
	function fAlphaRGB(axh) % Show the RGB gamut using alphashape.
		delete(get(axh, 'Children'))
		[az,el] = view(axh);
		% Get gamut boundary:
		nrw = size(UCS,1);
		mxn = 1e4; % max elements for ALPHASHAPE: more elements -> slower runtime.
		stp = ceil(nrw/mxn);
		vec = [];
		for idk = 1:stp
			idu = idk:stp:nrw;
			try
				bnd = fGetBound(idu);
			catch %#ok<CTCH>
				text(0.5, 0.5, 0.5,...
					{'ALPHASHAPE not found','(requires R2014b or later)'},...
					'Parent',axh, 'HorizontalAlignment','center',...
					'FontWeight','bold', 'Color',fgd)
				return
			end
			vec = union(vec,idu(bnd(:)));
		end
		bnd = fGetBound(vec);
		% Show RGB gamut:
		patch('Faces',bnd, 'Vertices',UCS(vec,[3,2,1]), 'Parent',axh,...
			'EdgeColor','none', 'FaceColor','interp', 'FaceVertexCData',RGB(vec,:));
		% Show color nodes:
		hold(axh,'on')
		scatter3(ucs(:,3),ucs(:,2),ucs(:,1), 13, fgd, 'filled', 'Parent',axh)
		% Orient axes:
		fOrient3D(axh,az,el)
	end
	function bnd = fGetBound(idu) % Get boundary of the node cloud.
		shp = alphaShape(UCS(idu,[3,2,1]),Inf); % requires R2014b or later.
		shp.Alpha = shp.criticalAlpha('all-points');
		bnd = shp.boundaryFacets();
	end
%
	function fPointCloud(axh) % Show the RGB gamut using a point cloud.
		delete(get(axh, 'Children'))
		[az,el] = view(axh);
		% Plot point cloud:
		npt = 1e4;
		I = unique(round(linspace(1,size(UCS,1),npt)));
		scatter3(UCS(I,3),UCS(I,2),UCS(I,1), 3, RGB(I,:), 'filled', 'Parent', axh)
		hold(axh,'on')
		scatter3(ucs(:,3),ucs(:,2),ucs(:,1), 13, fgd, 'filled', 'Parent',axh)
		% Orient axes:
		fOrient3D(axh,az,el)
	end
%
	function fSortPath(axh) % Colors shown in UCS space, with path.
		delete(get(axh, 'Children'))
		[az,el] = view(axh);
		% Show color nodes:
		n2s = cellstr(strjust(num2str((1:N).'),'left'));
		scatter3(ucs(:,3),ucs(:,2),ucs(:,1), 256, bgr, 'filled', 'Parent',axh)
		text(ucs(:,3),ucs(:,2),ucs(:,1), n2s, 'Parent',axh,...
			'Color',fgd, 'HorizontalAlignment','center')
		hold(axh,'on')
		% Show path:
		ipc = strcmpi(opts.path,'closed');
		mat = ucs([1:N,1:+ipc],:);
		plot3(mat(:,3),mat(:,2),mat(:,1),'-', 'Parent',axh, 'Color',fgd)
		% Show distances:
		vec = sqrt(sum(diff(mat,1,1).^2,2));
		[mxv,mxi] = max(vec);
		[mnv,mni] = min(vec);
		mxp = mean(mat(mxi:mxi+1,:),1);
		mnp = mean(mat(mni:mni+1,:),1);
		text(mxp(3),mxp(2),mxp(1), sprintf('max:%.5g',mxv), 'Parent',axh, 'Color',fgd)
		text(mnp(3),mnp(2),mnp(1), sprintf('min:%.5g',mnv), 'Parent',axh, 'Color',fgd)
		% Orient axes:
% 		axis(axh,'equal')
% 		view(axh,az,el)
		fOrient3D(axh,az,el)
	end
%
	function fCubeRGB(axh) % Colors shown in UCS space, with RGB cube.
		delete(get(axh, 'Children'))
		[az,el] = view(axh);
		% Show color nodes:
		n2s = cellstr(strjust(num2str((1:N).'),'left'));
		scatter3(ucs(:,3),ucs(:,2),ucs(:,1), 256, bgr, 'filled', 'Parent',axh)
		text(ucs(:,3),ucs(:,2),ucs(:,1), n2s, 'Parent',axh,...
			'Color',fgd, 'HorizontalAlignment','center')
		% Show excluded nodes:
		if isinteger(opts.exc)
			exc = bsxfun(@rdivide,double(opts.exc),ohm);
		else
			exc = opts.exc;
		end
		cxe = fun(exc);
		hold(axh,'on')
		scatter3(cxe(:,3),cxe(:,2),cxe(:,1), 256, exc, 'filled', 'Parent',axh)
		text(cxe(:,3),cxe(:,2),cxe(:,1), 'X', 'Parent',axh,...
			'Color',fgd, 'HorizontalAlignment','center')
		% Show outline of RGB cube:
		M = 23;
		[X,Y,Z] = ndgrid(linspace(0,1,M),0:1,0:1);
		mat = fun([X(:),Y(:),Z(:);Y(:),Z(:),X(:);Z(:),X(:),Y(:)]);
		X = reshape(mat(:,3),M,[]);
		Y = reshape(mat(:,2),M,[]);
		Z = reshape(mat(:,1),M,[]);
		line(X,Y,Z, 'Color',fgd, 'Parent',axh)
		% Orient axes:
% 		axis(axh,'equal')
% 		view(axh,az,el)
		fOrient3D(axh,az,el)
	end
%
	function fScatterMat(axh) % Matrix scatter plot.
		uih = get(axh, 'Parent');
		ise = isempty(pScH);
		for rr = 3:-1:1
			for cc = 3:-1:1
				if ise
					pos = [rr-1,(3-cc)*0.93,1,0.93]./3;
					pScH(rr,cc) = axes('Parent',uih, 'Visible','on',...
						'Units','normalized', 'OuterPosition',pos,...
						'NextPlot','replacechildren',...
						'Color','none', 'XColor',fgd, 'YColor',fgd); %#ok<LAXES>
				else
					delete(get(pScH(rr,cc), 'Children'))
				end
				if rr==cc
					text(0.5,0.5, zyx{rr}, 'Parent',pScH(rr,cc),...
						'FontWeight','bold', 'Color',fgd)
				else
					scatter(pScH(rr,cc), ucs(:,rr),ucs(:,cc), 32, bgr, 'filled');%, 'Parent',axh)
				end
			end
		end
		%set(pScH, 'XLimMode','auto', 'YLimMode','auto')
		set(pScH([1,5,9]), 'XLim',0:1, 'YLim',0:1, 'Visible','off')
		set(pScH, 'XColor',fgd, 'YColor',fgd, 'ZColor',fgd)
	end
%
	function fAdjaNode(axh) % Show matrix with all colors adjacent.
		delete(get(axh, 'Children'))
		[idr,idc] = ndgrid(0:N);
		F = (1:N*(N+1)).';
		F(N+1:N+1:end) = [];
		image('Parent',axh, 'CData',repmat(permute(bgr,[1,3,2]),[1,N,1]));
		patch('Parent',axh, 'Faces',[F,F+N+1,F+N+2], 'Vertices',0.5+[idr(:),idc(:)],...
			'FaceColor','flat', 'FaceVertexCData',bgr(mod(F,N+1),:), 'EdgeColor','none');
	end
%
	function fBandName(axh) % Show bands with colornames (if COLORNAMES is available).
		delete(get(axh, 'Children'))
		image(permute(bgr,[1,3,2]), 'Parent',axh)
		try
			cnm = colornames('CSS',bgr);
		catch %#ok<CTCH>
			cnm = repmat({'COLORNAMES not found: download FEX #48155'},1,N);
		end
		text(ones(1,N), 1:N, cnm, 'Parent',axh, 'Color',fgd,...
			'BackgroundColor',bgd, 'HorizontalAlignment','center')
	end
%
	function fRgbValues(axh) % Show bands with RGB values (floating point and integer).
		delete(get(axh, 'Children'))
		image(permute(bgr,[1,3,2]), 'Parent',axh)
		% Integer:
		cnm = rgb2str('[%d,%d,%d] =',1,bsxfun(@times,bgr,ohm));
		text(ones(1,N), 1:N, cnm, 'Parent',axh, 'Color',fgd,...
			'BackgroundColor',bgd, 'HorizontalAlignment','right')
		% Normalized:
		cnm = rgb2str(' [%.5g,%.5g,%.5g]',1e5,bgr);
		text(ones(1,N), 1:N, cnm, 'Parent',axh, 'Color',fgd,...
			'BackgroundColor',bgd, 'HorizontalAlignment','left')
	end
%
	function fEuclDist(axh) % Show Euclidean distances (2D or 3D).
		delete(get(axh, 'Children'))
		aud = get(axh, 'UserData');
		sgc = {'Parent',axh, 'LineWidth',2.8, 'Marker','o'};
		for idk = 1:N
			dst = sqrt(sum(bsxfun(@minus,ucs,ucs(idk,:)).^2,2));
			switch aud
				case 2
					scatter(1:N, dst, 123, bgr,...
						sgc{:}, 'MarkerFaceColor',bgr(idk,:), 'Parent',axh);
				case 3
					scatter3(idk*ones(1,N), 1:N, dst, 123, bgr,...
						sgc{:}, 'MarkerFaceColor',bgr(idk,:), 'Parent',axh);
				otherwise
					error('SC:maxdistcolor_view:TooManyDimensions',...
						'Sorry, I don''t know how to plot %d dimensions.',aud)
			end
			hold(axh,'on')
		end
		%
		if aud==2
			dst = status.minDistOutput;
			text(N+0.5,dst,sprintf(' %#.5g',dst), 'Parent',axh,...
				'Color',fgd, 'BackgroundColor','none')
		end
	end
%
%% Callback Functions %%
%
	function fEvalFun(obj,~) % Turn evaluation on and off.
		eUiX = ~eUiX;
		if eUiX % eval
			set(obj,'String','pause', 'BackgroundColor',eUiC)
		else % paused
			set(obj,'String','eval', 'BackgroundColor',[1,1,0])
		end
		fUpDtMap()
	end
	function fUpDtMap(~,~) % Update colormap using options structure.
		if eUiX
			% Generate colormap:
			set(figH, 'Pointer','watch')
			drawnow()
			[bgr,ucs,status,RGB,UCS] = maxdistcolor(N,fun,opts);
			set(figH, 'Pointer',figY)
			inw = true;
			ohm = pow2([opts.bitR,opts.bitG,opts.bitB])-1;
			% Update colorbar:
			set(bImH, 'CData',permute(bgr,[1,3,2]))
			% Update main plots:
			arrayfun(@(s,h) s.fun(h), pAxS, pAxH)
		end
	end
%
	function fNumEdit(obj,~) % Number edit box callback.
		str = get(obj, 'String');
		if all(isstrprop(str,'digit')) && sscanf(str,'%d')
			N = sscanf(str,'%d');
			set(nUiH, 'Value',nFun(N))
			fNumTick()
			fUpDtMap()
		else
			set(obj,'String',sprintf('%d',N))
		end
	end
	function fNumSlide(~,evt) % Number slider listener callback.
		try
			N = round(get(evt,'NewValue'));
		catch %#ok<CTCH>
			N = round(evt.AffectedObject.Value);
		end
		set(nVaH, 'String',sprintf('%d',N))
		fNumTick()
	end
	function fNumTick() % Number adjust limits and tickmarks.
		fPermSort()
		% Colorbar limits:
		set(bAxH, 'Ylim',[0,N]+0.5, 'YTick',1:N)
		% Table sizes:
		for idk = 1:tTxN
			new = get(tUiH(idk), 'Data');
			new(end+1:N,:) = NaN;
			new(N+1:end,:) = [];
			set(tUiH(idk), 'Data',new)
		end
		% Main plot axes limits:
		for idk = 1:numel(pAxH)
			for idc = 'XYZ'
				if strcmpi(pAxS(idk).(idc),ndx)
					set(pAxH(idk), [idc,'Lim'],[0,N]+0.5, [idc,'Tick'],1:N);
				end
			end
		end
	end
%
	function fOptEdit(obj,~,idk) % Options edit box callback.
		str = get(obj, 'String');
		new = str2double(str);
		if ~isreal(new) || (sInt(idk) && fix(new)~=new) || new<sRng(idk,1) || new>sRng(idk,2)
			new = NaN;
		end
		if isnan(new)
			set(obj, 'String',sStr(opts.(sTxt{idk})))
		else
			opts.(sTxt{idk}) = new;
			set(sUiH(idk), 'Value',new)
			fUpDtMap()
		end
	end
	function fOptSlide(~,evt,idk) % Options slider listener callback.
		try
			new = get(evt,'NewValue');
		catch %#ok<CTCH>
			new = evt.AffectedObject.Value;
		end
		if sInt(idk)
			new = round(new);
			set(sUiH(idk), 'Value',new)
		end
		opts.(sTxt{idk}) = new;
		set(sVaH(idk), 'String',sStr(new))
		% Move paired slider:
		if sTwo(idk)
			idt = setdiff(find(abs(sTwo)==abs(sTwo(idk))),idk);
			old = get(sUiH(idt), 'Value');
			if ((new-old) * diff(sign(sTwo([idt,idk])))) < 0
				set(sUiH(idt), 'Value',new)
			end
		end
	end
%
	function fOptMenu(obj,~,idk) % Options menu callback.
		idv = get(obj,'Value');
		if idk>1
			opts.(mTxt{idk}) = mStr{idk}{idv};
			fUpDtMap()
		else
			set(pPnH,     'Visible','off', 'HitTest','off')
			set(pPnH(idv),'Visible','on',  'HitTest','on')
		end
		fAlphaTry()
	end
%
	function fCellEdit(obj,~,idk) % Options table cell callback.
		new = get(obj,'Data');
		isn = sum(isnan(new),2);
		idz = isn==0;
		if all(idz|(isn==3))
			new = new(idz,:);
			if get(tCbH(idk),'Value') % uint
				pwr = pow2(max(3,ceil(log2(max(log2(ohm+1))))));
				new = cast(new,sprintf('uint%d',pwr));
			end
			opts.(tTxt{idk}) = new;
			fBackFore(true)
			fUpDtMap()
		end
	end
	function fCheckBox(obj,~,idk) % Options table checkbox callback.
		old = get(tUiH(idk),'Data');
		if get(obj,'Value')
			% float->uint
			new = round(bsxfun(@times,old,ohm));
		else
			% uint->float
			new = bsxfun(@rdivide,old,ohm);
		end
		set(tUiH(idk),'Data',new);
	end
%
	function fPermSort() % No permutation sorting if N>9.
		ids = strcmpi('sort',mTxt);
		idn = get(mUiH(ids), 'Value');
		if N>9
			if idn > numel(mSrt{1})
				idn = 1;
			end
			opts.sort = mSrt{1}{idn};
			set(mUiH(ids), 'String',mSrt{1}, 'Value',idn)
		else
			set(mUiH(ids), 'String',mStr{ids})
		end
	end
%
	function fBackFore(chg) % Background and Foreground colors.
		if isempty(opts.exc)
			bgd = [1,1,1];
			fgd = [0,0,0];
		else
			new = opts.exc(1,:);
			if isfloat(new)
				bgd = double(new);
			else
				bgd = double(new) ./ ohm;
			end
			% Define forground as farthest color from background:
			[~,idf] = max(sum(bsxfun(@minus,fun(bgd),fun(smp)).^2,2));
			fgd = smp(idf,:);
		end
		if chg
			uih = get(pAxH, 'Parent');
			set([uih{:}], 'BackgroundColor',bgd)
			uih = get(pAxH, 'Title');
			set([uih{:}], 'Color',fgd)
			set(pAxH, 'XColor',fgd, 'YColor',fgd, 'ZColor',fgd)
		end
	end
%
	function fSizeObj(~,~) % Resize the figure contents.
		drawnow()
		try
			figP = get(figH, 'Position');
		catch %#ok<CTCH>
			return
		end
		% Ensure minimum virtual figure size:
		adj = max(figP(3:4),[425,254]);
		pFg = [figP(1:2)+min(0,figP(3:4)-adj),adj];
		% Get object sizes:
		mUiX = cell2mat(get(mUiH, 'Extent'));
		sTxX = cell2mat(get(sTxH, 'Extent'));
		tCbX = cell2mat(get(tCbH, 'Extent'));
		tUiX = cell2mat(get(tUiH, 'Extent'));
		tTxX = cell2mat(get(tTxH, 'Extent'));
		% Group widths and heights:
		tWd = max(tUiX(:,3))+21; % table width
		bWd = 36; % colorbar axes width
		aWd = pFg(3)-tWd-bWd-gap*4; % main axes width
		mHt = max(mUiX(:,4)); % menu height
		% Menu UI positions:
		mUiP = mUiX;
		mUiP(:,1) = aWd+bWd+3*gap;
		mUiP(:,2) = gap+2*mHt*(mTxN-1:-1:0)+3;
		mUiP(:,3) = tWd;
		mUiP(:,4) = mHt;
		set(mUiH,{'Position'},num2cell(mUiP,2))
		% Menu text positions:
		mAxP = mUiP(end,:);
		mAxP(:,4) = 2*mTxN*mHt;
		set(mAxH,'Position',mAxP)
		% Horizontal slider text positions:
		sHt = (2*mTxN*mHt)/sTxN;
		sTxP = sTxX;
		sTxP(:,1) = gap;
		sTxP(:,2) = gap+sHt*(sTxN-1:-1:0);
		sTxP(:,3) = max(sTxX(:,3));
		sTxP(:,4) = sHt;
		set(sTxH,{'Position'},num2cell(sTxP,2))
		% Horizontal slider value positions:
		sVaP = sTxP;
		sVaP(:,1) = sum(sTxP(:,[1,3]),2);
		set(sVaH,{'Position'},num2cell(sVaP,2))
		% Horizontal slider UI positions:
		sUiP = sVaP;
		sUiP(:,1) = sum(sVaP(:,[1,3]),2);
		sUiP(:,3) = aWd-sTxP(:,3)-sVaP(:,3);
		set(sUiH,{'Position'},num2cell(sUiP,2))
		% Table UI positions:
		bHt = pFg(4)-2*mTxN*mHt-3*gap;
		tUiP = tUiX;
		tUiP(:,1) = aWd+bWd+3*gap;
		tUiP(:,2) = 2*mTxN*mHt+2*gap+[bHt/2;0];
		tUiP(:,3) = tWd;
		tUiP(:,4) = bHt/2;
		set(tUiH,{'Position'},num2cell(tUiP,2))
		% Table text positions:
		tTxP = tTxX;
		tTxP(:,1) = tUiP(:,1)+3;
		tTxP(:,2) = tUiP(:,2)+bHt/2-tTxX(:,4);
		tTxP(:,4) = tTxX(:,4)-3;
		set(tTxH,{'Position'},num2cell(tTxP,2))
		% Table checkbox UI positions:
		tCbP = tCbX(:,[1,2,4,4]);
		tCbP(:,1) = tUiP(:,1)+tUiP(:,3)-21;
		tCbP(:,2) = tUiP(:,2)+tUiP(:,4)-21;
		set(tCbH,{'Position'},num2cell(tCbP,2))
		% Colorbar axes position:
		bAxP = tUiP(end,:);
		bAxP(1) = aWd+gap*2;
		bAxP(3) = bWd;
		bAxP(4) = bHt;
		set(bAxH,'Position',bAxP)
		% Number slider UI position:
		nUiP = bAxP;
		nUiP(2) = gap;
		nUiP(4) = 2*mTxN*mHt-txh-gap-mHt;
		set(nUiH,'Position',nUiP)
		% Number slider value position:
		nVaP = nUiP;
		nVaP(2) = gap+nUiP(4);
		nVaP(4) = txh;
		set(nVaH,'Position',nVaP)
		% Eval button UI position:
		eUiP = nVaP;
		eUiP(2) = 2*mTxN*mHt-mHt+gap;
		eUiP(4) = mHt;
		set(eUiH,'Position',eUiP)
		% Main plots uipanel position:
		pPnP = bAxP;
		pPnP(1) = gap;
		pPnP(3) = aWd;
		set(pPnH,'Position',pPnP)
	end
%
if nargout
	waitfor(figH)
	rgb = bgr;
end
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%maxdistcolor_view