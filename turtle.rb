class Shoes::App
  def method_missing m, *args, &blk
    @start ? @cmds.push([m, args, blk]) : @turtle.send(m, *args, &blk)
  end
end

class Turtle
  def self.draw start = false, &blk
    Shoes.app title: 'Turtle Graphics' do
      @start, @cmds = start, []
      turtle = image './static/turtle.png', front: true
      turtle.rotate 360
      turtle.move 300-turtle.width/2, 250-turtle.height/2
      @turtle = Turtle.new turtle, self
      instance_eval &blk if blk
      button 'start' do
        n = @cmds.length
	e = every do |i|
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

  def self.start &blk
    draw true, &blk
  end
  
  def initialize turtle, app
    @turtle, @app = turtle, app
    @r = @n = 0
    @stroke = @app.black
    @pendown = true
  end
  
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
    @turtle.move x, y
    @app.flush
  end

  def backward len
    forward -len
  end
  
  def turnright n
    @n += n
    @r = @n/180.0 * Math::PI
    @turtle.rotate @n
  end

  def turnleft n
    turnright -n
  end
end
