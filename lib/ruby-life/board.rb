class Board
  attr_reader :generation, :width, :height, :births, :survivors, :running

  def initialize width, height, births=[3], survivors=[2,3]
    @width = width
    @height = height
    @survivors = survivors
    @births = births
    @generation = 0
    @board = Array.new(height) { Array.new(width, false) }
    @urnning = false
  end

  def [] x, y
    @board[@height-y-1][x]
  end

  def []= x, y, value
    @board[@height-y-1][x] = value
  end

  def live_neighbors x, y
    neighbors = [[x-1, y-1], [x, y-1], [x+1, y-1],
                 [x-1, y  ],           [x+1, y  ],
                 [x-1, y+1], [x, y+1], [x+1, y+1]]
    neighbors.map { |p| point_live? *p }.count true
  end

  def point_live? x, y
    in_bounds?(x, y) and self[x,y]
  end

  def flip x, y
    self[x,y]= !point_live?(x, y)
  end

  def characteristics
    "#{@width}x#{@height} B#{@births.join}/S#{@survivors.join}"
  end

  def to_s live='*', dead='.'
    board = @board.map do |line|
      line.map { |cell| cell ? live : dead }.join
    end.unshift(characteristics).join "\n"
  end

  def evolve
    @new_board = Array.new(@height) { Array.new(@width) }
    @width.times do |x|
      @height.times do |y|
        evolve_point x, y
      end
    end
    @board, @new_board = @new_board, nil
    @generation += 1
    self
  end

  def randomize p=0.5
    @width.times do |x|
      @height.times do |y|
        self[x,y]= rand <= p
      end
    end
    self
  end

  def run steps=Float::INFINITY, delay=1/60.0
    @running = true
    while @running
      begin
        @running = (steps -= 1) > 0
        puts "\e[H\e[2J#{evolve}"
        sleep delay
      rescue Interrupt
        @running = false
      end
    end
  end

  private
  def evolve_point x, y
    aliveness = self[x,y] ? @survivors : @births
    @new_board[@height-y-1][x] = aliveness.include? live_neighbors(x, y)
  end

  def in_bounds? x, y
    (0...@height) === y and (0...@width) === x
  end
end
