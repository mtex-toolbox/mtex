function [c,options] = orientation2color(o,colorCoding,varargin)
% convert orientation to color
%
%% Input
%  o    - @orientation
%  coloring -
%    IPDF, HKL
%    BUNGE, IHS, RODRIGUES, ANGLE
%%
%

% search available color codings
colorCodings = dir([mtex_path '/tools/orientationMappings/*.m']);
colorCodings = {colorCodings.name};

found = strcmpi(['om_' colorCoding,'.m'],colorCodings);

if ~any(found)
  colorCodings = strrep(colorCodings,'om_','');
  colorCodings = strrep(colorCodings,'.m','');
  format = ['\n\n' repmat(' %s\n',1,numel(colorCodings))];
  error(['Unknown color coding! Available colorcodings are: ',format],...
    colorCodings{:});
end

% compute color
[c,options] = feval(colorCodings{found}(1:end-2),o,varargin{:});

% arrange RGB values
if 3*numel(o) == numel(c)
  c = reshape(c,[],3);
end
