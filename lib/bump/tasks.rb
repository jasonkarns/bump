require "bump"

namespace :bump do
  (Bump::Bump::BUMPS).each do |bump|
    desc "Bump #{bump} part of gem version"
    task bump, :tag do |_task, args|
      Bump::Bump.new(args).bump(bump)
    end
  end

  desc "Show current gem version"
  task :current, :tag do |_task, args|
    Bump::Bump.new(args).print_current
  end

  desc "Sets the version number using the VERSION environment variable"
  task :set do
    Bump::Bump.new.set(ENV['VERSION'])
  end
end
