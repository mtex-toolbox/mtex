function c = char(S3G,varargin)
% convert to char

if numel(S3G) == 1
  c = char(quaternion(S3G),'EULER');
else
  c = [int2str(numel(S3G)),' orientations'];
  res = getResolution(S3G);
  if ~isempty(res) && ~check_option(varargin,'nores')
    c = [c,', resolution: ',xnum2str(res*180/pi),mtexdegchar];
  end
end
