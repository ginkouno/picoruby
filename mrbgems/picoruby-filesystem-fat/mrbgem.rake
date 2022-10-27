MRuby::Gem::Specification.new('picoruby-filesystem-fat') do |spec|
  spec.license = 'MIT'
  spec.author  = 'HASUMI Hitoshi'
  spec.summary = 'FAT filesystem'
  spec.add_dependency 'picoruby-vfs'

  obj = "#{build_dir}/src/#{objfile("discio")}"
  file obj => "#{dir}/src/hal/diskio.c" do |t|
    spec.cc.run(t.name, t.prerequisites[0])
  end
  spec.objs << obj

  spec.hal_obj

  Dir.glob("#{dir}/lib/ff14b/source/*.c").each do |src|
    obj = "#{build_dir}/src/#{objfile(File.basename(src, ".c"))}"
    file obj => src do |t|
      spec.cc.run t.name, t.prerequisites[0]
    end
    spec.objs << obj
  end
end
