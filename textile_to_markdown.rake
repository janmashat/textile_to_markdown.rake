# Conversion methods originally authored by Joji Jorge Senda (d3j)
# https://gist.github.com/d3j/95924df9fccc4d381d75/, thank you!
# encoding: utf-8

namespace :redmine do
  desc 'Syntax conversion from textile to markdown'
  task :textile_to_markdown => :environment do

    module Textile2Markdown

      def self.textile_to_markdown(textile)
        d = []
        pre = false
        table_header = false
        text_line = false

        textile.each_line do |s|
          s.chomp!

          if pre
            if s =~ /<\/pre>/
              d << "~~~"
              pre = false
            else
              d << s
            end
            next
          end

          s.gsub!(/(^|\s)\*([^\s\*].*?)\*(\s|$)/, " **\\2** ")
          s.gsub!(/(^|\s)@([^\s].*?)@(\s|$)/, " `\\2` ")
          # convert strike through but protecting horizontal lines (----)
          s.gsub!(/(^|\s)-([^\s-].*?)-(\s|$)/, " ~~\\2~~ ")
          s.gsub!(/"(.*?)":(.*?)\.html/, " [\\1](\\2.html) ")
          # Bullet lists
          s.gsub!(/^([\*]+)( .*)/){ |s| "  " * ($1.length - 1) + "*" + $2}
          # Numbered lists
          s.gsub!(/^([\#]+)( .*)/){ |s| "  " * ($1.length - 1)  + "1." + $2}
          # external links with formatting
          s.gsub!(/([\*_\-@\+]{1,2})"(.*)":([^\s]*)\1/){ |s| "[#{$1}#{$2}#{$1}](#{$3})"}
          # external links
          s.gsub!(/"(.*)":([^\s]*)/){ |s| "[#{$1}](#{$2})"}

          d << ""  if text_line
          text_line = false

          case s
            when /^<pre>/
              d << "~~~"
              pre = true
            when /^h(\d)\. (.*)$/
              d << "#" * $1.to_i + " " + $2
            when /^!(.*?)!/
              d << "![](#{$1})"
            when /^\|_\./
              d << s.gsub("|_.", "| ")
              table_header = true
            when /^\|/
              d << s.gsub(/\=\..+?\|/, ":---:|").gsub(/\s+.+?\s+\|/, "---|") if table_header
              table_header = false
              d << s.gsub("|=.", "| ")
            when /^\s*$/
              d << s
            else
              d << s
              text_line = true
          end
        end

        d.join("\n") + "\n"
      end # END textile_to_markdown


      def self.update_content(model, attribute, where)
        total = model.where("#{where}").count
        model.where("#{where}").each_with_index do |rec, ix|
          if !rec[attribute].empty? then
            markdowned = textile_to_markdown(rec[attribute])
            markdowned = cleanup_md(markdowned, model)
            if markdowned != rec[attribute] then
              puts "++++++ #{model}.#{attribute} : #{rec[:id]} : #{ix+1} / #{total} ++++++"
              rec.update_column(:"#{attribute}", markdowned);
              # update_column already persists the change to the db, an additional save! would
              # set the updated_on tiemstamp to NOW which not not always wanted.
              # rec.save! # DISABLED
#        print markdowned
            else
              puts "====== #{model}.#{attribute} : #{rec[:id]} : #{ix+1} / #{total} ======"
            end
          else
            puts "------ #{model}.#{attribute} : #{rec[:id]} : #{ix+1} / #{total} ------"
          end
        end
      end

      def self.convert
        update_content(WikiContent, :text, 1)
        update_content(Issue, :description, 1)
        update_content(Journal, :notes, 1)

        # update_content(Issue, :description, "updated_on < '2015/10/04'")
        # update_content(Issue, :description, "id = 1784")convert
      end

      # Optional clean up of the converted markdown
      #
      # Add you own rules here
      def self.cleanup_md(markdown, model)
        if model == WikiContent
          markdown.gsub!(/\[\[TracNav\(NavigationMenu\)\]\]/, '')
        end

        markdown
      end

      old_notified_events = Setting.notified_events
      begin
        # Turn off email notifications temporarily
        Setting.notified_events = []
          # Run the conversion
        Textile2Markdown.convert
      ensure
        # Restore previous settings
        Setting.notified_events = old_notified_events
      end

    end # END module Textile2Markdown

  end
end
