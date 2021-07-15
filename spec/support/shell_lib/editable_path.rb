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
      tap { FileUtils.chmod("a+x", pathname) }
    end

    def mk_only_user_readable
      tap { FileUtils.chmod("u+rw,go=", pathname) }
    end
  end
end
