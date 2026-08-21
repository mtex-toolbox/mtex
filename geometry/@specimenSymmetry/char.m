function c = char(s,varargin)
% object -> string

if check_option(varargin,'compact')

  % an owner carrying its own convention may pass it in, so the display shows it
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
