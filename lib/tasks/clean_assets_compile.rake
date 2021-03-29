Rake::Task['assets:precompile'].enhance do
  Rake::Task['lumen:create_non_digest_assets'].invoke
end

namespace :lumen do
  logger = Logger.new($stderr)

  task :create_non_digest_assets => :"assets:environment"  do
    manifest_path = Dir.glob(File.join(Rails.root, 'public/assets/.sprockets-manifest-*.json')).first
    manifest_data = JSON.load(File.new(manifest_path))

    manifest_data['assets'].each do |logical_path, digested_path|
      logical_pathname = Pathname.new logical_path
    
      if Chill::Application.config.assets.non_digest_named_assets.any? {|testpath| logical_pathname.fnmatch?(testpath, File::FNM_PATHNAME) }
        full_digested_path    = File.join(Rails.root, 'public/assets', digested_path)
        full_nondigested_path = File.join(Rails.root, 'public/assets', logical_path)

        logger.info "Copying to #{full_nondigested_path}"

        FileUtils.copy_file full_digested_path, full_nondigested_path, true
      end
    end
  end
end
