def resolve_header(html, frontmatter)
  # Port of resolveHeader function from Oh My CV:
  # https://github.com/Renovamen/oh-my-cv/blob/891c884c53cdf96c17a4cde94934cd0a4898c57a/site/src/utils/markdown.ts#L44-L71
  header = ''
  header += "<h1>#{frontmatter['name']}</h1>\n" if frontmatter['name']

  if frontmatter['header']
    n = frontmatter['header'].length

    (0...n).each do |i|
      item = frontmatter['header'][i]
      next unless item

      header += item['new_line'] ? "<br>\n" : ''
      header += "<span class=\"resume-header-item#{i == n - 1 || frontmatter['header'][i + 1]&.fetch('newLine', false) ? ' no-separator' : ''}\">"
      header += if item['link']
                  "<a href=\"#{item['link']}\" target=\"_blank\" rel=\"noopener noreferrer\">#{item['text']}</a>"
                else
                  item['text']
                end
      header += "</span>\n"
    end
  end

  "<div class=\"resume-header\">#{header}</div>" + html
end

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
    attributes = list_items.each_with_index.map do |_, i|
      "position: absolute; left: #{
        i * (100 / (list_items.length - 1)) - 10}%\" class=\"post-meta"
    end
    attributes[0] = 'float: left'
    attributes[-1] = 'float: right'
    div_list = list_items.zip(attributes).map { |item, attribute| "<div style=\"#{attribute}\">#{item}</div>" }
    inline_list = "<div class=\"post-preview\" style=\"overflow: auto; position: relative;\">#{div_list.join('')}</div>\n"
    output << text_before + inline_list + text_after
  end
  output
end

class Jekyll::Converters::Markdown::CVProcessor
  def initialize(config)
    super()
    Jekyll::Hooks.register :pages, :pre_render do |page|
        @page_data = page.data
    end
  end

  def convert(content)
    content = format_tilde_lists(content)
    html = Kramdown::Document.new(
      content, input: 'GFM'
    ).to_html
    if @page_data and @page_data.key?("header")
      html = resolve_header(html, @page_data)
    end
  end
end
