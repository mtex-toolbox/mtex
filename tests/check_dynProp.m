function check_dynProp
% check that multi channel (N x k) properties survive indexing and assignment
%
% A property does not have to be one number per object - a forescatter image
% is 5 channels, so it is stored as one N x 5 property rather than 5 separate
% ones. dynProp/subSet has always known that, but its two siblings did not:
%
%  - subsasgn appended the ':' that keeps the columns to the SHARED subscript
%    inside the per property loop, so a second N x k property appended a
%    second ':', and it wrote s.subs instead of s(1).subs
%  - the delete branch of subsasgn had no N x k case at all, so ebsd(ind)=[]
%    hit A(ind)=[] on a matrix, which MATLAB rejects
%  - subsref's '()' branch had none either. That branch is currently dead -
%    every MTEX class strips '()' in its own subsref and routes it through
%    subSet - so this file cannot reach it, and it is fixed for consistency
%    only
%
% Note ebsd(ind) and subSet(ebsd,ind) agreeing is asserted below because it
% was reported as broken. It was not - both go through subSet - and it has
% to stay that way.

[ebsd,fs,im,bc] = makeMap;

checkIndexing(ebsd,fs,im,bc);
checkAssignment(ebsd);
checkAssignmentNewField(ebsd);
checkDeletion(ebsd);
checkCat(ebsd);

disp('check_dynProp: passed');

end

% =========================================================================
function checkIndexing(ebsd,fs,im,bc)

n = length(ebsd);

for indCell = {[3 7 11 20], (1:n).' > n/2}

  ind = indCell{1};
  what = 'a linear index'; if islogical(ind), what = 'a logical mask'; end

  sub = ebsd(ind);

  assert(isequal(sub.fs,fs(ind,:)), ...
    'check_dynProp: %s gives an fs of %s, expected %s',...
    what,mat2str(size(sub.fs)),mat2str(size(fs(ind,:))));

  assert(isequal(sub.im,im(ind,:)), ...
    'check_dynProp: %s gives an im of %s, expected %s',...
    what,mat2str(size(sub.im)),mat2str(size(im(ind,:))));

  assert(isequal(sub.bc,bc(ind)), ...
    'check_dynProp: %s does not keep an ordinary property',what);

  % the two routes into a subset must not disagree
  sub2 = subSet(ebsd,ind);
  assert(isequal(sub2.fs,sub.fs) && isequal(sub2.im,sub.im) && ...
    isequal(sub2.bc,sub.bc), ...
    'check_dynProp: ebsd(ind) and subSet(ebsd,ind) disagree for %s',what);

end

end

% =========================================================================
function checkAssignment(ebsd)
% writing a subset back. With two N x k properties the old code appended a
% second ':' to the shared subscript while handling the second one

ind = [2 5 9 14];

b = ebsd(ind);
b.fs = -b.fs;
b.im = -b.im;
b.bc = -b.bc;

e = ebsd;
e(ind) = b;

assert(isequal(e.fs(ind,:),-ebsd.fs(ind,:)), ...
  'check_dynProp: assigning a subset did not write the first N x k property');

assert(isequal(e.im(ind,:),-ebsd.im(ind,:)), ...
  'check_dynProp: assigning a subset did not write the second N x k property');

assert(isequal(e.bc(ind),-ebsd.bc(ind)), ...
  'check_dynProp: assigning a subset did not write an ordinary property');

% and nothing outside ind moved
keep = true(length(ebsd),1); keep(ind) = false;
assert(isequal(e.fs(keep,:),ebsd.fs(keep,:)) && ...
  isequal(e.im(keep,:),ebsd.im(keep,:)) && ...
  isequal(e.bc(keep),ebsd.bc(keep)), ...
  'check_dynProp: assigning a subset changed rows outside the subset');

assert(isequal(size(e.fs),size(ebsd.fs)) && isequal(size(e.im),size(ebsd.im)), ...
  'check_dynProp: assigning a subset resized fs to %s and im to %s',...
  mat2str(size(e.fs)),mat2str(size(e.im)));

end

% =========================================================================
function checkAssignmentNewField(ebsd)
% the target does not carry the multi channel property yet, so a placeholder
% is created for it - it has to be N x k, not N x 1

ind = [4 8 12];

e = ebsd;
e.prop = rmfield(e.prop,'fs');

b = ebsd(ind);
e(ind) = b;

assert(isequal(size(e.fs),[length(ebsd) size(ebsd.fs,2)]), ...
  'check_dynProp: a newly created multi channel property has size %s, expected %s',...
  mat2str(size(e.fs)),mat2str([length(ebsd) size(ebsd.fs,2)]));

assert(isequal(e.fs(ind,:),ebsd.fs(ind,:)), ...
  'check_dynProp: a newly created multi channel property did not get the values');

end

% =========================================================================
function checkDeletion(ebsd)
% ebsd(ind) = [] used to hit A(ind) = [] on an N x k property

ind = [1 6 13];
keep = true(length(ebsd),1); keep(ind) = false;

e = ebsd;
e(ind) = [];

assert(length(e) == length(ebsd) - numel(ind), ...
  'check_dynProp: deleting %d of %d measurements left %d',...
  numel(ind),length(ebsd),length(e));

assert(isequal(size(e.fs),[length(e) size(ebsd.fs,2)]), ...
  'check_dynProp: after a deletion fs is %s, expected %s',...
  mat2str(size(e.fs)),mat2str([length(e) size(ebsd.fs,2)]));

assert(isequal(e.fs,ebsd.fs(keep,:)) && isequal(e.im,ebsd.im(keep,:)) && ...
  isequal(e.bc,ebsd.bc(keep)), ...
  'check_dynProp: a deletion kept the wrong rows');

end

% =========================================================================
function checkCat(ebsd)
% note this prints "Duplicated Ids detected" - concatenating a map with
% itself genuinely does that, and it is not what is under test here

e = [ebsd; ebsd];

assert(isequal(size(e.fs),[2*length(ebsd) size(ebsd.fs,2)]), ...
  'check_dynProp: concatenation gives an fs of %s, expected %s',...
  mat2str(size(e.fs)),mat2str([2*length(ebsd) size(ebsd.fs,2)]));

assert(isequal(e.fs,[ebsd.fs;ebsd.fs]) && isequal(e.im,[ebsd.im;ebsd.im]), ...
  'check_dynProp: concatenation does not stack the multi channel properties');

end

% =========================================================================
function [ebsd,fs,im,bc] = makeMap
% a plain map carrying TWO multi channel properties next to an ordinary one -
% one alone does not expose the subscript that accumulates across the loop

n = 24; d = 0.3;

fs = reshape(1:5*n,n,5);          % readable values, so a flattened result
im = -reshape(1:3*n,n,3);         % is obvious from the numbers themselves
bc = (1:n).';

ebsd = EBSD(vector3d((0:n-1).'*d,zeros(n,1),zeros(n,1)), rotation.rand(n,1), ...
  ones(n,1), {crystalSymmetry('m-3m')}, struct('fs',fs,'im',im,'bc',bc));

assert(isequal(size(ebsd.fs),[n 5]) && isequal(size(ebsd.im),[n 3]), ...
  'check_dynProp: the constructor already flattened the multi channel properties');

end
