# ScmacrosRepositoryInclude
# Copyright (C) 2010 Gregory Romé
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
require 'redmine'

module ScmacrosRepositoryInclude
  Redmine::WikiFormatting::Macros.register do
    desc "Includes and formats a file from repository.\n\n" +
      " \{{repo_include(file_path)}}\n" +
      " \{{repo_include(file_path, rev)}}\n"
    macro :repo_include do |obj, args|
      
      return nil if args.length < 1
      file_path = args[0].strip
      rev ||= args[1].strip if args.length > 1
    
      repo = @project.repository
      return nil unless repo
      
      text = repo.cat(file_path, rev)
      text = Redmine::CodesetUtil.to_utf8_by_setting(text)
      
      o = text
      
      return o
    end
  end

  Redmine::WikiFormatting::Macros.register do
    desc "Includes and formats a file from repository with syntax highlighting.\n\n" +
      " \{{repo_includecode(file_path, language, rev)}}\n"
    macro :repo_includecode do |obj, args|
      return nil if args.length < 1
      file_path = args[0].strip
      rev ||= args[2].strip if args.length > 2

      language ||= args[1].strip if args.length > 1

      repo = @project.repository
      return nil unless repo

      text = repo.cat(file_path, rev)
      text = Redmine::CodesetUtil.to_utf8_by_setting(text)

      if Redmine::SyntaxHighlighting.language_supported?(language)
        o = "<pre><code class=\"#{language} syntaxhl\">" +
          Redmine::SyntaxHighlighting.highlight_by_language(text, language) +
          "</code></pre>"
      else
        o = "<pre><code>#{ERB::Util.h(text)}</code></pre>"
      end

      o = o.html_safe
      return o
    end

  end


  Redmine::WikiFormatting::Macros.register do
    desc "Includes and formats a file from other repository with syntax highlighting.\n\n" +
      " \{{repo_include_repo_code(repositoryidentifier, file_path, language, rev)}}\n"
    macro :repo_include_repo_code do |obj, args|
      #Rails::logger.info '-----------------------------------------------------'
      #Rails::logger.info args.length
      return nil if args.length < 3

      identifier = args[0].strip
      file_path = args[1].strip
      language ||= args[2].strip
      rev ||= args[3].strip if args.length > 3

      repo = Repository::Git.find_by_identifier(identifier)
      return nil unless repo

      text = repo.cat(file_path, rev)
      text = Redmine::CodesetUtil.to_utf8_by_setting(text)

      if Redmine::SyntaxHighlighting.language_supported?(language)
        o = "<pre><code class=\"#{language} syntaxhl\">" +
          Redmine::SyntaxHighlighting.highlight_by_language(text, language) +
          "</code></pre>"
      else
        o = "<pre><code>#{ERB::Util.h(text)}</code></pre>"
      end

      o = o.html_safe
      return o
    end

  end


  Redmine::WikiFormatting::Macros.register do
    desc "Includes and formats a file from repository.\n\n" +
      " \{{repo_includewiki(file_path)}}\n"
    macro :repo_includewiki do |obj, args|
      
      return nil if args.length < 1
      file_path = args[0].strip
    
      repo = @project.repository
      return nil unless repo
      
      text = repo.cat(file_path)
      text = Redmine::CodesetUtil.to_utf8_by_setting(text)
      
      o = textilizable(text)
      
      return o
    end
  end

  Redmine::WikiFormatting::Macros.register do
    desc "Includes and formats a file from repository as a Markdown.\n\n" +
      " \{{repo_includemd(file_path)}}\n"
    macro :repo_includemd do |obj, args|
      
      return nil if args.length < 1
      file_path = args[0].strip
    
      repo = @project.repository
      return nil unless repo
      
      text = repo.cat(file_path)
      text = Redmine::CodesetUtil.to_utf8_by_setting(text)
      
      o = Redmine::WikiFormatting.to_html(:markdown, text)
      o = o.html_safe
      
      return o
    end
  end
end
