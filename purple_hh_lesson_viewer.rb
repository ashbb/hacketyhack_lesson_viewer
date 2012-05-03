require 'purple_shoes'
require 'nkf'
require_relative 'purple_turtle'

class IconButton < Shoes::Widget
  def initialize type, &blk
    over = stack(width: 16, height: 16){}
    @bgs = []
    over.hover{@bgs.flatten.each &:show}
    over.leave{@bgs.flatten.each &:hide}
    over.click{blk.call}
    timer 0.01 do
      @bgs << rect(over.left, over.top, 16, 16, hidden: true, strokewidth: 0, fill: gray(0.8))
      strokewidth 1
      stroke crimson
      nofill
      send type, over.left, over.top
      stroke black
      @bgs << send(type, over.left, over.top)
      @bgs.last.each &:hide
      strokewidth 0
      fill black
    end
  end
  
  def arrow_right x, y
    [line(x+1, y+8, x+14, y+8), 
     line(x+14, y+8, x+10, y+1+3), 
     line(x+14, y+8, x+10, y+15-3)]
  end

  def arrow_left x, y
    [line(x+1, y+8, x+14, y+8), 
     line(x+1, y+8, x+6, y+1+3), 
     line(x+1, y+8, x+6, y+15-3)]
  end

  def x x, y
    [line(x+2, y+2, x+13, y+13), 
     line(x+2, y+13, x+13, y+2)]
  end

  def menu x, y
    [rect(x+2, y+2, 11, 11), 
     line(x+4, y+6, x+11, y+6), 
     line(x+4, y+8, x+11, y+8), 
     line(x+4, y+10, x+11, y+10)]
  end
end

module GreenShoesMarkDown
  include HH::Markup
  def read_md file
    str = IO.read(file).force_encoding("UTF-8")
    #str = NKF.nkf('-wLu', str) unless RUBY_PLATFORM =~ /mingw/
    str.split("\n\n")
  end
  
  def show_page data
    data.each do |str|
      case
      when str =~ /^# /
        title strong str[2..-1]
      when  str =~ /^## /
        subtitle strong str[3..-1]
      when  str =~ /^### /
        flow do
          background gray
          caption strong fg(str[4..-1], white)
        end
      when str =~ /^    /, str =~ /^```/
        str = str.split("\n")[1...-1].join("\n") if str =~ /^```/
        flow do
          background "#eee", curve: 5
          para link('run'){eval str, TOPLEVEL_BINDING}, margin_left: width-100
          para *highlight(str).map{|e| code e}
        end
      when str =~ /^!\[.*\]\((.*)\)/
        file = $1
        if file =~ /\.[png|jpg|gif]/
          image File.join(PATH, file)
        else
          txts = str.split("\n")
          txts[0] =~ /^!\[(.*)\]\(\/(.*)\/(.*)\)/
          func, type, msg = $2, $3, $1
          send func, type, &proc{alert msg unless msg.empty?}
          para mk_strong_em_code(txts[1..-1].join("\n"))
        end
      when str =~ /^\d+\.* .+/
        flow margin_left: 30 do
          para *mk_txts(str)
        end
      else
        para *mk_txts(str.gsub "\n", ' ')
      end
    end
  end
  
  def mk_txts str
    txts = []
    loop do
      n = str.index(/\[(.*?)\]\((.*?)\)/)
      term, url = $1, $2
      if n
        txts << mk_strong_em_code(str[0...n])
        txts << link(term){visit url}
        str = str[(n + (term + url).length + 4)..-1]
      else
        txts << mk_strong_em_code(str)
        break
      end
    end
    txts
  end
  
  def mk_strong_em_code str
    str.gsub(/__(.+?)__/){"#{strong $1}"}.gsub(/`(.+?)`/){"#{fg code($1), green}"}.
      gsub(/_(.+?)_/){|s| t = $1; s =~ /</ ? s : "#{em t}"}
  end
end

#file = ask_open_file
Shoes.app title: 'Hackety Hack Lesson Viewer', width: 800, height: 700 do
  file = ask_open_file
  PATH = '.'
  extend GreenShoesMarkDown
  flow width: 1.0, margin: 10 do
    background "#ddd"
    flow width: 0.95 do
      show_page read_md file
    end
  end
end #if file
