function pf = simulatePoleFigure(odf,h,r,varargin)
% simulate pole figures for an ODF
%
% *simulatePoleFigure* allows to simulate diffraction counts given an ODF.
% Setting the option SUPERPOSITION one can deside wether to to simulate a
% bunch of single PoleFigures or one superposed PoleFigire.
%
%% Input
%  odf - @ODF
%  h   - @Miller / @vector3d crystallographic directions
%  r   - @vector3d specimen directions
%
%% Options
%  antipodal         - include [[AxialDirectional.html,antipodal symmetry]]
%  SUPERPOSITION - [double] superposition weights
%
%% See also
% PoleFigure/scale PoleFigure/simulatePoleFigure PoleFigure/noisepf

argin_check(h,{'Miller'});
h = set(h,'CS',odf(1).CS);
argin_check(r,'vector3d');

if check_option(varargin,'complete')
  antipodal = 'complete';
else
  antipodal = 'antipodal';
end

comment = get_option(varargin,'comment',...
    ['Pole figures simulated from ',get(odf,'comment')]);

c = get_option(varargin,'SUPERPOSITION',1);
c = c ./ sum(c);

for iv = 1:length(h)/length(c)
      
  Z = zeros(size(r));
  for ic = 0:length(c)-1
    Z = Z + c(ic+1) * ...
      reshape(pdf(odf,vector3d(h(iv+ic)),r,antipodal),size(r));
  end

  if length(c) == 1
    pf(iv) = PoleFigure(h(iv),r,Z,odf(1).CS,odf(1).SS,'comment',comment,antipodal); %#ok<AGROW>
  else
    pf = PoleFigure(h,r,Z,odf(1).CS,odf(1).SS,'SUPERPOSITION',c,'comment',comment,antipodal);
  end
end
