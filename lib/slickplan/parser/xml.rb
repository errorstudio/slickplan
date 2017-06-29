module Slickplan
  module Parser
    class XML
      def self.parse(xml)
        doc = Nokogiri::XML(xml)
        sitemap = Slickplan::Sitemap.new(title: doc.css('sitemap>title').text)
        sitemap.templates = doc.css('content_templates>template').collect do |t|
          Slickplan::Template.new(name: t.attr(:name), id: t.attr(:id))
        end
        sitemap.pages = doc.css('section#svgmainsection>cells>cell').collect do |p|
          template_id = p.css('contents>template').text
          parent_id = p.css('parent').text

          Slickplan::Page.new(id: p.attr(:id), title: p.css('text').text, content: p.css('contents>body>wysiwyg>content').text, template_id: template_id, template: sitemap.templates.find {|t| t.id == template_id}, parent_id: parent_id)
        end
        sitemap.pages.each do |page|
          page.parent = sitemap.pages.find {|p| p.id == page.parent_id}
        end
        return sitemap
      end
    end
  end
end
