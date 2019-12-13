class RQueryHook < Mumukit::Templates::FileHook
  with_error_patterns
  isolated true

  def tempfile_extension
    '.R'
  end

  def compile_file_content(r)
    "#{compile_file_header(r)}\n#{compile_query(r.query)}"
  end

  def compile_file_header(r)
<<R
#{r.extra}

#{r.content}

#{compile_cookie(r.cookie)}
R
  end

  def compile_query(query, output_var = "mumuki__query__result")
    "#{output_var} <- #{query};\nprint(#{output_var})"
  end

  def compile_cookie(cookie)
    return if cookie.blank?

    compile_statements(cookie).join "\n"
  end

  def command_line(filename)
    "Rscript #{filename}"
  end

  private

  def compile_statements(cookie)
    cookie.map { |query| "invisible(tryCatch({ #{query} }, error = function(e) {}))" }
  end

  def error_patterns
    [
      Mumukit::ErrorPattern::Errored.new(error_regexp)
    ]
  end

  def error_types
    '(Reference|Syntax|Type)Error'
  end

  def error_regexp
    /(?=\X*#{error_types})(solution.*\n|var mumuki__query__result = )|#{error_types}.*\n\K\X*/
  end
end
