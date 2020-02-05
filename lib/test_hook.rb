class RTestHook < Mumukit::Templates::FileHook
  isolated true
  structured true

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
    %Q{R -q -e testthat::test_file('#{filename}',reporter='junit')} #TODO use
  end

  def post_process_file(file, result, status)
    if status.failed?
      [result, :errored]
    else
      super
    end
  end

  def to_structured_result(result)
    clean_xml = result.gsub(/^>.+$/, '')
    transform(Nokogiri::XML(clean_xml).xpath('//testcase'))
  end

  def transform(examples)
    examples.map do |it|
      failure = it.at('failure')
      if failure
        [it['name'].gsub('_', ' '), :failed, failure.content]
      else
        [it['name'].gsub('_', ' '), :passed, '']
      end
    end
  end
end
