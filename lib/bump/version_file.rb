module Bump
  class VFile
    include Enumerable

    PRERELEASE    = ["alpha","beta","rc",nil]
    VERSION_REGEX = /(\d+\.\d+\.\d+(?:-(?:#{PRERELEASE.compact.join('|')}))?)/

    def path
      paths.tap do |files|
        raise TooManyVersionFilesError, files.join(", ") if files.size > 1
      end.first
    end

    def version
      File.read(path.to_s)[VERSION_REGEX]
    rescue Errno::ENOENT
    end

    private

    def paths
      Dir.glob(self.class::GLOB)
    end

  end

  class VersionFile < VFile
    GLOB="VERSION"
  end
end
