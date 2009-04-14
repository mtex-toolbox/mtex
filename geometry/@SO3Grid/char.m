function c = char(N)
% convert to char

if sum(GridLength(N)) == 1
  c = char(N.Grid,'EULER');
else
  c = [int2str(GridLength(N)),' orientations'];
  res = getResolution(N);
  if ~isempty(res)
    c = [c,', resolution: ',num2str(res*180/pi,2),mtexdegchar];
  end
end
