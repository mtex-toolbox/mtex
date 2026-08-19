function display(cs,varargin)
% standard output

% the plotting convention goes into the header, the way a specimen symmetry
% shows it - see @specimenSymmetry/display. For a crystal it is stated in
% crystal directions, e.g. '⊙c*→a', which is how a crystallographer names
% a setting; conventionChar falls back to the Cartesian pictogram when no
% crystal axis points out of the screen or east
if isscalar(cs) && isa(cs.how2plot,'plottingConvention')
  displayClass(cs,inputname(1),'moreInfo',conventionChar(cs.frame),varargin{:});
else
  displayClass(cs,inputname(1),varargin{:});
end

if ~isscalar(cs)
  disp(cs);
  return
end

disp(' ');

props = {}; propV = {};

% add mineral name if given
if ~isempty(cs.mineral)
  props{end+1} = 'mineral'; 
  propV{end+1} = cs.mineral;
end

if ~isempty(cs.color)
  props{end+1} = 'color'; 
  propV{end+1} = rgb2str(cs.color);
end

% add symmetry
props{end+1} = 'symmetry'; 
if cs.id>0
  propV{end+1} = symmetry.pointGroups(cs.id).Inter;
  if getMTEXpref("UTF8Output")
    ov = char(hex2dec('0305'));   % U+0305 COMBINING OVERLINE
    propV{end} = regexprep(propV{end}, '-([A-Za-z0-9])', ['$1' ov]);
  end
else
  propV{end+1} = 'unknown';
end

% add symmetry
props{end+1} = 'elements'; 
propV{end+1} = numSym(cs);



% the lattice geometry all lives on the reference frame - a symmetry
% without one has no axes to report, and every one of these would throw
% out of the display rather than print what it does know
if ~isempty(cs.frame)

  % add axis length
  props{end+1} = 'a, b, c';
  propV{end+1} = option2str(vec2cell(norm(cs.axes)));

  % add axis angle
  if cs.id < 12
    props{end+1} = 'alpha, beta, gamma';
    propV{end+1} = [num2str(cs.alpha./degree) mtexdegchar ', ' ...
      num2str(cs.beta./degree) mtexdegchar ', ' ...
      num2str(cs.gamma./degree) mtexdegchar];
  end

  % add reference frame
  if ~cs.lattice.isEucledean
    props{end+1} = 'reference frame';
    propV{end+1} = option2str(cs.alignment);
  end

end

% display all properties
cprintf(propV(:),'-L','  ','-ic','L','-la','L','-Lr',props,'-d',': ');

disp(' ');
