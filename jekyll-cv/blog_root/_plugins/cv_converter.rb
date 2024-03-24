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

def convert_icons(html)
  output = ""
  span_regex = /<span [^<]+?><\/span>/
  split_locations = [0] + html.gsub(span_regex).map{
    [Regexp.last_match.begin(0), Regexp.last_match.end(0)]
  }.flatten() + [html.length]
  for split_start, split_end in split_locations.zip(split_locations.drop(1))
    next unless split_start and split_end
    item = html[split_start..(split_end - 1)]
    data_icon_matches = item.match(/data-icon="(.+?)"/)
    if item.match(span_regex) and data_icon_matches and item.include? "iconify"
        data_icon_matches = data_icon_matches.captures
        if item.include? "tabler"
            item = item.gsub('class="', 'class="ti ' + data_icon_matches[0].gsub("tabler:", "ti-") + " ")
        end
        if item.include? "ic:" # Google Material icons
            full_icon_name = data_icon_matches[0].gsub("ic:", "")
            icon_types = {
                "outline" => "outlined",
                "round" => "round",
                "sharp" => "sharp",
                "two-tone" => "two-tone"
            }
            icon_type = ""
            icon_name_part = ""
            icon_types.each do |icon_name_part_iter, icon_type_iter|
                if full_icon_name.include? icon_name_part_iter
                    icon_name_part = icon_name_part_iter
                    icon_type = "-" + icon_type_iter
                end
            end
            item = item.gsub('class="', 'style="font-size:1em" class="material-icons' + icon_type + " ").gsub("><", ">" + full_icon_name.gsub(icon_name_part + "-", "").gsub("-", "_") + "<")
        end
    end
    output << item
  end
  %(
    <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@latest/tabler-icons.min.css" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/material-icons@1.13.12/iconfont/material-icons.min.css">
  ) + output
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
    html = convert_icons(html)
  end
end
