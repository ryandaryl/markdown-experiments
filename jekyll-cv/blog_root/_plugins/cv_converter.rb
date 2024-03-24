def format_tilde_lists(html)
  output = ''
  tilde_list_regex = /((?:.|\n)*?)(\n.+?)(\n +?~ .+?)(\n +?~ .+?)?(\n +?~ .+?)?\n((?:.|\n)*?)/
  html.scan(tilde_list_regex).each do |text_before, left_align, c1, c2, c3, text_after|
    list_items = [left_align, c1, c2, c3].compact
    list_items = list_items.map do |x|
      Kramdown::Document.new(
        x.to_s.gsub(/\n +?~ +?/, '').delete("\n"), input: 'GFM'
      ).to_html
    end
    attributes = list_items.each_with_index.map do |_x, i|
      "position: absolute; left: #{
        i * (100 / (list_items.length - 1))}%"
    end
    attributes[0] = 'float: left'
    attributes[-1] = 'float: right'
    div_list = list_items.zip(attributes).map { |item, attribute| "<div style=\"#{attribute}\">#{item}</div>" }
    inline_list = "<div style=\"overflow: auto; position: relative;\">#{div_list.join('')}</div>\n"
    output << text_before + inline_list + text_after
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
