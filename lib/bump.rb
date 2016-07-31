require 'bump/errors'
require 'bump/version_file'

module Bump
  class << self
    attr_accessor :tag_by_default
  end

  class Bump
    BUMPS      = %w(major minor patch pre)
    PRERELEASE = ["alpha","beta","rc",nil]
    OPTIONS    = BUMPS | ["set", "current"]

    class << self

      def defaults
        {
          :commit => true,
          :bundle => File.exist?("Gemfile"),
          :tag => ::Bump.tag_by_default
        }
      end

      def run(bump, options={})
        options = defaults.merge(options)

        case bump
        when *BUMPS
          bump_part(bump, options)
        when "set"
          raise InvalidVersionError unless options[:version]
          bump_set(options[:version], options)
        when "current"
          puts "Current version: #{current}"
        else
          raise InvalidOptionError, OPTIONS
        end
      end

      def current
        version_file.version
      end

      def next(part)
        version_file.version.next part
      end

      private

      def bump_part(part, options)
        bump_to(self.next(part), options)
      end

      def bump_set(next_version, options)
        bump_to(next_version, options)
      end

      def bump_to(new_version, options)
        puts "Bump version #{current} to #{new_version}"

        version_file.version = new_version

        bundler_with_clean_env { system("bundle") } if options[:bundle]
        commit(new_version, options) if options[:commit]
      end

      def bundler_with_clean_env(&block)
        return unless under_version_control?("Gemfile.lock")
        if defined?(Bundler)
          Bundler.with_clean_env(&block)
        else
          yield
        end
      end

      def commit(version, options)
        return unless File.directory?(".git")
        system("git add --update Gemfile.lock") if options[:bundle]
        system("git add --update #{version_file.path} && git commit -m '#{commit_message(version, options)}'")
        system("git tag -a -m 'Bump to v#{version}' v#{version}") if options[:tag]
      end

      def commit_message(version, options)
        (options[:commit_message]) ? "v#{version} #{options[:commit_message]}" : "v#{version}"
      end

      def under_version_control?(file)
        @all_files ||= `git ls-files`.split(/\r?\n/)
        @all_files.include?(file)
      end

      def version_file
        @vf ||= [VersionFile, VersionRbFile, GemspecFile, LibRbFile, ChefFile]
          .map(&:new).find(&:version) || raise(UnfoundVersionError)
      end
    end
  end
end
