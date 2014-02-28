module UtilityHelper
  def title(page_title)
    content_for(:title) { page_title }
  end

  def icon(name, opts = {})
    opts[:size] = opts[:size] == 1 ? 'lg' : opts[:size].to_s + 'x' if opts[:size]
    name = name.to_s.gsub('_', '-')

    html_tag = ""
    html_tag << '<div class="icon-wrapper">' if opts[:wrapper]

    if opts[:circle]
      html_tag << "<span class=\"fa-stack fa-#{opts[:size] || 'lg'}\">"
      html_tag << '<i class="fa fa-circle fa-stack-2x"></i>'
      html_tag << "<i class=\"fa fa-#{name} fa-stack-1x fa-inverse\"></i>"
      html_tag << '</span>'
    else
      html_tag << "<i class=\"fa fa-#{name}"
      html_tag << " #{opts[:additional]}" if opts.has_key? :additional
      html_tag << " fa-border" if opts[:border]
      html_tag << " fa-#{opts[:size]}" if opts[:size]
      html_tag << '"></i>'
      html_tag << '</div>' if opts[:wrapper]
    end
    html_tag.html_safe
  end

  def placeholder(width, height = nil, text = nil)
    [["http://placehold.it/#{width}", *height].join("x"), *text].join("&text=")
  end
end