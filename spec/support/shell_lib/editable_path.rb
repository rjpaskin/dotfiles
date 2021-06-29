module ShellLib
  class EditablePath < Path
    def edit
      tap do
        new_content = yield(read, self)
        pathname.write(new_content)
      end
    end
  end
end
