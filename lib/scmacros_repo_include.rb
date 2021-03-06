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
      " \{{repo_include_repo_code(projectidentifier, repositoryidentifier, file_path, language, rev)}}\n"
    macro :repo_include_repo_code do |obj, args|
      return nil if args.length < 4

      projident = args[0].strip
      identifier = args[1].strip
      file_path = args[2].strip
      language ||= args[3].strip
      rev ||= args[4].strip if args.length > 4

      Rails::logger.info '1 -------------------------------------------------'
      Rails::logger.info User.current
    

      proj = Project.find_by_identifier(projident)
      #return nil unless proj
      return "Fehlende Rechte" unless User.current.allowed_to?(:view_changesets, proj)
      return "Projekt „#{projident}“ nicht gefunden." unless proj

      #allowed = User.current.allowed_to?(q.class.view_permission, q.project, :global => true)
      #Rails::logger.info '2 -------------------------------------------------'
      #Rails::logger.info allowed

      repo = proj.repositories.find_by_identifier_param(identifier)
      return "Projekt „#{projident}“ hat kein Repository mit der Kennung „#{identifier}“." unless repo

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
