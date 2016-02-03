def quiet_load(file)
  warn_level = $VERBOSE
  $VERBOSE = nil
  load file
  $VERBOSE = warn_level
end
