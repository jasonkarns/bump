module Bump
  class VFile
    include Enumerable

    PRERELEASE    = ["alpha","beta","rc",nil]
    VERSION_REGEX = /(\d+\.\d+\.\d+(?:-(?:#{PRERELEASE.compact.join('|')}))?)/

    def self.version_from(file)
      File.read(file.to_s)[VERSION_REGEX]
    rescue Errno::ENOENT
    end

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

  class VersionRb < VFile
    GLOB="lib/**/version.rb"

    private

    def paths
      super.select do |file|
        self.class.version_from(file)
      end
    end
  end
end
