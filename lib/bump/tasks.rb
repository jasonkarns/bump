require "bump"

namespace :bump do
  (Bump::BUMPS).each do |bump|
    desc "Bump version to #{Bump::Bump.new.next(bump)}"
    task bump, :tag do |_task, args|
      Bump::Bump.new(args).bump(bump)
    end
  end

  desc "Show current gem version: #{Bump::Bump.new.current}"
  task :current, :tag do |_task, args|
    Bump::Bump.new(args).print_current
  end

  desc "Sets the version number using the VERSION environment variable"
  task :set, [:version] do |_task, args|
    args.with_defaults(:version => ENV['VERSION'])
    Bump::Bump.new.set(args[:version])
  end
end
