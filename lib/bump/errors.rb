module Bump
  class InvalidOptionError < StandardError
    def initialize(options)
      super "Invalid option. Choose between #{options.join(',')}."
    end
  end

  class InvalidVersionError < StandardError
    def initialize(message="Invalid version number given.")
      super message
    end
  end

  class UnfoundVersionError < StandardError
    def initialize(message="Unable to find your gem version")
      super message
    end
  end

  class TooManyVersionFilesError < StandardError
    def initialize(files)
      super "More than one version file found (#{files.join(", ")})"
    end
  end
end
