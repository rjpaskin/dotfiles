require "fileutils"

module ShellLib
  class EditablePath < Path
    def mkpath(*args)
      tap { pathname.mkpath(*args) }
    end

    def edit
      tap do
        new_content = yield(read, self)
        pathname.write(new_content)
      end
    end

    def write(content)
      tap do
        dirname.mkpath
        pathname.write(content)
      end
    end

    def mk_executable
      chmod("a+x")
    end

    def mk_only_user_readable
      chmod("u+rw,go=")
    end

    def chmod(mode)
      tap { FileUtils.chmod(mode, pathname) }
    end
  end
end
