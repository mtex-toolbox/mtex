function ori = cat(dim,varargin)
% implement cat for orientation
%
% Syntax 
%   ori = cat(dim,ori1,ori2,ori3)
%
% Input
%  dim - dimension
%  ori1, ori2, ori3 - @orientation
%
% Output
%  ori - @orientation
%
% See also
% rotation/horzcat, rotation/vertcat

if ~isempty(varargin{1}) && ~isempty(varargin{2})
  if varargin{1}.CS ~= varargin{2}.CS
    warning("The symmetries " + char(varargin{1}.CS) + " and " + char(varargin{2}.CS) + ...
      " of the orientations to be concatenated do not match");
  end
  if varargin{1}.SS ~= varargin{2}.SS
    warning("The symmetries " + char(varargin{1}.SS) + " and " + char(varargin{2}.SS) + ...
      " of the orientations to be concatenated do not match");
  end
end

ori = cat@rotation(dim,varargin{:});
