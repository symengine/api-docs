require "rake"
require "mkmf" # for find_executable
require "fileutils" # Cross Platform

#############
# Variables #
#############
# Common
CWD = File.expand_path(__dir__)
DOXYFILE = "Doxyfile-syme.cfg"
NIXSHELL = File.join(CWD, "shell.nix")
SYMESRC = File.join(CWD, "projects/symengine/symengine")
OUTPUB = File.join(CWD, "public")
# API
BASEAPI = File.join(CWD, "docs/")
SPHINXAPI = File.join(BASEAPI, "Sphinx")
DOXXML = File.join(BASEAPI, "Doxygen/gen_docs/xml")
OUTAPI = File.join(CWD, "public")
DOXLUA = File.join(BASEAPI, "doxyrestConf.lua")
# Coverage
OUTCOV = File.join(OUTAPI, "doc_coverage")
DOCCOV = File.join(OUTAPI, "doc-coverage.info")

# Exception
class RunnerException < StandardError
  def initialize(msg = "Undefined runner, supports nix and system (with conda)", exception_type = "custom")
    @exception_type = exception_type
    super(msg)
  end
end

class ExecException < StandardError
  def initialize(msg = "Missing an application, typically doxyrest", exception_type = "custom")
    @exception_type = exception_type
    super(msg)
  end
end

#########
# Tasks #
#########

# Genric
task :default => :darkServe

desc "Clean the generated content"
task :clean do
  rm_rf "public"
  rm_rf "docs/Doxygen/gen_docs"
  rm_rf "docs/Sphinx/build"
  rm_rf "docs/Sphinx/gen_doxyrest"
end

desc "Serve site with darkhttpd"
task :darkServe, [:port, :runner] do |task, args|
  args.with_defaults(:port => "1336", :runner => "system")
  if args.runner == "system"
    sh "darkhttpd #{OUTAPI} --port #{args.port}"
  elsif args.runner == "nix"
    sh "nix-shell #{NIXSHELL} --run 'darkhttpd #{OUTAPI} --port #{args.port}'"
  else
    raise RunnerException.new
  end
end

namespace "api" do
  desc "Build full API documentation"
  task :mkDocs, [:builder, :runner] do |taks, args|
    args.with_defaults(:builder => "html", :runner => "system")
    Rake::Task["api:mkSphinx"].invoke(args.builder, args.runner)
  end

  desc "Build doxygen API"
  task :mkDoxy, [:runner] do |task, args|
    args.with_defaults(:runner => "system")
    Dir.chdir(to = File.join(CWD, "docs/Doxygen"))
    if args.runner == "system"
      system("doxygen", DOXYFILE)
    elsif args.runner == "nix"
      sh "nix-shell #{NIXSHELL} --run 'doxygen #{DOXYFILE}'"
    else
      raise RunnerException.new
    end
  end

  desc "Build doxyrest API"
  task :mkDoxyRest, [:builder, :runner] => "api:mkDoxy" do |task, args|
    args.with_defaults(:builder => "html", :runner => "system")
    Dir.chdir(to = CWD)
    if args.runner == "system"
      if find_executable "doxyrest"
        sh "doxyrest -c #{DOXLUA}"
      elsif find_executable "nix"
        begin
          puts "System has no doxyrest, trying nix"
          sh "nix-shell #{NIXSHELL} --run 'doxyrest -c #{DOXLUA}'"
        rescue
          puts "Falling back to conda"
          sh "conda run doxyrest -c #{DOXLUA}"
        end
      else
        raise ExecException.new
      end
    elsif args.runner == "nix"
      begin
        puts "System has no doxyrest, trying nix"
        sh "nix-shell #{NIXSHELL} --run 'doxyrest -c #{DOXLUA}'"
      rescue
        puts "Falling back to conda"
        sh "conda run doxyrest -c #{DOXLUA}"
      end
    else
      raise RunnerException.new
    end
  end

  desc "Build Sphinx API docs"
  task :mkSphinx, [:builder, :runner] => ["api:mkDoxyRest"] do |task, args|
    args.with_defaults(:builder => "html", :runner => "system")
    if args.runner == "system"
      sh "conda run sphinx-build #{SPHINXAPI} #{OUTAPI} -b #{args.builder}"
    elsif args.runner == "nix"
      begin
        sh "nix-shell #{NIXSHELL} --run 'sphinx-build #{SPHINXAPI} #{OUTAPI} -b #{args.builder}'"
      rescue
        puts "Handling the case where nix errors out by rescuing with conda"
        sh "conda run sphinx-build #{SPHINXAPI} #{OUTAPI} -b #{args.builder}"
      end
    else
      raise RunnerException.new
    end
  end

  desc "Build API Coverage"
  task :mkDocCover, [:runner] => ["api:mkDoxy"] do |task, args|
    args.with_defaults(:runner => "system")
    if args.runner == "system"
      sh "conda run python3 -m coverxygen --xml-dir #{DOXXML} --src-dir #{SYMESRC} --output #{DOCCOV}"
    elsif args.runner == "nix"
      sh "nix-shell #{NIXSHELL} --run 'python3 -m coverxygen --xml-dir #{DOXXML} --src-dir #{SYMESRC} --output #{DOCCOV}'"
    else
      raise RunnerException.new
    end
  end

  desc "Build HTML Coverage Report"
  task :mkDocCovHTML, [:runner] => ["api:mkDocCover"] do |t, args|
    args.with_defaults(:runner => "system")
    if args.runner == "system"
      sh "genhtml --no-function-coverage --no-branch-coverage #{DOCCOV} -o #{OUTCOV}"
    elsif args.runner == "nix"
      sh "nix-shell #{NIXSHELL} --run 'genhtml --no-function-coverage --no-branch-coverage #{DOCCOV} -o #{OUTCOV}'"
    else
      raise RunnerException.new
    end
  end
end
