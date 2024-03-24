class Jekyll::Converters::Markdown::CVProcessor
  def initialize(_config)
    super()
  end

  def convert(content)
    output = ''
    tilde_list_regex = /((?:.|\n)*?)(\n.+?)(\n +?~ .+?)(\n +?~ .+?)?(\n +?~ .+?)?\n((?:.|\n)*?)/
    content.scan(tilde_list_regex).each do |text_before, left_align, c1, _, _, text_after|
      left_align = Kramdown::Document.new(
        left_align.delete("\n"), input: 'GFM'
      ).to_html
      output << text_before + <<~HTML
        <div style=\"overflow: auto\">
          <div style=\"float: left\">#{left_align}</div>
          <div style=\"float: right\">#{c1.gsub(/\n +?~ +?/, '')}</div>
        </div>\n#{text_after}
      HTML
    end
    Kramdown::Document.new(
      output, input: 'GFM'
    ).to_html
  end
end
