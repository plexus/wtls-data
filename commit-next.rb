#!/usr/bin/env ruby

require 'shellwords'

$push = (ARGV[0] == '--push')

if $push
  puts "NOTE: Pushing after every automated commit."
end


class Commit
  def find(dir)
    (Dir["#{dir}/*/*/*/*"] + Dir["#{dir}/*/*/*/*/*"]).reject do |x|
      File.directory?(x)
    end
  end

  def find_file(dir = '*', name)
    Dir[File.join(File.dirname(__FILE__), dir, '*', '*', '*', "*#{name}*")].first
  end

  # Find next uncommitted PCL + tsion/ + steveklabnik/ grouping.
  def find_next
    status = `git status -s`.lines.reject(&:nil?).grep(/.. (PCL|tsion|steveklabnik)\//)
    return nil if status.empty?

    first = status.map{|x| x.gsub(/^.. /, '') }.first.strip
  
    if File.directory?(first) 
      return [first, [first]]
    else
      name = first.split('/')[-1].split('_', 2)[1]
    end

    pcl   = find_file('PCL', name)
    tsion = find_file('tsion', name)
    steve = find_file('steveklabnik', name)

    [name, [pcl, tsion, steve]]
  end

  def update
    name, files = find_next

    if name.nil?
      puts "Nothing to commit!"
      return
    end

    files = files.reject(&:nil?).map{|x| Shellwords.escape(x) }.join(' ')
    msg = Shellwords.escape("Add #{name}.")
    cmd = "git add #{files} && git commit -m #{msg}"
    cmd += " && git push" if $push
    `#{cmd}`
  end
end
