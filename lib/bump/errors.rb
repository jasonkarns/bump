module Bump
  class InvalidOptionError < StandardError; end
  class InvalidVersionError < StandardError; end
  class UnfoundVersionError < StandardError; end
  class TooManyVersionFilesError < StandardError; end
end
