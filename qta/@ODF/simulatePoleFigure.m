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
argin_check(r,{'S2Grid','vector3d'});

if check_option(varargin,'complete')
  antipodal = 'complete';
else
  antipodal = 'antipodal';
end

comment = get_option(varargin,'comment',...
    ['Pole figures simulated from ',getcomment(odf)]);

c = get_option(varargin,'SUPERPOSITION',1);
c = c ./ sum(c);

for iv = 1:length(h)/length(c)
  data = [];
  for ir = 1:length(r)
    
    Z = zeros(GridSize(r(ir)));
    for ic = 0:length(c)-1
      Z = Z + c(ic+1)*reshape(pdf(odf,vector3d(h(iv+ic)),r(ir),antipodal),GridSize(r(ir)));
    end
    
    data = [data;reshape(Z,[],1)];
  end
  if length(c) == 1
    pf(iv) = PoleFigure(h(iv),r,data,odf(1).CS,odf(1).SS,'comment',comment,antipodal); %#ok<AGROW>
  else
    pf = PoleFigure(h,r,data,odf(1).CS,odf(1).SS,'SUPERPOSITION',c,'comment',comment,antipodal);
  end
end
