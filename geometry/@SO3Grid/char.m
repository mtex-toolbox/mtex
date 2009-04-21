function c = char(N,varargin)
% convert to char

if sum(GridLength(N)) == 1
  c = char(N.Grid,'EULER');
else
  c = [int2str(GridLength(N)),' orientations'];
  res = getResolution(N);
  if ~isempty(res) && ~check_option(varargin,'nores')
    c = [c,', resolution: ',num2str(res*180/pi,2),mtexdegchar];
  end
end
