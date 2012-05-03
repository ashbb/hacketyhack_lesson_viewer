class Shoes::App
  def method_missing m, *args, &blk
    @start ? @cmds.push([m, args, blk]) : @turtle.send(m, *args, &blk)
  end
end

class Turtle
  def self.draw start = false, &blk
    Shoes.app title: 'Turtle Graphics' do
      @start, @cmds = start, []
      speed = start ? start : 1
      turtle = image './static/turtle.png'
      turtle.rotate = [360, turtle.left+turtle.width/2, turtle.top+turtle.height/2]
      turtle.move 300-turtle.width/2, 250-turtle.height/2
      @turtle = Turtle.new turtle, self
      instance_eval &blk if blk

      turtle = @turtle.turtle
      x, y, r = turtle.left, turtle.top, turtle.rotate
      turtle.clear
      turtle = image './static/turtle.png', hidden: true
      turtle.move x, y
      turtle.rotate = r
      turtle.show

      button 'start' do
        turtle.clear
        n = @cmds.length
        e = animate speed do |i|
          j = i - 1
          if @cmds[j][2]
            @turtle.send @cmds[j][0], *@cmds[j][1], &@cmds[j][2]
          else
            @turtle.send @cmds[j][0], *@cmds[j][1]
          end
          e.stop if i >= n
        end if n > 0
      end if @start
    end
  end

  def self.start speed = 1, &blk
    draw speed, &blk
  end
  
  def initialize turtle, app
    @turtle, @app = turtle, app
    @r = @n = 0
    @stroke = @app.black
    @pendown = true
  end
  
  attr_reader :turtle
  
  def pencolor color
    @stroke = color
  end

  def pendown
    @pendown = true
  end

  def penup
    @pendown = false
  end
  
  def forward len
    x, y = @turtle.left, @turtle.top
    x -= len * Math.sin(-@r)
    y -= len * Math.cos(-@r)
    dx, dy = 22, 24
    @app.line(@turtle.left+dx, @turtle.top+dy, x+dx, y+dy, stroke: @stroke, strokewidth: 6) if @pendown
    @turtle.clear
    @turtle = @app.image './static/turtle.png', hidden: true
    @turtle.move x, y
    @turtle.rotate = [@n, @turtle.left+@turtle.width/2, @turtle.top+@turtle.height/2]
    @turtle.show
    @app.flush
  end

  def backward len
    forward -len
  end
  
  def turnright n
    @n += n
    @r = @n/180.0 * Math::PI
    @turtle.rotate = [@n, @turtle.left+@turtle.width/2, @turtle.top+@turtle.height/2]
  end

  def turnleft n
    turnright -n
  end
end
