require 'bump/errors'
require 'bump/version_file'

module Bump
  class <<self
    attr_accessor :tag_by_default
  end

  class Bump
    BUMPS         = %w(major minor patch pre)
    PRERELEASE    = ["alpha","beta","rc",nil]
    OPTIONS       = BUMPS | ["set", "current"]

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
          ["Current version: #{current}", 0]
        else
          raise InvalidOptionError
        end
      rescue InvalidOptionError
        ["Invalid option. Choose between #{OPTIONS.join(',')}.", 1]
      rescue InvalidVersionError
        ["Invalid version number given.", 1]
      rescue UnfoundVersionError
        ["Unable to find your gem version", 1]
      rescue TooManyVersionFilesError
        ["More than one version file found (#{$!.message})", 1]
      end

      def current
        current_info.version
      end

      private

      def bump_to(next_version, options)
        current_version = current_info.version

        current_info.version = next_version

        if options[:bundle] and under_version_control?("Gemfile.lock")
          bundler_with_clean_env do
            system("bundle")
          end
        end
        commit(next_version, current_info.path, options) if options[:commit]
        ["Bump version #{current_version} to #{next_version}", 0]
      end

      def bundler_with_clean_env(&block)
        if defined?(Bundler)
          Bundler.with_clean_env(&block)
        else
          yield
        end
      end

      def bump_part(part, options)
        next_version = next_version(current_info.version, part)
        bump_to(next_version, options)
      end

      def bump_set(next_version, options)
        bump_to(next_version, options)
      end

      def commit_message(version, options)
        (options[:commit_message]) ? "v#{version} #{options[:commit_message]}" : "v#{version}"
      end

      def commit(version, file, options)
        return unless File.directory?(".git")
        system("git add --update Gemfile.lock") if options[:bundle]
        system("git add --update #{file} && git commit -m '#{commit_message(version, options)}'")
        system("git tag -a -m 'Bump to v#{version}' v#{version}") if options[:tag]
      end

      def current_info
        @vf ||= [VersionFile, VersionRbFile, GemspecFile, LibRbFile, ChefFile]
          .map(&:new).find(&:version) || raise(UnfoundVersionError)
      end

      def next_version(current, part)
        current, prerelease = current.split('-')
        major, minor, patch, *other = current.split('.')
        case part
        when "major"
          major, minor, patch, prerelease = major.succ, 0, 0, nil
        when "minor"
          minor, patch, prerelease = minor.succ, 0, nil
        when "patch"
          patch = patch.succ
        when "pre"
          prerelease.strip! if prerelease.respond_to? :strip
          prerelease = PRERELEASE[PRERELEASE.index(prerelease).succ % PRERELEASE.length]
        else
          raise "unknown part #{part.inspect}"
        end
        version = [major, minor, patch, *other].compact.join('.')
        [version, prerelease].compact.join('-')
      end

      def under_version_control?(file)
        @all_files ||= `git ls-files`.split(/\r?\n/)
        @all_files.include?(file)
      end
    end
  end
end
