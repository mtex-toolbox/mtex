function plot_spectra(spec,bg,range,varargin)
% plot spectra of the Dubna goniometer
%
% Syntax
%   plot_spectra(spec,bg)
%   plot_spectra(spec,bg,range)
%   plot_spectra(spec,bg,'noInteraction')
%
% Input
%  spec  - spectra
%  bg    - background spectra
%  range - channels to display, default 250:3100
%
% Flags
%  noInteraction - draw the first spectrum and return, instead of browsing
%
% Description
%
% By default this is an interactive browser: it draws one spectrum, waits
% for a key press and steps through detectors and phi positions until
% Escape is pressed. That blocks anything non-interactive, so a doc page
% that calls it has to pass |noInteraction| - the flag is the only thing
% that helps there, since publishing happens in a perfectly ordinary
% MATLAB with a display. A MATLAB started with |-nodisplay| implies the
% flag, because waitforbuttonpress errors outright without figure windows.

% accept the flag in place of range
if nargin >= 3 && (ischar(range) || isstring(range))
  varargin = [{range},varargin];
  range = [];
end

d = 1;
r = 0;
key = 0;
if nargin <= 2 || isempty(range), range = 250:3100; end
mm = 0;

interactive = ~check_option(varargin,'noInteraction') && hasFigureWindows;

%subplot('position',[0.025,0.03,0.975,0.97]);
while key ~= 27

	if r+1 > 0
		if d > 0
			sp = spec(:,r+1,d);
			if nargin >= 2
				plot(range,bg(range,r+1,d),'r','LineWidth',2);
				hold on
			end
			mm = max(mm,max(sp(range)));
			axis([min(range) max(range) 0 max(mm)]);
			set(gcf,'Name',['Detector ',char(64+d),'    Phi: ',int2str(r)]);
		else
			sp = sum(spec(:,r+1,:),2);
			set(gcf,'Name',['sum spectra for  Phi: ',int2str(r)]);
		end
	else
		if d > 0
			sp = sum(spec(:,:,d),2);
			set(gcf,'Name',['sum spectra for detector ',char(64+d)]);
		else
			sp = sum(spec(:,:),2);
			set(gcf,'Name','sum spectra');
		end
	end
	plot(range,sp(range));
	xlim([min(range),max(range)]);
	hold off;

	% one spectrum is all a non-interactive caller can show
	if ~interactive, break; end

	waitforbuttonpress;
	key = get(gcf,'CurrentCharacter');
	%if any(key == 'a':'u')
	%	d = key-96;
	if key == 'l'
		range = min(range)+10:max(range);
	elseif key == 'L'
		range = min(range)-10:max(range);
	elseif key == 'r'
				range = min(range):max(range)-10;
	elseif key == 'R'
		range = min(range):max(range)+10;
  elseif key == 'm'
    range = range + (max(range)-min(range))*0.2;
	elseif key == 'n'
    range = range - (max(range)-min(range))*0.2;
  elseif key ==  28
		r = r - 1;
	elseif key == 29
		r = r + 1;
	elseif key == 30
		d = d + 1;
	elseif key == 31
		d = d -1;
	else
		disp(int8(key));
	end
	d = mod(d,size(spec,3)+1);
	r = mod(r+1,size(spec,2)+1)-1;
end

end

function tf = hasFigureWindows
% false in a MATLAB started with -nodisplay or -noFigureWindows, where
% waitforbuttonpress is not supported

try
  tf = logical(feature('ShowFigureWindows'));
catch
  tf = usejava('desktop');
end

end

