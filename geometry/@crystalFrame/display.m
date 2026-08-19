function display(cF,varargin)
% standard output

% the mineral and the convention go in the header, as for every other
% reference frame - the lattice below is the detail
info = {};
if ~isempty(cF.name), info{end+1} = cF.name; end %#ok<AGROW>
if isa(cF.how2plot,'plottingConvention')
  info{end+1} = conventionChar(cF); %#ok<AGROW>
end

displayClass(cF,inputname(1),'moreInfo',strjoin(info,', '),varargin{:});

disp(['  ' strjoin(cF.axesNames,', ') '  : ' xnum2str(cF.abc)]);

abg = cF.abg;
if any(abs(abg - pi/2) > 1e-6)
  disp(['  α, β, γ  : ' xnum2str(abg./degree) '°']);
end

align = alignment(cF);
if ~isempty(align)
  disp(['  alignment: ' strjoin(align,', ')]);
end

disp(' ');

end
