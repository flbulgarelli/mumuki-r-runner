class RTestHook < Mumukit::Templates::FileHook
  isolated true

  def compile_file_content(request)
<<R
#{request.extra}
#{request.content}
#{request.test}
R
  end

  def tempfile_extension
    '.R'
  end

  def command_line(filename)
    %Q{R -e 'testthat:test_file("#{filename}")'} #TODO use JunitReporter 
  end
end
