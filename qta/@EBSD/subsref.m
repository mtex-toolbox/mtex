function ebsd = subsref(ebsd,s)
% indexing of EBSD data
%
%% Syntax:
%  ebsd('Fe') - returns phase Fe
%  ebsd({'Fe','Mg'}) - returns phase Fe and Mg
%

for ii=1:size(s.subs,2)
  switch s.type
    case '()'
      if ischar(s.subs{ii})

        minerals = get(ebsd,'minerals');

        ind = strncmpi(minerals,s.subs{ii},length(s.subs{ii}));

        ebsd = ebsd(ind);

      elseif iscell(s.subs{ii})

        minerals = get(ebsd,'minerals');
        ind = false(size(ebsd));
        for i = 1:length(s.subs{ii})
          ind = ind | strncmpi(minerals,s.subs{ii}{i},length(s.subs{ii}{i}));
        end

        ebsd=ebsd(ind);

      else
        ebsd=ebsd(s.subs{ii});
      end
    otherwise
      error('Use phase name as index as ebsd(''Mg'')')
  end
end
