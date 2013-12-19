function result = isOctave ()
  persistent is_octave;
  is_octave = exist('OCTAVE_VERSION');
  result = is_octave;
end
