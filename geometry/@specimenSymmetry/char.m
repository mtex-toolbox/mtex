function c = char(s,varargin)
% object -> string

if check_option(varargin,'compact')

  % an owner that carries its own plotting convention - a tensor, an S2Fun -
  % may pass it in, so the display shows the frame the data is plotted in
  % rather than the one of this symmetry. headerChar renders it with the
  % frame's axes names and makes it clickable
  pC = getClass(varargin,'plottingConvention',s.how2plot);
  c = referenceFrame.headerChar(s.frame,pC);
  if s.id > 1, c = [c,' (' s.pointGroup ')']; end

elseif check_option(varargin,'verbose')
  c = s.pointGroup;
  if check_option(varargin,'symmetryType')
    c = ['  specimen symmetry: ',c];
  end
else
  c = ['"',s.pointGroup,'"'];
end
