function pf = DubnaPoleFigure(fname,h_id,data,CS,SS,varargin)
% construct pole figure using Dubna struct file
%
%% Input
%  fname  - crystal struct file
%  h_id   - lines in this struct file corresponding to one peak
%  data   - intensities of this peak with respect to the Dubna Grid
%  CS, SS - crystal / specimen symmetry
%
%% Output
% pf     - single PoleFigure
		
crystal = load(fname);

if any(strcmp(Laue(CS),{'-3','-3m','6/m','6/mmm'}))
  % access superpostion coefficient
  c = crystal(h_id,12);
  % access crystal directions
  h = Miller(crystal(h_id,2),crystal(h_id,3),crystal(h_id,4),crystal(h_id,5),CS);
else
  c = crystal(h_id,11);
  h = Miller(crystal(h_id,2),crystal(h_id,3),crystal(h_id,4),CS);
end

% standard Dubna specimen directions
r = DubnaGrid(19);

pf = PoleFigure(h,r,data,CS,SS,'SUPERPOSITION',c,varargin{:});
