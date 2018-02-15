function plot_spectra(spec,bg,range)
% plot spectra of the Dubna goniometer

d = 1;
r = 0;
key = 0;
if nargin <= 2, range = 250:3100;end
mm = 0;

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

