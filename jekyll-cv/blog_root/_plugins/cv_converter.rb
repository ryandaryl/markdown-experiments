class Jekyll::Converters::Markdown::CVProcessor
    def initialize(config)
        super()
    end
    def convert(content)
        output = ""
        for text_before, left_align, c1, c2, c3, text_after in content.scan(/((?:.|\n)*?)(\n.+?)(\n +?~ .+?)(\n +?~ .+?)?(\n +?~ .+?)?\n((?:.|\n)*?)/) do
            output << "#{text_before}\n<div style=\"overflow: auto\"><div style=\"float: left\">#{Kramdown::Document.new(left_align.delete("\n"), input: 'GFM').to_html}</div><div style=\"float: right\">#{c1.gsub(/\n +?~ +?/, "")}</div></div>\n#{text_after}"
        end
        html = Kramdown::Document.new(output, input: 'GFM').to_html
        html
    end
end