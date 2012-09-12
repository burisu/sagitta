module ApplicationHelper

  def newsletter_html(comm)
    html = ""
    html << content_tag(:h1, comm.name)
    html << "<div>"
    for article in comm.articles
      art = ""
      title = article.title
      art << content_tag(:h2, title.html_safe)
      art << content_tag(:div, article.content)
      unless article.readmore_url.blank?
        art << link_to("Lire la suite...", article.readmore_url, :style => "display: block;")
      end
      html << content_tag(:div, art.html_safe)
    end
    html << "</div>"

    return html.html_safe
  end


end
