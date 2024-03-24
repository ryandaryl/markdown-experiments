def format_tilde_lists(html)
  output = ''
  tilde_list_regex = /((?:.|\n)*?)(\n.+?)(\n +?~ .+?)(\n +?~ .+?)?(\n +?~ .+?)?\n((?:.|\n)*?)/
  html.scan(tilde_list_regex).each do |text_before, left_align, c1, c2, c3, text_after|
    left_align, c1, c2, c3 = [left_align, c1, c2, c3].map{ |x| Kramdown::Document.new(
      x.to_s.gsub(/\n +?~ +?/, '').delete("\n"), input: 'GFM'
    ).to_html}
    inline_list_template = <<~HTML
      <div style=\"overflow: auto\">
        <div style=\"float: left\">#{left_align}</div>
        <div style=\"float: right\">#{c1}</div>
      </div>\n
    HTML
    output << text_before + inline_list_template + text_after
  end
  output
end

class Jekyll::Converters::Markdown::CVProcessor
  def initialize(_config)
    super()
  end

  def convert(content)
    content = format_tilde_lists(content)
    Kramdown::Document.new(
      content, input: 'GFM'
    ).to_html
  end
end
