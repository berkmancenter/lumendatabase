module ImporterFileHelpers
  def touch_file(path)
    File.open(path, 'w') { }
  end
end
