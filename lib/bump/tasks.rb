require "bump"

namespace :bump do
  (Bump::Bump::BUMPS + ["current"]).each do |bump|
    if bump == "current"
      desc "Show current gem version"
    else
      desc "Bump #{bump} part of gem version"
    end

    task bump, :tag do |_task, args|
      Bump::Bump.new(args).run(bump)
    end
  end

  desc "Sets the version number using the VERSION environment variable"
  task :set do
    Bump::Bump.new.set(ENV['VERSION'])
  end
end
